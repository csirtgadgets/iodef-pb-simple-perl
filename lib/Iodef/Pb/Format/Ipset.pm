package Iodef::Pb::Format::Ipset;
use base 'Iodef::Pb::Format';

use strict;
use warnings;

use Regexp::Common qw/net/;

sub write_out {
    my $self    = shift;
    my $args    = shift;
    
    my $config  = $args->{'config'};
    my $array   = $self->SUPER::to_keypair($args);
    
    return '' unless(exists(@{$array}[0]->{'address'}));
    
    my $text = '';

    ### Create the iptables chains for whitelisting and blacklisting
    $text .= "\# Create the iptables chains, if necessary\n";
    $text .= "if [ \`iptables-save | grep -c \":in_blocked_cif\"\` -eq 0 ]; then\n";
    $text .= "    iptables -N in_blocked_cif\n";
    $text .= "fi\n\n";
    $text .= "if [ \`iptables-save | grep -c \":out_blocked_cif\"\` -eq 0 ]; then\n";
    $text .= "    iptables -N out_blocked_cif\n";
    $text .= "fi\n\n";
    $text .= "\# Create the iptables chains, if necessary\n";
    $text .= "if [ \`iptables-save | grep -c \":in_whitelist_cif\"\` -eq 0 ]; then\n";
    $text .= "    iptables -N in_whitelist_cif\n";
    $text .= "fi\n\n";
    $text .= "if [ \`iptables-save | grep -c \":out_whitelist_cif\"\` -eq 0 ]; then\n";
    $text .= "    iptables -N out_whitelist_cif\n";
    $text .= "fi\n\n";

    ### Match sure we're in the INPUT and OUTPUT chains
    $text .= "\# Ensure that we are in the INPUT and OUTPUT chains\n";
    $text .= "if [ \`iptables -L INPUT | head -3 | grep -c in_blocked_cif\` -eq 0 ]; then\n";
    $text .= "    iptables -I INPUT 1 -j in_blocked_cif\n";
    $text .= "fi\n\n";
    $text .= "if [ \`iptables -L INPUT | grep -c in_whitelist_cif\` -eq 0 ]; then\n";
    $text .= "    iptables -A INPUT -j in_whitelist_cif\n";
    $text .= "fi\n\n";
    $text .= "if [ \`iptables -L OUTPUT | head -3 | grep -c out_blocked_cif\` -eq 0 ]; then\n";
    $text .= "    iptables -I OUTPUT 1 -j out_blocked_cif\n";
    $text .= "fi\n\n";
    $text .= "if [ \`iptables -L OUTPUT | head -4 | grep -c out_blocked_cif\` -eq 0 ]; then\n";
    $text .= "    iptables -I OUTPUT 2 -j out_whitelist_cif\n";
    $text .= "fi\n\n";

    ### Set up the blacklist set
    $text .= "\# Create the ipset, if necessary\n";
    $text .= "if [ \`ipset list -name | grep -c CIF_BL_IPSET\` -eq 0 ]; then\n";
    $text .= "    ipset create CIF_BL_IPSET hash:net hashsize " . scalar(@$array) . " maxelem " . scalar(@$array) * 2 . "\n";
    $text .= "fi\n\n";

    ### Add the iptables rules to reference the ipset
    $text .= "\# Reference the ipset in the ip chain, if necessary\n";
    $text .= "if [ \`iptables-save | grep -c -- \"-A in_blocked_cif -m set --match-set CIF_BL_IPSET\"\` -eq 0 ]; then\n";
    $text .= "    iptables -A in_blocked_cif -m set --match-set CIF_BL_IPSET src -j LOG --log-prefix \"CIF_BL_IPSET : \"\n";
    $text .= "    iptables -A in_blocked_cif -m set --match-set CIF_BL_IPSET src -j DROP\n";
    $text .= "fi\n\n";
    $text .= "if [ \`iptables-save | grep -c -- \"-A out_blocked_cif -m set --match-set CIF_BL_IPSET\"\` -eq 0 ]; then\n";
    $text .= "    iptables -A out_blocked_cif -m set --match-set CIF_BL_IPSET dst -j LOG --log-prefix \"CIF_BL_IPSET : \" --log-uid\n";
    $text .= "    iptables -A out_blocked_cif -m set --match-set CIF_BL_IPSET dst -j DROP\n";
    $text .= "fi\n\n";

    ### Set up the whitelist set
    $text .= "\# Create the ipset, if necessary\n";
    $text .= "if [ \`ipset list -name | grep -c CIF_WL_IPSET\` -eq 0 ]; then\n";
    $text .= "    ipset create CIF_WL_IPSET hash:net hashsize " . scalar(@$array) . " maxelem " . scalar(@$array) * 2 . "\n";
    $text .= "fi\n\n";

    ### Add the iptables whitelist rules to reference the ipset
    $text .= "\# Reference the ipset in the ip chain, if necessary\n";
    $text .= "if [ \`iptables-save | grep -c -- \"-A in_whitelist_cif -m set --match-set CIF_WL_IPSET\"\` -eq 0 ]; then\n";
    $text .= "    iptables -A in_whitelist_cif -m set --match-set CIF_WL_IPSET src -j LOG --log-prefix \"CIF_WL_IPSET : \"\n";
    $text .= "    iptables -A in_whitelist_cif -m set --match-set CIF_WL_IPSET src -j RETURN\n";
    $text .= "fi\n\n";
    $text .= "if [ \`iptables-save | grep -c -- \"-A out_whitelist_cif -m set --match-set CIF_WL_IPSET\"\` -eq 0 ]; then\n";
    $text .= "    iptables -A out_whitelist_cif -m set --match-set CIF_WL_IPSET dst -j LOG --log-prefix \"CIF_WL_IPSET : \" --log-uid\n";
    $text .= "    iptables -A out_whitelist_cif -m set --match-set CIF_WL_IPSET dst -j RETURN\n";
    $text .= "fi\n\n";

    ### Create the temporary ipset
    $text .= "ipset create CIF_BL_TMP hash:ip hashsize " . scalar(@$array) . " maxelem " . scalar(@$array) * 2 . "\n";
    $text .= "ipset create CIF_WL_TMP hash:ip hashsize " . scalar(@$array) . " maxelem " . scalar(@$array) * 2 . "\n";

    my $isWhitelist = 0;

    foreach (@$array){
        my $address = $_->{'address'};
        unless($_->{'address'} =~ /^$RE{'net'}{'IPv4'}/){
            warn 'WARNING: Currently this plugin only supports IPv4 addresses'."\n";
            return '';
        }
        $_->{'address'} = normalize_address($_->{'address'});
        if($_->{'assessment'} eq 'whitelist'){
            $isWhitelist = 1;
            $text .= "ipset add CIF_WL_TMP $_->{'address'} -exist\n";
        } else {
            $text .= "ipset add CIF_BL_TMP $_->{'address'} -exist\n";
        }
    }

    ### Swap the new ipset and the old ipset
    $text .= "ipset swap CIF_BL_TMP CIF_BL_IPSET\n";
    $text .= "ipset swap CIF_WL_TMP CIF_WL_IPSET\n";

    ### Get rid of the old ipset
    $text .= "ipset destroy CIF_BL_TMP\n";
    $text .= "ipset destroy CIF_WL_TMP\n";
    return $text;
}

sub normalize_address {
    my $addr = shift;

    my @bits = split(/\./,$addr);
    foreach(@bits){
        next unless(/^0{1,2}[1-9]{1,2}/);
        $_ =~ s/^0{1,2}//;
    }
    return join('.',@bits);
}
1;
