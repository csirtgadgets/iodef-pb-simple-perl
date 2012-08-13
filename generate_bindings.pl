#!/usr/bin/perl -w

use strict;
use Google::ProtocolBuffers;

my $f = './protocol/defs/iodef.proto';
Google::ProtocolBuffers->parsefile($f,
    {
        generate_code => 'lib/Iodef/Pb.pm',
        create_accessors    => 1,
        follow_best_practice => 1,
    }
);

open(F,'lib/Iodef/Pb.pm') || die($!);;
my @lines = <F>;
close(F);
open(F,'>','lib/Iodef/Pb.pm');
no warnings;
print F "package Iodef::Pb;\n";
foreach (@lines){
    print F $_;
}
close(F);

