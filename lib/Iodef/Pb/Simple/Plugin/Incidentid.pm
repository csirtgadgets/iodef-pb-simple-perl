package Iodef::Pb::Simple::Plugin::Incidentid;
use base 'Iodef::Pb::Simple::Plugin';

use strict;
use warnings;

sub process {
    my $self = shift;
    my $data = shift;
    my $iodef = shift;
  
    my $source = $data->{'IncidentID'} || $data->{'source'} || 'unknown';
    
    unless(ref($source) eq 'IncidentIDType'){
        $source = IncidentIDType->new({
            content     => '',
            instance    => '',
            name        => $source,       
        });
    }
    @{$iodef->get_Incident()}[0]->set_IncidentID($source);
}

1;