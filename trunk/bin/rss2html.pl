#!/usr/bin/perl -w
# rss2html - converts an RSS file to HTML
# It take one argument, either a file on the local system,
# or an HTTP URL like http://slashdot.org/slashdot.rdf
# by Jonathan Eisenzopf. v1.0 19990901
# Copyright (c) 1999 Jupitermedia Corp. All Rights Reserved.
# See http://www.webreference.com/perl for more information
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# INCLUDES
use strict;
use XML::RSS;
use LWP::Simple;
use HTML::Strip;
use DateTime::Format::Mail;
use File::Temp qw(tempfile);
use File::Copy qw(move);


# MAIN
# check for command-line argument
die "Usage: rss2html.pl (<RSS file> | <URL>) <output file>\n" unless @ARGV == 2;

# get the command-line argument
my ($input, $output) = @ARGV;

# create new instance of XML::RSS
my $rss = XML::RSS->new;

# argument is a URL
if ($input=~ /http:/i) {
    my $content = get($input) || die "Couldn't fetch $input\n";
    # parse the RSS content
    $rss->parse($content);

# argument is a file
} else {
    die qq[File "$input" does't exist.\n] unless -e $input;
    # parse the RSS file
    $rss->parsefile($input);
}

# print the HTML channel
print_html($rss, $output);

# SUBROUTINES
sub print_html {
    my ($rss, $output) = @_;

    my ($fh, $filename) = tempfile() or die "Couldn't make tmpfile: $!\n";
    
    print "FILENAME: $filename, output: $output\n";
    
    print $fh qq[<div class="rssfeed">\n];

    my $i =0;
    my $desc;
    my $title;
    my $hs = HTML::Strip->new();

    # print the channel items
    foreach my $item (@{$rss->{'items'}}[0 .. 15]) {
  	next unless defined($item->{'title'}) && defined($item->{'link'});
        $title = $item->{'title'};
  	$desc = substr($hs->parse($item->{'description'}),0, 100);
  	
  	# Wed, 03 Sep 2008 06:58
        my $date = DateTime::Format::Mail->parse_datetime($item->{pubDate})->strftime('%a, %d %b %Y %R');
        
        print $fh "<blockquote class=\"bluebox\">\n";
        print $fh qq[<h3>$date</h3>\n];
	print $fh qq[<h4>$title</h4>\n];
        print $fh qq{<p class="update">$desc</p>\n};
        print $fh "</blockquote>\n";
    }

    print $fh "</div>";

    close($fh) || die "Couldn't close $filename: $!\n";
    
    move($filename, $output);    
    
}






