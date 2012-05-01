package Iodef::Pb::Simple::Plugin::Domain;
use base 'Iodef::Pb::Simple::Plugin';

use strict;
use warnings;

use Regexp::Common qw/URI/;

sub process {
    my $self = shift;
    my $data = shift;
    my $iodef = shift;
    
    my $addr = $data->{'address'};
    return unless($addr);
    
    # Regexp::Common qw/URI/ chokes on large urls
    return if($addr =~ /^(ftp|https?):\/\//);
    return unless($addr =~ /^[a-zA-Z0-9.\-_]+\.[a-z]{2,6}$/);
    
    my $category = AddressType::AddressCategory::Address_category_ext_value();
    
    my @additional_data ;
    if($data->{'rdata'}){
        my $r = ExtensionType->new({
            dtype   => ExtensionType::DtypeType::dtype_type_string(),
            meaning => 'rdata',
            content => $data->{'rdata'},
        });
        push(@additional_data,$r);
    }
    
    my $event = EventDataType->new({
        Flow    => FlowType->new({
            System  => SystemType->new({
                Node    => NodeType->new({
                    Address => AddressType->new({
                        category        => $category,
                        ext_category    => 'domain',
                        content         => $addr,
                    }),
                }),
                AdditionalData  => \@additional_data,
                category        => SystemType::SystemCategory::System_category_infrastructure(),
            }),
        }),
    });
    
    my $incident = @{$iodef->get_Incident()}[0];
    push(@{$incident->{'EventData'}},$event);
}

1;