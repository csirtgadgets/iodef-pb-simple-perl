package Iodef::Pb::Simple::Plugin;

use strict;
use warnings;

sub process {}

sub normalize_timestamp {
    my $self = shift;
    my $dt = shift;
    return $dt if($dt =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/);
    if($dt && ref($dt) ne 'DateTime'){
        if($dt =~ /^\d+$/){
            if($dt =~ /^\d{8}$/){
                $dt.= 'T00:00:00Z';
                $dt = eval { DateTime::Format::DateParse->parse_datetime($dt) };
                unless($dt){
                    $dt = DateTime->from_epoch(epoch => time());
                }
            } else {
                $dt = DateTime->from_epoch(epoch => $dt);
            }
        } elsif($dt =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(\S+)?$/) {
            my ($year,$month,$day,$hour,$min,$sec,$tz) = ($1,$2,$3,$4,$5,$6,$7);
            $dt = DateTime::Format::DateParse->parse_datetime($year.'-'.$month.'-'.$day.' '.$hour.':'.$min.':'.$sec,$tz);
        } else {
            $dt =~ s/_/ /g;
            $dt = DateTime::Format::DateParse->parse_datetime($dt);
            return undef unless($dt);
        }
    }
    $dt = $dt->ymd().'T'.$dt->hms().'Z';
    return $dt;
}

sub restriction_normalize {
    my $self            = shift;
    my $restriction     = shift;
    
    return unless($restriction);
    return $restriction if($restriction =~ /^[1-4]$/);
    for(lc($restriction)){
        if(/^private$/){
            $restriction = RestrictionType::restriction_type_private(),
            last;
        }
        if(/^public$/){
            $restriction = RestrictionType::restriction_type_public(),
            last;
        }
        if(/^need-to-know$/){
            $restriction = RestrictionType::restriction_type_need_to_know(),
            last;
        }
        if(/^default$/){
            $restriction = RestrictionType::restriction_type_default(),
            last;
        }   
    }
    return $restriction;
}
    

1;