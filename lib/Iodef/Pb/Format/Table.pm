package Iodef::Pb::Format::Table;
use base 'Iodef::Pb::Format';

use strict;
use warnings;

use Text::Table;
use Regexp::Common qw/net/;

my $addr_regex = qr/$RE{'net'}{'IPv4'}|https?|ftp|[a-z0-9._]+\.[a-z]{2,6}/;

sub write_out {
    my $self = shift;
    my $args = shift;
    
    #delete($args->{'data'});
    #die ::Dumper($args);

    my $array = $self->to_keypair($args->{'data'});
  
    my @cols;
    push(@cols,(
        'restriction',
        'guid',
        'assessment',
        'description',
        'confidence',
        'detecttime',
        'reporttime',
    ));

    my %c;
    foreach my $e (@$array){
        $c{'address'}   = 1 if($e->{'address'});
        $c{'hash'}      = 1 if($e->{'hash'});
        $c{'protocol'}  = 1 if($e->{'protocol'});
        $c{'portlist'}  = 1 if($e->{'portlist'});
        $c{'rdata'}     = 1 if($e->{'rdata'});
        $c{'asn'}       = 1 if($e->{'asn'});
        
        # this could be a performance killer
        # work-around for searches that don't have
        # an address associated with it and would confuse
        # output
        $c{'address'}   = 1 if($e->{'description'} =~ /search $addr_regex$/);
    }
    
    if($c{'address'}){
        push(@cols,'address');
    }
    if($c{'hash'} && !$c{'address'}){
        push(@cols,'hash');
    }
    if($c{'protocol'}){
        push(@cols,'protocol');
    }
    if($c{'portlist'}){
        push(@cols,'portlist');
    }
    if($c{'rdata'}){
        push(@cols,'rdata');
    }
    if($c{'asn'}){
        push(@cols,'asn');
    }
    ## TODO -- malware hash lookups?
    
    push(@cols,(
        'alternativeid_restriction',
        'alternativeid',
    ));
    

    my @header = map { $_, { is_sep => 1, title => '|' } } @cols;
    pop(@header);
    my $table = Text::Table->new(@header);
    
    foreach my $e (@$array){
        # work-around for hash searches that don't show the address
        # at some point we'll move this back up the stack to Format.pm
        unless($e->{'address'}){
            for($e->{'description'}){
                if(/search ($addr_regex)$/){
                    $e->{'address'} = $1;
                    last;
                }
            }
        } else {
            if($args->{'compress_address'} && length($e->{'address'}) > 32){
                $e->{'address'} = substr($e->{'address'},0,31);
                $e->{'address'} .= '...';
            }
        }
        ## TODO: do we need this?
        if($args->{'compress_address'} && length($e->{'description'}) > 32){
            $e->{'description'} = substr($e->{'description'},0,31);
            $e->{'description'} .= '...';
        }
        $table->load([ map { $e->{$_} } @cols]);
    }
    ## TODO -- what if RestrictionType in Iodef::Pb and FeedType get out of sync?
    my $restriction = $self->convert_restriction($args->{'restriction'}) || 'private';
    if($self->get_group_map && $self->get_group_map->{$args->{'guid'}}){
        $args->{'guid'} = $self->get_group_map->{$args->{'guid'}};
    }
    
    ## TODO - guid should be responded to by the router
    $args->{'uuid'} = '' unless($args->{'uuid'});
    $args->{'guid'} = '' unless($args->{'guid'});
    
    my $meta = "feed description:   $args->{'description'}
feed reporttime:    $args->{'reporttime'}
feed uuid:          $args->{'uuid'}
feed guid:          $args->{'guid'}
feed restriction:   $restriction
feed confidence:    $args->{'confidence'}\n\n";

    unless($args->{'table_nowarning'}){
        $meta = 'WARNING: Turn off this warning by adding: \'table_nowarning = 1\' to your ~/.cif config'."\n\n".$meta;
        $meta = 'WARNING: This table output not to be used for parsing, see "-p plugins" (via cif -h)'."\n".$meta;
    }
    $table = $meta . $table;
    return $table;
}

1;