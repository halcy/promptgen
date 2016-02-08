#!/usr/bin/perl

use warnings;
use strict;
use List::Util qw(shuffle);
use CGI;
use URI::Escape;

my $query = new CGI;
if(!$query->param('seed')) {
	print $query->redirect('?seed=' . int(time() * rand()));
}
else {
	my $seed = int($query->param('seed'));
	srand($seed);

	my $char_file = "characters.txt";
	my $prompts_file = "prompts.txt";
	my $template_file = "template.txt";
	
	open my $handle, '<', $char_file;
	chomp(my @chars = <$handle>);
	map {$_ =~ s/^\s+|\s+$//g} @chars;
	my @shuffled_chars = shuffle(@chars);
	close $handle;
	
	open $handle, '<', $prompts_file;
	chomp(my @prompts = <$handle>);
	map {$_ =~ s/^\s+|\s+$//g} @prompts;
	my @shuffled_prompts = shuffle(@prompts);
	close $handle;
	
	open $handle, '<', $template_file;
	chomp(my @template = <$handle>);
	map {$_ =~ s/^\s+|\s+$//g} @template;
	close $handle;
	
	my $char1 = $shuffled_chars[0];
	my $char2 = $shuffled_chars[1];
	my $char3 = $shuffled_chars[2];
	my $char4 = $shuffled_chars[3];
	my $char5 = $shuffled_chars[4];

	my $img1 = "charicons/" . lc($char1) . ".png";
	my $img2 = "charicons/" . lc($char2) . ".png";
	my $img3 = "charicons/" . lc($char3) . ".png";
	my $img4 = "charicons/" . lc($char4) . ".png";
	my $img5 = "charicons/" . lc($char5) . ".png";

	my $prompt = $shuffled_prompts[0];

	my %qualifiers = {};
        if($prompt =~ /CHAR1/) {
                $qualifiers{"CHAR1"} = 1;
        }
	
	if($prompt =~ /CHAR2/) {
                $qualifiers{"CHAR2"} = 1;
        }

	if($prompt =~ /CHAR3/) {
                $qualifiers{"CHAR3"} = 1;
        }

	if($prompt =~ /CHAR4/) {
                $qualifiers{"CHAR4"} = 1;
        }

	 if($prompt =~ /CHAR5/) {
                $qualifiers{"CHAR5"} = 1;
        }

	$prompt =~ s/CHAR1/$char1/g;
	$prompt =~ s/CHAR2/$char2/g;
	$prompt =~ s/CHAR3/$char3/g;
	$prompt =~ s/CHAR4/$char4/g;
	$prompt =~ s/CHAR5/$char5/g;
	my $prompt_tweet = $prompt;
	$prompt = "$prompt.";
	
	if(length($prompt_tweet) > 97) {
		my $pos = rindex($prompt_tweet, " ", 97);
	        $prompt_tweet = substr($prompt_tweet, 0, $pos);	
		$prompt_tweet = $prompt_tweet . " [...]";
	}

	my $tweettext = $prompt_tweet . ' ' . "http://sb69prompt.halcy.de/?seed=" . $seed . " #sb69prompt";
	$tweettext = uri_escape($tweettext);

	print "Content-type: text/html\n\n";
	for my $template_line (@template) {
		my ($qualifier, $template_line_proper) = ($template_line =~ /^([A-Z0-9]+)\: (.*)$/);
		if(defined $qualifier) {
			$template_line = $template_line_proper;
			if(!defined $qualifiers{$qualifier}) {
				next;
			}
		}
		
		$template_line =~ s/PROMPT/$prompt/g;
	        $template_line =~ s/ICON1/$img1/g;
        	$template_line =~ s/ICON2/$img2/g;
		$template_line =~ s/ICON3/$img3/g;
		$template_line =~ s/ICON4/$img4/g;
		$template_line =~ s/ICON5/$img5/g;
		$template_line =~ s/TWEET/$tweettext/g;
		print "$template_line\n";
	}
}
