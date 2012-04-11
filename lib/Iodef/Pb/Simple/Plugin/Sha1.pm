package Iodef::Pb::Simple::Plugin::Sha1;
use base 'Iodef::Pb::Simple::Plugin';

use strict;
use warnings;

sub process {
    my $self = shift;
    my $data = shift;
    my $iodef = shift;
    
    return unless($data->{'sha1'});
    my $sha1 = lc($data->{'sha1'});
    return unless($sha1 =~ /^[a-f0-9]{40}$/);
    
    my $hash = ExtensionType->new({
        meaning     => 'sha1',
        content     => $sha1,
        dtype       => ExtensionType::DtypeType::dtype_type_string(),
    });
    
    my $incident = @{$iodef->get_Incident()}[0];
    push(@{$incident->{'AdditionalData'}},$hash);  
}

1;