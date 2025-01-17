#!/usr/bin/perl
use utf8;
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use Unicode::Normalize 'NFC';
use List::Util 'shuffle';
use common;

use open qw(:std :utf8);

# Seems to be exponential time for mf_train step of the process so keep this reasonably small
my $MAX = 40;

# Print out up to X of the most common words for a given letter or combo, given a set of input text

my %chars;
while(<>) {
    chomp;
    $_ = NFC $_;
    for my $w (split /[\s.,:]+/, $_ ) {
        next if !common::is_allowed($w);
        my @chars = split //, $w;

        # Add more words in that tesseract gets commonly confused about
        my %extra = map { $_ => 1 } $w =~ /(ın|ımız|nın)/g;
        #if( %extra ) {
        #    print "$w: ", join ',', keys %extra, "\n";
        #}

        for my $c (@chars, keys %extra) {
            next if $c =~ /\s/;
            $chars{$c}{count}++;
            $chars{$c}{words}{$w}++
        }
    }
}
#print map { "$_\n" } sort keys %chars;
#exit;
#use Data::Dumper;
#print Dumper \%chars;
my @words;

while( my ($c, $d) = each %chars ) {
    my $w = $d->{words};
    my @order = sort { $w->{$b} <=> $w->{$a} } keys %$w;
    @order = @order[0 .. $MAX] if @order > $MAX;
    push @words, @order;
}

my @app = (',', ':', '.', ('') x 200);  # Add back in stuff we lost in the split with appropriate proabilities
@words = map { $_ . $app[rand @app] } @words;
my %words = map { $_ => 1 } @words;     # uniq
@words = shuffle keys %words;

# as per https://groups.google.com/forum/#!topic/tesseract-dev/32czn-wcA-I need blank line first
print "\n";
while( @words ) {
    my $line = join " ", splice @words, 0, 200;
    print "$line\n";
}
#\U@words \L@words\n";
