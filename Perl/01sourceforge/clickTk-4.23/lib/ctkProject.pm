#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 ctkProject

	Class ctkProject models a project file as used in the clickTk
	session.

=head2 Syntax

	my $prj = ctkProject->new();

	$prj->open ;

	$prj->save;

	$prj->close;

=head2 Programming notes

=over

=item Still under construction

=back

=head2 Maintenance

	Author:	marco
	date:	28.10.2006
	History
			28.10.2006 MO03101 mam First draft
			26.11.2007 version 1.02 refactoring
			14.12.2007 version 1.03 refactoring
			13.10.2008 version 1.04
			28.10.2008 version 1.05
			15.04.2009 version 1.06
			23.04.2009 version 1.07
			30.07.2010 version 1.08

=head2 Methods

=head3 Summary

		_extractVariables
		_init
		assignVariables
		conflicts
		descriptor
		destroy
		empty_file_opt
		existsFolder
		extractVariables
		fileName
		generate_unique_id
		getType
		getWidgetIdList
		id_to_path
		index_of
		init
		insertGlobal
		insertLocal
		isRef2Widget
		name
		new
		noname
		parseNonvisualConstructor
		parseTkCode
		path_to_id
		refreshVariables
		removeGlobal
		removeLocal
		saveDataToFile

=cut

package ctkProject;

use strict;

use ctkFile;
use base (qw/ctkBase ctkFile/);

use Time::localtime;

our $VERSION = 1.08;

our $debug = 0;

our $noname;

our $projectFolder;

our @tree = ($main::getMW);       # design tree list ('.' separated entry)

our %descriptor=();    # (id->descriptor)

our $objCount = 0;      # counter for unique object id

our $changes;          # Modifications flag

our @baseClass;
our @libraries;
our @other_code;		## other code provided by programmer, do not manipulate it!
our @user_auto_vars;
our @user_gcode;
our @user_local_vars;
our @user_methods_code;
our @user_pod;
our @user_subroutines =("sub init { 1 }\n");

our $opt_modalDialogClassName ;	## name of the parent class of modal dialogs

my $FS = ctkFile->FS;

our $arg1;
our $arg2;
our @DTmessage =();

sub noname { return $noname }
sub descriptor { return \%descriptor }

sub new {
	my $class = shift;
	my (%args) = @_;
	$class = ref($class) || $class ;
	my $self = $class->SUPER::new(%args);
	bless  $self, $class;
	$self->_init(%args);

	return $self
}

sub destroy {
	my $self = shift;
	$self->SUPER::destroy(@_);
}

sub _init {
	my $self = shift;
	my (%args) = @_;
	## $self->SUPER::_init(%args);
	$self->init();
	return 1
}

sub init {
	my $self = shift;
	@baseClass =();
	@libraries = ();
	@other_code =();
	@user_auto_vars =();
	@user_gcode =();
	@user_local_vars =();
	@user_methods_code =("sub arglist {\n","my \$self=shift;\n","my \$args = shift;\n","return \$args\n","}\n");
	@user_pod =();
	@user_subroutines=("sub init { 1 }\n");
}

=head3 index_of

	return the index of the given id in the
	class data member @tree

	TODO : raise an exception if id not found

=cut

sub index_of {
	my $self = shift;
	my ($id) = @_;
	&main::trace("index_of");
	my $i=0;
	while ($tree[$i] !~ /(^|\.)$id$/) { $i++ };
	&main::trace("id '$id' returns i='$i'");
	return $i;
}

=head3 getType

	Return the type (class name) of the given widget path
	(default is the selected widget).

	Exception

	id doesn't exist in the class data member %descriptor

	TODO : check existence of $id first, then access the hash

=cut

sub getType {
	my $self= shift;
	my ($id) = @_;
	my $rv;
	if (defined($id)){
		&main::trace("getType ('$id')");
		$rv = $self->descriptor->{&main::path_to_id($id)}->type;
	} else {
		my $id = &main::getSelected();			## i MO03605
		if (defined $id) {						## i MO03605
			&main::trace('getType ('.'\''.$id.'\')');
			$rv= $self->descriptor->{&main::path_to_id($id)}->type;
		} else {
			&std::ShowErrorDialog("'getType' is missing valid args 'sel' and selected.\nProcess goes on with 'UNDEF', but data may be corrupted.");
		}
	}
	&main::trace("rv = '$rv'");
	return $rv
}

