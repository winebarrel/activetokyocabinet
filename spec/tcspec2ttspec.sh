#!/bin/sh
cat tokyocabinet_spec.rb | sed -r 's/\bTokyoCabinet/ TokyoTyrant/g' | sed -r 's/tokyocabinet/tokyotyrant/' > tokyotyrant_spec.rb
