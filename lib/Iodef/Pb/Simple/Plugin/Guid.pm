package Iodef::Pb::Simple::Plugin::Guid;
use base 'Iodef::Pb::Simple::Plugin';

use strict;
use warnings;

sub process {
    my $self = shift;
    my $data = shift;
    my $iodef = shift;
    
    return unless($data->{'guid'});
    
    my $ad = ExtensionType->new({
        dtype   => 'string',
        content => $data->{'guid'},
        meaning => 'guid'
    });
    
    my $incident = @{$iodef->get_Incident()}[0];
    push(@{$incident->{'AdditionalData'}},$ad);  
}

1;