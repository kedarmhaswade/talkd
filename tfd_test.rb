#!/usr/bin/env ruby
require "test/unit"
require "stringio"
require_relative "tfd"

class TFDTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # tests a random word from dictionary

  def test_ds_list
    # tests a known file to see if I got nokogiri API right
    html_str = File.open("san.html").read
    reader = StringIO.new(html_str)
    tfd = TFD.new
    tfd.extract_text(reader).any?{|text| assert_match(/Africa/, text)}
  end
end