package Iodef::Pb::Simple::Plugin::Md5;
use base 'Iodef::Pb::Simple::Plugin';

use strict;
use warnings;

sub process {
    my $self = shift;
    my $data = shift;
    my $iodef = shift;
    
    return unless($data->{'md5'});
    my $md5 = lc($data->{'md5'});
    return unless($md5 =~ /^[a-f0-9]{32}$/);
    
    my $hash = ExtensionType->new({
        meaning     => 'md5',
        content     => $md5,
        dtype       => ExtensionType::DtypeType::dtype_type_string(),
    });
    
    my $incident = @{$iodef->get_Incident()}[0];
    push(@{$incident->{'AdditionalData'}},$hash);  
}

1;