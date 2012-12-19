package Iodef::Pb::Simple::Plugin::Alternativeid;
use base 'Iodef::Pb::Simple::Plugin';

use strict;
use warnings;

use Iodef::Pb::Simple qw/iodef_normalize_restriction/;

sub process {
    my $self = shift;
    my $data = shift;
    my $iodef = shift;
  
    my $altid = $data->{'AlternativeID'} || $data->{'alternativeid'};
    return unless($altid);
    
    unless(ref($altid) eq 'AlternativeIDType'){
        $altid = AlternativeIDType->new({
            IncidentID  => IncidentIDType->new({
                content     => $altid,
                instance    => '',
                name        => '',       
            }),
            restriction => iodef_normalize_restriction($data->{'alternativeid_restriction'}) || RestrictionType::restriction_type_private(),
        });
    }
    
    my $incident = @{$iodef->get_Incident()}[0];
    push(@{$incident->{'AlternativeID'}},$altid);
}

1;