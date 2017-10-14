package Net::Twitter::Role::InflateObjects;
use Moose::Role;
use namespace::autoclean;
use Data::Visitor::Callback;
use Digest::SHA;

=head1 NAME

Net::Twitter::Role::InflateObjects - Inflate Twitter API return values to Moose objects

=cut

requires qw/_inflate_objects/;

has _class_map => (
    traits    => ['Hash'],
    isa       => 'HashRef',
    default   => sub { {} },
    handles  => {
       set_cached_class => 'set',
       get_cached_class => 'get',
    },
);

override _inflate_objects => sub {
    my ($self, $datetime_parser, $obj) = @_;

    return unless ref $obj;

    my $visitor = Data::Visitor::Callback->new(
        hash   => sub { $self->_hash_to_object($datetime_parser, $_[1]) },
    );

    $visitor->visit($obj);
};

sub _attribute_inflator {
    my ($self, $datetime_parser, $name, $value) = @_;

    return URI->new($value) if $name =~ /url$/;
    return $datetime_parser->parse_datetime($value) if $name =~ /^created_at|reset_time$/;

    return $value;
}

sub _hash_to_object {
    my ($self, $datetime_parser, $href) = @_;

    my $signature = Digest::SHA::sha1_hex(
        join ',' => sort keys %$href
    );

    my $class = $self->get_cached_class($signature);
    unless ( $class ) {
        $class = Moose::Meta::Class->create_anon_class;
        for my $name ( keys %$href ) {
            $class->add_attribute(
                $name,
                reader => {
                    $name => sub { $self->_attribute_inflator($datetime_parser, $name, shift->{$name}) },
                },
            );
        }
        if ( exists $href->{created_at} ) {
            $class->add_method(relative_created_at => sub {
                my $self = shift;

                my $delta = time - $self->created_at->epoch;
                return "less than a minute ago" if $delta < 60;
                return "about a minute ago"     if $delta < 120;
                return int($delta / 60) . " minutes ago" if $delta < 45 * 60;
                return "about an hour ago"      if $delta < 120 * 60;
                return int($delta / 3600) . " hours ago" if $delta < 24 * 60 * 60;
                return "1 day ago"              if $delta < 48 * 60 * 60;
                return int($delta / (3600*24)) . " days ago";
            });
        }
        $class->make_immutable;
        $self->set_cached_class($signature, $class);
    }

    bless $href, $class->name;
}

1;

__END__

=head1 SYNOPSIS

  use Net::Twitter;
  my $nt = Net::Twitter->new(traits => [qw/InflateObjects API::Rest/]);
  
  $nt->credentials($username, $password);

  $r = $nt->friends_timeline;

  $r->[0]->user->name; # return values are objects with read accessors
  $r->[0]->created_at; # dates are inflated to DateTime objects
  $r->[0]->relative_created_at; # "6 minutes ago"

=head1 DESCRIPTION

This role provides inflation of HASH refs, returned by the Twitter API, into
Moose objects.  URLs are inflated to URI objects.  Dates are inflated to
DateTime objects.  Objects that have a C<created_at> attribute also have a
C<relative_created_at> method that prints times in the same style as the
Twitter web interface.

All HASH members have read accessors, so

  $r->[0]->{user}{screen_name}

Can be accessed as

  $r->[0]->user->screen_name

=head1 CAVEATS

An accessor is created for each HASH key returned by Twitter.  As Twitter adds
new attributes, InflateObjects will create accessors for them.  However,
    InflateObjects will also drop accessors if Twitter drops the corresponding
HASH element.  So, code that relies on HASH element will fail loudly if Twitter
drops support for it.  (This may be a feature!)

=head1 AUTHOR

Marc Mims <marc@questright.com>

=head1 LICENSE

Copyright (c) 2009 Marc Mims

The Twitter API itself, and the description text used in this module is:

Copyright (c) 2009 Twitter

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
