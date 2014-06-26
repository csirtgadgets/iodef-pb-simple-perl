package Iodef::Pb::Format::Json;
use base 'Iodef::Pb::Format';

# This module does not output valid json blobs. The reason
# is machines were exhausing all the memory loading the json blob
# into memory during blob creation. As a work-around the feed is
# line-delimited  (split(\n)) where you can stream through the 
# blobs and manipulate them (or suck them in) individually.

use strict;
use warnings;

require JSON::XS;

sub write_out {
    my $self = shift;
    my $args = shift;

    my $array = $self->to_keypair($args);
    my @json_stream;
    push(@json_stream,JSON::XS::encode_json($_)) foreach(@$array);
    my $text = join("\n",@json_stream);
    return $text;
}
1;