=head3 generate_unique_id

	Build the id of a new widget definition

	Argument

		widget class

	Return

		id

	Note : the class data member $objCount is
	used to make the id unique.

=cut

sub generate_unique_id {
	my $self = shift;
	my $type = shift;
	&main::trace("generate_unique_id type =$type");
	my $id;
	do {
		$objCount++;
		## $id = sprintf("%s%s%s%.3d",$identPrefix,$type,'_',$ctkProject::objCount);
		$id = sprintf("%s%.3d",$main::identPrefix,$objCount);
	} while(exists $self->descriptor->{$id});

	&main::trace("id='$id'");
	return $id;
}

=head3 empty_file_opt

	Return the hash or ref to hash
	of the default file_opt structure.

=cut

sub empty_file_opt {
	my $self = shift;
	&main::trace("empty_file_opt");
	my (%fo) = ('description' => '',
				'title' => '',
				'code' => 0,
				'strict' => 0,
				'modal' => 0,
				'buttons' => ' ',
				'subroutineName' => $ctkTargetSub::subroutineName,
				'subroutineArgs' => $ctkTargetSub::opt_defaultSubroutineArgs,
				'subroutineArgsName' => $ctkTargetSub::subroutineArgsName,
				'modalDialogClassName' => $opt_modalDialogClassName,
				'autoExtractVariables' => 1,
				'autoExtract2Local' => 1,
				'baseClass' => '',
				'subWidgetList' => [],
				'onDeleteWindow' => 'sub{1}',
				'Toplevel' => '1',
				'treewalk' =>'D'			## MO06002 , set default to 'D' because of packAdjust
				);
	return wantarray ? (%fo) : \%fo;
}

=head3 existsFolder

	Return true if the project folder exists.

=cut

sub existsFolder {
	my $self = shift;
	my ($path) = @_;
	my $rv = (-d "$path$FS$projectFolder") ? 1:0;
	return $rv
}

=head3 name

	Build the project name out of the given file name.

=cut

sub name {
	my $self = shift;
	my ($file) = @_ ;
	my $rv;
	$file = $self->noname unless (defined($file));
	$file = "${main::applName}_00.pl" if ($file eq $self->noname && $main::applName);
	if ($file =~ /[\\\/]/) {
			$rv = &main::_name($file,$projectFolder);
	} else {
		$rv = $file
	}
	return $rv
}

=head3 fileName

	Build the file name for the given project name.

=cut

sub fileName {
	my $self = shift;
	my ($file) = @_ ;
	&main::trace("fileName");
	$file = $self->noname unless(defined($file));
	return $file if ( $file =~ /^(\.[\\\/]){0,1}$projectFolder/);
	$file =~ s/\.pm$/.pl/;
	return ".$FS$projectFolder$FS$file";
}

=head3 getWidgetIdList

	Return the id of all currently defined widgets
	as array or ref to array.


=cut

sub getWidgetIdList {
	my $self = shift;
	my @rv =();
	map {
		push @rv,&main::path_to_id($tree[$_]);
	} 1..$#tree;
	return wantarray ? @rv : \@rv;
}

=head3 isRef2Widget

	Check if the geiven widget's ids
	are in the list of the defined wigets.

	Return the number of name matches.

=cut

sub isRef2Widget {
	my $self = shift;
	&main::trace("isRef2Widget");
	my $rv;
	my $list = $self->getWidgetIdList();
	unshift @$list,&main::path_to_id($tree[0]);
	map {
		my $id = $_;
		$id =~ s/^\$//;
		$rv ++ if grep( $id eq $_, @$list);
	} @_;
	&main::trace("rv = $rv");
	return $rv;
}

=head3 path_to_id

	Return the id of the given path
	Default id is getSelected()

	Exception 'Missing selected widget'

=cut

sub path_to_id {
	my $self = shift;
	my ($id) = @_;
	my $rv;
	$id = &main::getSelected unless defined($id);
	&main::trace("path_to_id '$id'");
	unless (defined($id)) {
		&std::ShowErrorDialog("Missing selected widget, cannot convert path to id.");
		return undef
	}
	my @a = split /\./,$id;
	$rv = pop @a;
	return $rv;
}

=head3 id_to_path

	Scan the class data member ctkProject::tree
	for the given id and reurn the found item.

	Argument

	id

	Exception : more thean one item found

	Return

		found item or
		UNDEF if none found

=cut

