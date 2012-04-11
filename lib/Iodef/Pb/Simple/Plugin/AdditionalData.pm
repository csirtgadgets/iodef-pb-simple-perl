package Iodef::Pb::Simple::Plugin::AdditionalData;
use base 'Iodef::Pb::Simple::Plugin';

use strict;
use warnings;

sub process {
    my $self = shift;
    my $data = shift;
    my $iodef = shift;
    
    return unless($data->{'AdditionalData'} && ref($data->{'AdditionalData'}) eq 'ExtensionType');
    
    my $incident = @{$iodef->get_Incident()}[0];
    push(@{$incident->{'AdditionalData'}},$data->{'AdditionalData'});  
}

1;