package Iodef::Pb::Simple::Plugin::Relatedactivity;
use base 'Iodef::Pb::Simple::Plugin';

use strict;
use warnings;

sub process {
    my $self = shift;
    my $data = shift;
    my $iodef = shift;
  
    my $altid = $data->{'RelatedActivity'} || $data->{'relatedid'};
    return unless($altid);
    
    unless(ref($altid) eq 'RelatedActivityType' || ref($altid) eq 'ARRAY'){
        $altid = IncidentIDType->new({
            content     => $altid,
            instance    => '',
            name        => '',       
        });
    }
    
    my $incident = @{$iodef->get_Incident()}[0];
    push(@{$incident->{'RelatedActivity'}},$altid);
}

1;