sub id_to_path {
	my $self = shift;
	my ($id) = @_;
	my @w;
	my $rv;
	unless($id) {
		&std::ShowErrorDialog("Missing expected widget ident,\ncannot determine parent widget.");
		return undef
	}
	@w = grep(/$id$/,@ctkProject::tree);
	if (@w > 1) {
		&std::ShowErrorDialog("Widget tree is damaged.\nMore than one widget id '$id' found.");
	} elsif (@w == 1) {
		$rv = $w[0]
	} else {
		$rv = undef
	}
	return $rv;
}

=head3 saveDataToFile

	- generate the code
	- set up an instance of type ctkFile
	- create a backup
	- write the generated code
	- return true if the close did well.

	Argument

	- file name

=cut

sub saveDataToFile {
	my $self = shift;
	my ($fName) = @_;
	my $rv;
	&main::trace("saveDataToFile");

	my $source = &main::code_generate();
	if (defined($source)) {
		my $f = ctkFile->new(fileName =>$fName,debug => $debug);
		$f->backup();
		if ($f->open('>')) {
			map {$f->print("$_\n") } @$source;
			$f->close;
			$rv = 1;
			&main::trace("project '$fName' successfully saved")
		} else {
			# report error
			&std::ShowErrorDialog("Project '$fName' write error\n'$!'");
			}
	} else {
			&std::ShowErrorDialog("Project '$fName' not saved because of\n'empty gened code'");
	}
	return $rv
}

=head3 conflicts

	Scan the widgets definitions for existing conflicts

		conflict 1 	remove option -label from Frame with sub-widgets using grid
					(endless loop in Perl)

			for each frame widget
			get all children id's
			get those geometry
			remove -label if at least one match 'grid'

	Arguments
		None

	Return
		array of conflicts description or
		number of conflicts

=cut

