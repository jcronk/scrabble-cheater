#!/usr/bin/env perl
use strict;
use warnings;
use autodie;
use File::Slurp;

my @wl = read_file( 'enable1.txt', chomp => 1 );
my $continue = 'n';
my $letters;
my $has_wildcard;
do {
    $letters = get_input("Enter letters\n") unless $continue =~ /y/i;
    # $has_wildcard = $letters =~ m/\*/;
    my $pattern = get_input("Enter pattern\n");
    my $length  = length $pattern;
    # my $re      = sub_pattern( $pattern, $letters );
    if ( my $result = get_words_( $length, $pattern, $letters, \@wl ) ) {

        # if ( my $result = get_words( $length, $re, \@wl ) ) {
        print "Your words:\n$result\n";
        # my @dups = remove_duplicate_letters( $result, $pattern );
        # print "Non-duplicated letter words: \n";
        # print join "\n", @dups;
        # print $/;
    }
    else {
        print "No words found.\n";
    }
    $continue = get_input("Continue with same letters?\n");
} while ( $continue =~ /y/i );

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
    my ( $length, $pattern, $letters, $wl ) = @_;
    my %own_letters = letters_hash($letters);
    my $regexp      = qr/^$pattern$/;
    my @list        = grep { /$regexp/ } @$wl;
    my @words;
    for (@list) {
        my @word_letters = split '', $_;
        my @letters_to_match = get_letters_to_match( $_, $pattern );
        my %pool = %own_letters;
        if ( match_word( \@letters_to_match, \%pool ) ) {
            push @words, $_;
        }
        else {
            next;
        }
    }
    return join "\n", @words if @words;
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

sub get_words {
    my ( $length, $regex, $wl ) = @_;
    my @out = grep { length($_) == $length } grep { /$regex/ } @wl;
    return join "\n", @out if @out;
    return 0;
}

sub remove_duplicate_letters {
    my ( $list, $pattern ) = @_;
    my $last_index = length($pattern) - 1;
    my @wildcardpos =
      grep { substr( $pattern, $_, 1 ) eq '.' } ( 0 .. $last_index );
    grep { !has_duplicates_at( \@wildcardpos, $_ ) } split /\n/, $list;
}

sub has_duplicates_at {
    my ( $positions, $word ) = @_;
    my %index;
    $index{ substr( $word, $_, 1 ) }++ for @$positions;
    return grep { $_ > 1 } values %index;
}

sub sub_pattern {
    my ( $pattern, $letters ) = @_;
    $pattern =~ s/\./[$letters]/g;
    return qr/^$pattern$/;
}
