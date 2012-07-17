cryptoquote
===========

A dictionary-based algorithm to crack the Cryptoquote puzzles found on the funnies page of most daily newspapers.

Implemented in Chicken Scheme.

This algorithm works by mapping the crypted words into patterns of repeated letters (ie. "linux" => "abcde" and "food" => "abbc") and doing a dictionary look-up of other words that will fit that pattern.  When a matching word is found occurrences of those letters are replaced in the other words and a new word's pattern is looked up, etc. until either a solution or a dead end is found.

The running time of my algorithm is going to be influenced by the quality of the dictionary the patterns are generated from.  I realize that /usr/share/dict/words is not going to be a very good resource because it's full of unlikely words, and doesn't contain any contractions.  A dictionary that's sorted in order of the words' frequency in prose will also be a great aid to the algorithm.

Here are a few resources of such word lists:

http://www.insightin.com/esl/

http://ucrel.lancs.ac.uk/bncfreq/flists.html

http://imonad.com/seo/wikipedia-word-frequency-list/

http://www.puzzlers.org/dokuwiki/doku.php?id=solving:crypts

http://www.wordfrequency.info/ - has a free 5,000 word list that is based upon the "Corpus of Contemporary American English"
