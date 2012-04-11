#!/usr/bin/perl -w

use strict;

use lib './lib';
use Data::Dumper;
use Iodef::Pb::Simple;
use ZeroMQ qw(:all);

my $context = ZeroMQ::Context->new();

my $client = $context->socket(ZMQ_REQ);
$client->connect('ipc://test');
    
my $x = Iodef::Pb::Simple->new({
    contact => 'Wes Young',
    #address => 'example.com',
    #rdata   => '1.2.3.4',
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