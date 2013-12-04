#!/usr/bin/env perl
use strict;
use warnings;
use autodie;
use File::Slurp;

my @wl       = read_file( 'enable1.txt', chomp => 1 );
my %wlc      = cache_words_by_length( \@wl );
my $continue = 'n';
my $letters;
do {
    $letters = get_input("Enter letters\n") unless $continue =~ /y/i;
    my $pattern = get_input("Enter pattern\n");
    my $length  = length $pattern;
    if ( my $result = get_words_( $length, $pattern, $letters, \%wlc ) ) {
        print "Your words:\n$result\n";
    }
    else {
        print "No words found.\n";
    }
    $continue = get_input("Continue with same letters?\n");
} while ( $continue =~ /^y/i );

sub cache_words_by_length {
    my $wl = shift;
    my %by_length;
    push @{ $by_length{ $_->[1] } }, $_->[0]
      for sort { $a->[1] <=> $b->[1] } map { [ $_, length $_ ] } @$wl;
    return %by_length;
}

sub get_input {
    my $message = shift;
    print $message;
    chomp( my $resp = <STDIN> );
    $resp;
}

sub letters_hash {
    my $letters = shift;
    my @characters = split '', $letters;
    my %hash;
    $hash{$_}++ for @characters;
    return %hash;
}

sub get_letters_to_match {
    my ( $word, $pattern ) = @_;
    my @letters = split '', $pattern;
    my @match_letters;
    my $last_index = length($pattern) - 1;
    for ( 0 .. $last_index ) {
        push @match_letters, substr( $word, $_, 1 ) if $letters[$_] eq '.';
    }
    @match_letters;
}

sub get_words_ {
    my ( $length, $pattern, $letters, $wlc ) = @_;
    my %own_letters = letters_hash($letters);
    my %words;
    my ( $front, $back ) = ( 1, 2 );
    for ( 1 .. 2 ) {
        my $pattern_copy = $pattern;
        while ($pattern_copy =~ /[a-z]/) {
            my $regexp = qr/^$pattern_copy$/;
            my @list = grep { /$regexp/ } @{ $$wlc{ length $pattern_copy } };
            for (@list) {
                my @word_letters = split '', $_;
                my @letters_to_match =
                  get_letters_to_match( $_, $pattern_copy );
                my %pool = %own_letters;
                if ( match_word( \@letters_to_match, \%pool ) ) {
                    $words{$_}++;
                }
                else {
                    next;
                }
            }
            $pattern_copy = substr( $pattern_copy, 1 )
              if $_ == $front && $pattern_copy =~ /[a-z]/;
            $pattern_copy = substr( $pattern_copy, 0, -2 )
              if $_ == $back && $pattern_copy =~ /[a-z]/;
        }
    }
    return join "\n", keys %words if %words;
    return 0;
}

sub match_word {
    my ( $letters_to_match, $pool ) = @_;
    for (@$letters_to_match) {
        if ( my $matched = matches( $_, $pool ) ) {
            consume( $matched, $pool );
        }
        else {
            return 0;
        }
    }
    return 1;
}

sub matches {
    my ( $letter, $hash ) = @_;
    return $letter if exists $$hash{$letter} && $$hash{$letter} > 0;
    return '*' if exists $$hash{'*'} && $$hash{'*'} > 0;
    return 0;
}

sub consume {
    my ( $letter, $hash ) = @_;
    $$hash{$letter}--;
}
