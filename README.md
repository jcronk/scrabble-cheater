# Scrabble Cheater

A simple Perl script for cheating at Scrabble, Words With Friends, or whatever.  The word list comes from [here](https://code.google.com/p/dotnetperls-controls/downloads/detail?name=enable1.txt&can=2&q=) among other places.  

This is on the command line, and it doesn't do anything fancy like calculating point totals.  The program follows a simple loop:

1. Enter the letters you have.  If you have a blank tile, enter it as \*.
2. Enter a pattern you want to match.  This can have lowercase letters and dots.  Dots are placeholders for your letters.  For instance, one pattern could be 't..l'
3. It returns a list of words matching the pattern.
4. You can start over without having to reenter your letters if you like, otherwise the program ends.

This is super simplistic and probably not very efficient.  There is no documentation other than this file.  I made this progressively over a couple of evenings playing Words with Friends with my wife, because I'm crappy at Scrabble.
