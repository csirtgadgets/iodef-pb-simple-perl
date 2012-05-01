#!/usr/bin/perl -w

use strict;

use lib './lib';
use lib '../iodef-pb-perl/lib';
use Data::Dumper;
use Iodef::Pb::Simple;

my $x = Iodef::Pb::Simple->new({
    contact => 'Wes Young',
    id      => '1234',
    address => '1.1.1.1',
    prefix  => '1.1.1.0/24',
    asn     => 'AS1234',
    cc      => 'US',
    assessment  => 'botnet',
    confidence  => '50',
    restriction     => 'private',
});

my $str = $x->encode();
warn Dumper($x);
warn Dumper(IODEFDocumentType->decode($str));