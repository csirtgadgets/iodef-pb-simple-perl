package Iodef::Pb::Simple::Plugin::Restriction;
use base 'Iodef::Pb::Simple::Plugin';

use strict;
use warnings;

sub process {
    my $self = shift;
    my $data = shift;
    my $iodef = shift;
    
    my $restriction = $data->{'restriction'} || 'private';
    
    unless(ref($restriction) eq 'RestrictionType'){
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
    }    
    my $incident = @{$iodef->get_Incident()}[0];  
    $incident->set_restriction($restriction);
}

1;
