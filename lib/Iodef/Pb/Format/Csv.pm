package Iodef::Pb::Format::Csv;
use base 'Iodef::Pb::Format';

use strict;
use warnings;

sub write_out {
    my $self = shift;
    my $args = shift;
    
    my $config = $args->{'config'};
    my $feed = $args->{'data'};
    
    my $array = $self->SUPER::to_keypair($args->{'data'});
    
    $config = $config->{'config'};
    my $nosep = $config->{'csv_noseperator'};
    my @header = keys(%{@{$array}[0]});

    @header = sort { $a cmp $b } @header;
    my $body = '';
    foreach my $a (@$array){
        delete($a->{'message'}); 
        # there's no clean way to do this just yet
        foreach (@header){
            if($a->{$_} && !ref($a->{$_})){
                # deal with , in the field
                if($nosep){
                    $a->{$_} =~ s/,/ /g;
                    $a->{$_} =~ s/\s+/ /g;
                } else {
                    $a->{$_} =~ s/,/_/g;
                }
                # strip out non-ascii (typically unicode) chars
                # there are better ways to do this, but this works for now
                $a->{$_} =~ tr/\000-\177//cd;
            }
        }
        # the !ref() bits skip things like arrays and hashref's for now...
        $body .= join(',', map { ($a->{$_} && !ref($a->{$_})) ? $a->{$_} : ''} @header)."\n";
    }
    my $text = '# '.join(',',@header);
    $text .= "\n".$body;

    return $text;
}
1;
