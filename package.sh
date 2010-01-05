#!/bin/sh
VERSION=0.1.0

rm *.gem *.tar.bz2
rm -rf doc
rdoc  -w 4 -SHN -m README README --title 'ActiveTokyoCabinet - a library for using TokyoCabinet under ActiveRecord.'
tar jcvf activetokyocabinet-${VERSION}.tar.bz2 --exclude=.svn lib README *.gemspec doc
gem build activetokyocabinet.gemspec