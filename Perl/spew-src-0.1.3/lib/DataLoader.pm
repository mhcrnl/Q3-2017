
###################################################################
### DataLoader CLASS                                      	###
###################################################################
### Author:  Ben Garvey                                       	###
### Date:  Feb, 2004	 					###
###								###
### Description:  						###
###								###
### Methods:  			new				###
###								###
###								###
### Instance variables:		none				###
###								###
###################################################################

package DataLoader;

use strict;
use FileBaby;
use XML::Simple;
use Settings;
use HighScores;
use Score;

=for comment
use File::Basename;
use File::Spec;
use XML::Sax;
use XML::Sax::PurePerl;
use Carp;
use Exporter;
=cut

use XML::Sax::PurePerl;
use XML::Sax;

###################################################################
### SUB ROUTINE:  new						###
###################################################################
### Author:  Ben Garvey                                      	###
### Date:  Feb, 2004						###
###								###
### DESCRIPTION:						###
### 								###
### ARGUMENTS:							###
### 								###
### RETURNS:		DataLoader $self			###
###################################################################
sub new
{	my $self 		= {};

	bless $self;
	return ($self);
}

sub loadData
{	
	my $self = shift;	
	my $file = $_[0];
	my $type = $_[1];
	$self->{main} = $_[2];

	my $parser = new XML::Simple;
	
	my $doc = $parser->XMLin($file);
	
	my $ob = new HighScores;

	# Change the object if we have something else
	if ($type eq 'HighScores')
	{	$ob = new HighScores;
	}
	elsif ($type eq 'Settings')
	{	$ob = new Settings;
	}
	
	foreach my $key (keys %{$doc})
	{	if ($key eq 'Score')
		{	my @s = @{$self->printData($key => $doc->{$key}, $type => $ob)};

			print "SIZE3!  " . scalar(@s) . "\n";
			
		}

		$ob->configure($key => $self->printData($key => $doc->{$key}, $type => $ob));
	}

	$ob->configure('main', $self->{main});
	
	return $ob;
}

sub printData
{	my $self = shift;
	my $name = $_[0];
	my $input = $_[1];	
	my $rootName = $_[2];
	my $root = $_[3];

	my $ob = $input;

	if (ref($input) eq 'HASH')
	{	
		if (scalar(%{$input}) > 0)
		{	$ob = $name->new();
        
        		$ob->configure($rootName => $root);
        
        		foreach my $key (keys %{$input})
        		{	$ob->configure($key => $self->printData($key => $input->{$key}, $rootName => $root));
        		}

        
        		$ob = $ob;
        
        		$ob->configure('main' => $self->{'main'});
		}
		else
		{	$ob = "";
		}
	}
	elsif (ref($input) eq 'ARRAY')
	{	my @temp = ();

		foreach my $index (@{$input})
		{
			push(@temp, $self->printData($name => $index, $rootName => $root));
		}

		@{$ob} = @temp;


		#print "S: " . ${$ob}[0] . "\n";
		#print "S: " . ${$ob}[1] . "\n";
		#print "S: " . ${$ob}[2] . "\n";

		#$ob->configure('main' => $self->{'main'});
	}
	else
	{
	}

	return $ob;
}

sub saveData
{	my $self = shift;
	
	my $path = $_[0];
	my $ob = $_[1];
	my $type = $_[2];

	#my $ob = new HighScores;

	#if ($type eq "HighScores")
	#{	$ob = new HighScores;
	#}
	
	my $data = "";

	foreach my $k (keys (%{$ob}))
	{	print "KEYS $k " . ref($ob->{$k}) . "\n";

		if ($k ne 'main')
		{
			if ( ref($ob->{$k}) eq 'ARRAY' ) 
			{	my @a = @{$ob->{$k}};

				$data = "<Score>\n" . $data;
				
				foreach my $s (@a)
				{	if ($s ne "Score")
					{	
						foreach my $s2 (keys(%{$s}))
						{	$data .= "<$s2>" . $s->{$s2} . "</$s2>\n";
						}
					}
				}

				$data .= "</Score>\n";	
			}
			elsif ( ref($ob->{$k}) eq 'Score' ) 
			{	foreach my $k2 (keys (%{$ob->{$k}}))
				{	$data .= "<$k2>" . ($ob->{$k})->{$k2} . "</$k2>\n";
				}	
			}	
			else
			{	$data .= "<$k>" . $ob->{$k} . "</$k>\n";	
			}
		}
	}

	print $data . "\n";
	
	#my $data = $self->_generateXML() . "<QuoteSheet>\n" . $quoteSheet->getXMLData() . "</QuoteSheet>\n";

	# Using a simple file interface
	#my $fb = new FileBaby;

	# Write to my file
	#$fb->writeText($path, $data);	
}

return 1;

