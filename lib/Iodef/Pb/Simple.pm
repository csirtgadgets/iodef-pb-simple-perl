package Iodef::Pb::Simple;

use 5.008008;
use strict;
use warnings;

require Exporter;

our $VERSION = '0.05';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Iodef::Pb::Simple ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

# Preloaded methods go here.

use Iodef::Pb;
use Module::Pluggable require => 1;

my @plugins = __PACKAGE__->plugins();

sub new {
    my $class = shift;
    my $args = shift;

    $args->{'description'}  = 'unknown'     unless($args->{'description'});
    $args->{'lang'}         = 'EN'          unless($args->{'lang'});
    $args->{'timezone'}     = 'UTC'         unless($args->{'timezone'});

    unless(ref($args->{'description'}) eq 'MLStringType'){
        $args->{'description'} = MLStringType->new({
            lang    => $args->{'lang'},
            content => $args->{'description'},
        });
    }

    my $pb = IODEFDocumentType->new({
        lang        => $args->{'lang'},
        # IODEF version
        version     => '1.00',
        # PB version
        formatid    => '0.01',
        Incident    => [
            IncidentType->new({
                Description => $args->{'description'},
            }),
        ],
    });
    foreach(@plugins){
        $_->process($args,$pb);
    }

    return $pb;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Iodef::Pb::Simple - Perl extension providing high level API access to Iodef::Pb. It takes simple key-pair hashes and maps them to the appropriate IODEF classes using a Module::Pluggable framework of plugins.

=head1 SYNOPSIS

  use Iodef::Pb::Simple;
  use Data::Dumper;

  my $x = Iodef::Pb::Simple->new({
    contact     => 'Wes Young',
    #address    => 'example.com',
    #rdata      => '1.2.3.4',
    id          => '1234',
    address     => '1.1.1.1',
    prefix      => '1.1.1.0/24',
    asn         => 'AS1234',
    cc          => 'US',
    assessment  => 'botnet',
    confidence  => '50',
    restriction => 'private',
    method      => 'http://www.virustotal.com/analisis/02da4d701931b1b00703419a34313d41938e5bd22d336186e65ea1b8a6bfbf1d-1280410372',
  });

  my $str = $x->encode();
  warn Dumper($x);
  warn Dumper(IODEFDocumentType->decode($str));

=head1 DESCRIPTION

This library provides high level access to the Iodef::Pb API. It allows for the rapid generation of simple IODEF messages.

Once the buffer's are encoded, they can easily be transported via REST, ZeroMQ, Crossroads.io or any other messaging framework (or the google protocol RPC bits themselves). To store these in a database, you can easily base64 the data-structure and save as text.

=head2 EXPORT

None by default. Object Oriented.

=head1 SEE ALSO

 http://github.com/collectiveintel/iodef-pb-simple-perl
 http://github.com/collectiveintel/iodef-pb-perl
 https://github.com/collectiveintel/IODEF
 http://tools.ietf.org/html/rfc5070#section-3.2
 http://search.cpan.org/~gariev/Google-ProtocolBuffers/lib/Google/ProtocolBuffers.pm
 http://code.google.com/p/protobuf/
 http://search.cpan.org/~kasei/Class-Accessor/lib/Class/Accessor.pm
 http://search.cpan.org/~simonw/Module-Pluggable/lib/Module/Pluggable.pm
 http://collectiveintel.net

=head1 AUTHOR

Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

  Copyright (C) 2012 by Wes Young <claimid.com/wesyoung>
  Copyright (C) 2012 the REN-ISAC <ren-isac.net>
  Copyright (C) 2012 the trustee's of Indiana University <iu.edu>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