sub conflicts {
		my $self = shift;
		my @rv;

	foreach my $elm (@tree[1..scalar(@tree)-1]) {
		my $id = &main::path_to_id($elm);
		next unless ($self->descriptor->{$id}->type eq 'Frame');
		my (@children)=grep(/\.$id\.([^\.]+)$/,@tree);
		next unless @children;
		map {s/.*\.//} @children;
		map {$_ = $self->descriptor->{$_}->geom} @children;
		if ( grep (/grid/,@children) ) {
			my (%opt)=&main::split_opt($self->descriptor->{$id}->opt);
			if ($opt{'-label'}) {
				delete $opt{'-label'};
				push @rv,"Option -label of widget '$id' has been suppressed,\n because it is not compatible with geometry mgr 'grid' \nused by widget's children.";
				$self->descriptor->{$id}->opt(&main::buildWidgetOptions(\%opt,$self->descriptor->{$id}->type));
			}
		}
	}
	return wantarray ? @rv : scalar(@rv);
}

=head3 parseTkCode

	For each widget description line:

		1. get Id, Parent, Type, parameters, geometry
		2. check for Parent existence
		3. add line to tree descriptor
		4. add element to widget descriptor
		5. collect variables and callbacks

	Arguments

		- widget constructor code (string)
		- line number within input batch (int)
		- assigned order (string)
		- nonvisual flag
		-

	Return

		array of exceptions

	Global structures

		%ctkProject::descriptor (id->descriptor)
		@ctkProject::tree
		@ctkProject::user_auto_vars - user-defined variables to be pre-declared automatically
		use vars qw/$x/;

	Global widgets used:

		$tf - preview tree


=cut

sub parseTkCode {
	my $self = shift;
	my ($line,$count,$order,$nonvisual,$where) = @_;
	my @rv =();
	my $MW = &main::getMW();
	my $parser = ctkParser->new();

	&main::trace("parseTkCode '$line'");
	&main::trace("count '$count'") if (defined($count));
	&main::trace("nonvisual '$nonvisual'") if (defined($nonvisual));
	&main::trace("where '$where'") if (defined($where));

	$nonvisual = 0 unless defined $nonvisual;
	$where = 'push' unless (defined($where));

	my $pic = &main::get_picW;
	my $picN;

	my @token = $parser->parseWidgetOptionsQuotate($parser->parseStringExtended($line));

	map {s/\(/#28/g if length > 1 } @token;
	map {s/\)/#29/g if length > 1 } @token;

	&main::trace("line = '$line'");

	map {&main::trace("$_,$token[$_]")} 0..$#token;

	# 1. get Id, Parent, Type, parameters, geometry

	my ($id,$parent,$type,$opt,$geom,$menuConfig,$scrolledClass);

	unless ($nonvisual) {
		my @t = ();
		my $p;
		my @classes = (qw/menuCommand tkCommandScrolled tkCommand/);
		my $class;
		while (@classes) {
			$class = shift @classes;
			$p = $class->new(-tokenList, \@token);
			eval {@t = $p->parse();};
			last unless ($@)
		}
		if ($@) {
				my $w = "line ${count}: Could not parse code '$line', code discarded";
				main::Log($w);
				push @rv, $w;
				return wantarray ? @rv : \@rv
		} else {
			if ($class eq 'tkCommand') {
				$id     = shift(@t); $id =~ s/^\$//;
				$parent = shift(@t); $parent =~ s/^\$//;
				$type   = shift(@t);
				$opt    = (@t) ? shift(@t) : '( )';
				$geom   = (@t > 1) ? shift(@t) . '(' . shift(@t) . ')' : shift @t
			} elsif ($class eq 'menuCommand') {
				my $virtual_parent;
				($id,$virtual_parent,$type,$parent,$menuConfig) = @t;
				$id =~ s/^\$//;
				$parent =~ s/^\$//;
				$menuConfig =~ s/^\$//;
			} elsif($class eq 'tkCommandScrolled') {
				$id     = shift(@t); $id =~ s/^\$//;
				$parent = shift(@t); $parent =~ s/^\$//;
				$type = shift(@t);
				$scrolledClass = shift(@t);
				$opt = (@t) ? shift(@t) : '';
				$opt = $scrolledClass .' , ' . $opt;
				$geom   = (@t > 1) ? shift(@t) . '(' . shift(@t) . ')' : shift @t
			}
		}
	} else {
		$id = $token[0];$id =~ s/^\$//;
		$parent = $token[2]; $parent =~ s/^\$//;
		$type = $token[4];
		$opt = '';
		if (!&main::nonVisual($type)) {
			my $w = "line ${count}: class <$type> for widget <$id> isn't a non-visual class.";
			main::Log($w);
			push @rv, $w;
			return wantarray ? @rv : \@rv
		} else {}
	}

	$opt =~ s/#28/(/g;
	$opt =~ s/#29/)/g ;


	# 2. check widget existence

	# 2.1 Parent exists ?

	if($parent ne $MW && ! defined $self->descriptor->{$parent}) {
		# error - report in Tk style:
		push @rv, "line ${count}: Wrong parent id <$parent> for widget <$id>";
		return wantarray ? @rv : \@rv
	}

	# 2.2 ident exists ?
	if (exists $self->descriptor->{$id}) {
		push @rv, "line ${count}: Duplicated widget <$id> definition\n";
		return wantarray ? @rv : \@rv
	}

	$objCount++;

	# 3. add line to tree descriptor

	my $parent_path = main::id_to_path($parent);
	$parent_path=$MW unless $parent_path;
	my $insert_path;
	my $new_path;

	if ($where eq 'push') {
		($insert_path)=(grep(/$parent\.[^.]+$/,@tree))[-1];
		$new_path = "$parent_path.$id";
		push(@tree,$new_path);
		main::trace('widget tree after push',@tree);
	} elsif ($where eq 'splice') {
		($insert_path)=(grep(/$parent\.[^.]+$/,@tree))[-1];
		$new_path = "$parent_path.$id";
		push(@tree,$new_path);
		main::trace('widget tree after splice',@tree);
	} else {
		push @rv,"unexpected where argument value '$where', operation discarded";
		return (wantarray) ? @rv : \@rv
	}

	$type =~ s/\s//g;

	# 4. add element to widget descriptor

	if ($type eq 'add'){
		$type = 'NoteBookFrame';
		$opt =~ s/^\s*\S+\s*,\s*//;
	}

	if ($nonvisual) {
			$self->descriptor->{$id}=&main::createDescriptor($id,$parent,$type,'','',$order);
	} else {

		if ($type =~ /^Scrolled/) {
			# my ($w) = $opt =~ /^\s*'*([a-zA-Z][a-zA-Z0-9_]*)'*\s*\,/;
			my $w = $scrolledClass;
			if (defined($w)) {
				$self->descriptor->{$id}=&main::createDescriptor($id,$parent,"Scrolled$w",$opt,$geom,$order);
			} else {
				my $e = "Missing class name in options '$opt' for scrolled widget '$id'";
				&main::trace($e);
				push @rv, "line $count : $e\n";
				return wantarray ? @rv : \@rv
			}
		} elsif ($type =~ /^Menu$/) {
			$self->descriptor->{$id}=&main::createDescriptor($id,$parent,$type,$opt,$geom,$order);
		} else {
			$self->descriptor->{$id}=&main::createDescriptor($id,$parent,$type,$opt,$geom,$order);
		}

		# 5. collect variables and callbacks

		if($opt=~/variable/){
			# store user-defined variable in array
			my ($user_var)=($opt=~/\\\$(\w+)/);
			&main::trace("Variable '$user_var' detected parsing '$opt'");
			$self->assignVariables("\$$user_var") if ($user_var) ;
		}
		if ($opt=~/(-command|-\w*cmd)\s*=>\s*([^\-^\)]+)/) {
			my $w = $2;
			$w =~ s/^\s+//;
			$w =~ s/\s+$//;
			$w =~ s/[,\)]$//;
			&main::pushCallback($w);
		} else {
		}
	}

	return wantarray ? @rv : \@rv;
}

=head3 parseNonvisualConstructor

	Parse the given constructore code and
	build up a descriptor for the given nonvisual entry.

	The constructor code looks like this

	$<id> = <type> -> new (<optionslist>);

=cut

sub parseNonvisualConstructor {
	my $self = shift;
	my ($line,$count,$order,$nonvisual,$where) = @_;
	my @rv =();
	my $MW = &main::getMW();
	my $parser = ctkParser->new();

	my @token = $parser->parseString($line);

	&main::trace("line = '$line'");

	my ($id,$parent,$type,$opt);

	$parent = $MW;
	my $parent_path = main::id_to_path($parent);
	my $insert_path;
	my $new_path;


	$id     = shift @token; $id =~ s/^\$//;
	$type   = shift @token;
	shift @token;
	$opt = join ',',@token;
	$opt =~ s/;$//;
	if (exists $self->descriptor->{$id}) {
		push @rv, "line ${count}: Duplicated widget <$id> definition\n";
		return wantarray ? @rv : \@rv
	}

	if ($where eq 'push') {
		($insert_path)=(grep(/$parent\.[^.]+$/,@tree))[-1];
		$new_path = "$parent_path.$id";
		push(@tree,$new_path);
		main::trace('widget tree after push',@tree);
	} elsif ($where eq 'splice') {
		($insert_path)=(grep(/$parent\.[^.]+$/,@tree))[-1];
		$new_path = "$parent_path.$id";
		push(@tree,$new_path);
		main::trace('widget tree after splice',@tree);
	} else {
		push @rv,"unexpected where argument value '$where', operation discarded";
		return (wantarray) ? @rv : \@rv
	}

	$self->descriptor->{$id}=&main::createDescriptor($id,$parent,$type,$opt,'',$order);
	return wantarray ? @rv : \@rv;
}

=head3 _extractVariables

	- set up a parser instance
	- get descriptor
	- parse options string to options list
		message parseWidgetOptionsQuotate( return of message parseString)
	- scan options list
		- build option's pair (opt , value)
		  skip opt
		  - check value for
				constant
				variable's name beginning with %@$ (package name not yet supported)
				ref to variable
				element of array or hash
				ref to list [ ]
				closure (get not analyzed)
	- return the list of found variable's ident
	  (depending on context array or ref to array)

=cut

sub _extractVariables {
	my $self = shift;
	&main::trace("extractVariables");

	my @rv =();
	my $parser = ctkParser->new();
	foreach my $element (@ctkProject::tree[1..$#tree]) {
		my $d = $self->descriptor->{&main::path_to_id($element)};
		next unless $d;
		my @token = $parser->parseWidgetOptionsQuotate($parser->parseString($d->opt));
		foreach (0..$#token) {
			next unless $token[$_] =~ /^-/;
			my ($opt,$value) = @token[$_,$_ + 1];
			if ($value =~ /^[\'\"\#\w]/i) {
				next
			} elsif ($value =~ /^[%@\$]/) {
				if ($value =~ /^(.)(\w+)\s*([\[\{])/) {
					$value =($3 eq '[') ? "\@$2" : ($3 eq '{') ? "\%$2" : "\$$2";
				}
				push(@rv,$value) unless grep($_ eq $value,@rv);
			} elsif ($value =~ /^\\[\$@%]/) {
				$value =~ s/^\\//;
				if ($value =~ /^\$(\w+)\s*([\[\{])/) {
					$value =($3 eq '[') ? "\@$2" : ($3 eq '{') ? "\%$2" : "\$$2";
				}
				push(@rv,$value) unless grep($_ eq $value,@rv);
			} elsif ($value =~ /\[[^,]+,([^]]+)\]/) {	## -command => [ sub {}, $var1,$var2]
				my $user_var = "$1";
				&main::trace("Possible variable list detected '$user_var'");
				$user_var =~ s/,/ /g;
				map {
					my $v = $_;
					if ($v =~ /^\$/) {
						push (@rv,$v) unless (grep $_ eq $v ,@rv);
						&main::trace("Variable '$v' detected.");
					} elsif ($v =~ /^\\[@%][a-z_]/i) {
						$v =~ s/^\\//;
							push (@rv,$v) unless (grep $_ eq $v ,@rv);
							&main::trace("Variable '$v' detected.");
					} elsif ($v =~ /\d+$/){
						## numeric constant, OK
					} elsif ($v =~ /sub\s*\{/){
						## anonymous sub
					} else {
						&main::trace("Extracting variables, possible variable $v discarded.") unless ($v =~ /^-/);
					}
				} $parser->parseWidgetOptionsQuotate($parser->parseString($user_var));
			} else {}
			## if() { ## more variable patterns go here
		}
	}
	return wantarray ? @rv : \@rv
}

=head3 extractVariables

	Extract valriables form the TK-commands and
	put them into data class members @user_local_vars
	and @user_auto_vars.
	Send message $self->_extractVariables to do the job,
	then save its return into the mentioned class data members.

=cut

sub extractVariables {
	my $self = shift;
	my @rv =();
	&main::trace("extractVariables");
	return wantarray ? @rv : \@rv  unless(main::getFile_opt()->{'autoExtractVariables'});
	@rv = $self->_extractVariables();
	foreach (@user_local_vars, @user_auto_vars) { ## eliminate vars which are already explicitly declared
		my $v = $_;
		next unless (grep ($v eq $_, @rv));
		foreach ( reverse 0..$#rv) {
			if ($rv[$_] eq $v) {
				splice @rv,$_,1 ;
				&main::trace("variable '$v' already declared, eliminated");
				last
			}
		}
	}
	return wantarray ? @rv : \@rv ;
}

=head3 Atomic methods for variable's handling

=over

=item insertLocal

=item insertGlobal

=item removeLocal

=item removeGlobal

=back

=cut

sub insertLocal  {
	my $self = shift;
	my $this = shift;
	print "\ninsertLocal $this" if ($debug);
	push @user_local_vars, $this;
}
sub insertGlobal  {
	my $self = shift;
	my $this = shift;
	print "\ninsertGlobal $this" if ($debug);
	push @user_auto_vars, $this;
}
sub removeLocal  {
	my $self = shift;
	my $this = shift;
	print "\nremoveLocal $this" if ($debug);
	@user_local_vars = grep ($_ ne $this, @user_local_vars);
}
sub removeGlobal  {
	my $self = shift;
	my $this = shift;
	print "\nremoveGlobal $this" if ($debug);
	@user_auto_vars = grep ($_ ne $this, @user_auto_vars);
}

=head3 refreshVariables

	Reassign the extracted variables and inform the user
	about reassignments.

	See class data member ctkProject::DTmessage

=cut

sub refreshVariables {
	my $self = shift;
	my (@w) = @_;
	&main::trace("refreshVariables");
	my $rv;
	return undef unless (@w);

	$rv = $self->assignVariables(@w);
	&std::ShowWarningDialog(join("\n",@ctkProject::DTmessage)) if (@ctkProject::DTmessage);
	@ctkProject::DTmessage =();
	return $rv
}

=head3 assignVariables

	This method saves the given list of variables in the global
	arrays depending on the actual conditions.

=over

=item Decision table

	see definition module ctkDT_variables.pl .

=item Notes

	- local variables are declared by means of my $variable .

	- global variables are declared with use vars qw/$variable/ .

	- same variable may exist in the local namespace and in the
	  global one (warning).

=back

=cut

sub assignVariables {
	my $self = shift;
	my (@w) = @_;
	&main::trace("assignVariables");
	my $rv = 0;
	return $rv unless (@w);
	die "Could not locate DT './ctkDTvar.pl'." unless(-f "./ctkDTvar.pl");
	require "ctkDTvar.pl";
	$arg2 = "Variable assignment ";
	foreach (@w) {
		$arg1 = $_;
		eval 'ctkDTvar::xTable();';
		die "\nCould not exec DT for '$arg1'\n$@" if ($@);
	}
	$rv = 1;
	return $rv ;
}

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
