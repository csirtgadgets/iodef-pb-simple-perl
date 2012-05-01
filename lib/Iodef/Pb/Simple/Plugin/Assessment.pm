package Iodef::Pb::Simple::Plugin::Assessment;
use base 'Iodef::Pb::Simple::Plugin';

use strict;
use warnings;

sub process {
    my $self = shift;
    my $data = shift;
    my $iodef = shift;
    
    return unless($data->{'assessment'} || $data->{'Assessment'});
    
    my $assessment  = $data->{'Assessment'} || $data->{'assessment'};
    my $severity    = $data->{'severity'};
    my $confidence  = $data->{'confidence'} || '';
    
    # assume if it's an ARRAY, we're passing an array of AssessmentType's
    unless(ref($assessment) eq 'AssessmentType' || ref($assessment) eq 'ARRAY'){
        unless(ref($severity) eq 'severity_type'){
            $severity = SeverityType::severity_type_low();
            for(lc($severity)){
                if(/^high$/){
                    $severity = SeverityType::severity_type_high(),
                    last;
                }
                if(/^medium$/){
                    $severity = SeverityType::severity_type_medium(),
                    last;
                }
            }
        }
    
        my $impact = ImpactType->new({
            lang        => $data->{'lang'},
            content     => MLStringType->new({
                lang    => $data->{'lang'},
                content => $assessment,
            }),
            severity    => $severity,
        });

        my $rating; 
        unless(ref($confidence) eq 'ConfidenceType'){
            for($confidence){
                if(/^\d+/){
                    $rating = ConfidenceType::ConfidenceRating::Confidence_rating_numeric();
                    last;
                }
            
                $confidence = '';
                if(/^high$/){
                    $rating = ConfidenceType::ConfidenceRating::Confidence_rating_high();
                    last;
                }
                if(/^medium$/){
                    $rating = ConfidenceType::ConfidenceRating::Confidence_rating_medium();
                    last;
                }
                if(/^low$/){
                    $rating = ConfidenceType::ConfidenceRating::Confidence_rating_low();
                    last;
                }
            }
            $confidence = ConfidenceType->new({
                rating  => $rating,
                content => $confidence,
            });
        }
    
        $assessment = AssessmentType->new({
            Impact      => [$impact],
            Confidence  => $confidence,
        });
    }
    
    my $incident = @{$iodef->get_Incident()}[0];
    push(@{$incident->{'Assessment'}},$assessment);
}

1;
