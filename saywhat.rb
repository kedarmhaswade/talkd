#!/usr/bin/env ruby
#
require_relative 'tfd'

tfd = TFD.new
if ARGV[0]
  word=ARGV[0].dup
else
  puts "What to look up and pronounce?"
  word = gets.chomp
end
begin
  tfd.lookup(word).each { |m| puts m }
  tfd.talk(word)
rescue
  puts(STDERR, "got an exception: #{$!}")
ensure
  tfd.cleanup(word)
end
