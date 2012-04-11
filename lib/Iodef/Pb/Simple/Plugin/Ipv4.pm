package Iodef::Pb::Simple::Plugin::Ipv4;
use base 'Iodef::Pb::Simple::Plugin';

use strict;
use warnings;

use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;

sub process {
    my $self = shift;
    my $data = shift;
    my $iodef = shift;
    
    my $addr = $data->{'address'};
    return unless($addr && $addr =~ /^$RE{'net'}{'IPv4'}/);
    
    my $category = ($addr =~ /^$RE{'net'}{'IPv4'}$/) ? AddressType::AddressCategory::Address_category_ipv4_addr() : AddressType::AddressCategory::Address_category_ipv4_net();
    
    my @additional_data;
    if($data->{'prefix'} && $data->{'prefix'} =~ /^$RE{'net'}{'CIDR'}{'IPv4'}$/){
        push(@additional_data,ExtensionType->new({
            dtype   => ExtensionType::DtypeType::dtype_type_string(),
            meaning => 'prefix',
            content => $data->{'prefix'},
        }));
    }
    
    if($data->{'asn'}){
        push(@additional_data,ExtensionType->new({
            dtype   => ExtensionType::DtypeType::dtype_type_string(),
            meaning => 'asn',
            content => $data->{'asn'},
        }));
    }
    
    if($data->{'asn_desc'}){
        push(@additional_data,ExtensionType->new({
            dtype   => ExtensionType::DtypeType::dtype_type_string(),
            meaning => 'asn_desc',
            content => $data->{'asn_desc'},
        }));
    }
    
    if($data->{'cc'}){
        push(@additional_data,
            ExtensionType->new({
                dtype   => ExtensionType::DtypeType::dtype_type_string(),
                meaning => 'cc',
                content => uc($data->{'cc'}),
            })
        );
    }
    
    if($data->{'rir'}){
        push(@additional_data,
            ExtensionType->new({
                dtype   => ExtensionType::DtypeType::dtype_type_string(),
                meaning => 'rir',
                content => uc($data->{'rir'}),
            })
        );
    }
    
    my $service;
    if($data->{'service'} && ref($data->{'service'}) eq 'ServiceType'){
        $service = $data->{'service'};
    } elsif($data->{'protocol'} || $data->{'portlist'}) {
        $service = ServiceType->new();
        my $proto = 'tcp';
        if($data->{'protocol'}){
            $proto = normalize($data->{'protocol'});
            $service->set_ip_protocol($proto);
        }
        if($data->{'portlist'}){
            $service->set_Portlist($data->{'portlist'});
        }
    }
    
    my $system = $data->{'system'};
    unless(ref($system) eq 'SystemType'){
        $system = SystemType->new({
            Node => NodeType->new({
                Address =>  AddressType->new({
                    category    => $category,
                    content     => $addr,
                }),
            }),
            category        => SystemType::SystemCategory::System_category_infrastructure(),
        });
    }

    if($#additional_data > -1){
        $system->set_AdditionalData(\@additional_data);
    }
    if($service){
        $system->set_Service($service);
    }

    my $event = EventDataType->new({
        Flow    => FlowType->new({
            System  => $system,
        }),
    });
    my $incident = @{$iodef->get_Incident()}[0];
    push(@{$incident->{'EventData'}},$event);
}

sub normalize {
    my $proto = shift;
    return $proto if($proto =~ /^\d+$/);

    for(lc($proto)){
        if(/^tcp$/){
            return(6);
        }
        if(/^udp$/){
            return(17);
        }
        if(/^icmp$/){
            return(1);
        }
    }
    return($proto);
}

1;