#!/usr/bin/env ruby
require "open-uri"
require "nokogiri"
require "erb"
require_relative "dictionary"
require "logger"

class TFD < Dictionary

  BASE_URL = "http://www.thefreedictionary.com"

  def initialize
    @dictionary = Hash.new
    @logger     = Logger.new(STDOUT)
  end

  def lookup(word)
    word.gsub!(/\s/, "+")
    meaning_file = initialize_files(word)[0]
    f = File.open(meaning_file)
    begin
      extract_text(f)
    rescue Exception
      raise
    end

  end

  def extract_text(f)
    doc = Nokogiri::HTML(f)
    nodes = doc.xpath("//div[@class='ds-list']") + doc.xpath("//div[@class='ds-single']")
    texts = []
    nodes.each {|node| texts << node.inner_text}
    texts
  end

  def talk(word)
    word.gsub!(/\s/, "+")
    sound_file = initialize_files(word)[1]
    #system("sox --combine sequence #{sound_file} #{sound_file}.wav")
    system("play #{sound_file}")
  end

  def cleanup(word)
    word_files = @dictionary[word]
    if (word_files)
      word_files.each { |name| File.delete name }
    end
    @logger.close
  end

  private

  def initialize_files(word)
    word_files = @dictionary[word] #an array of two elements
    unless word_files
      word_files=[]
      download_files(word, word_files)
      @dictionary[word] = word_files
    end
    word_files
  end

  def write_file(file, url)
    headers = {"User-Agent" => "Mozilla/5.0"}
    res = nil
    open(url, headers) do |f|
      res = f.read
    end
    file.write(res) if res
    res
  end

  # can be refactored
  def download_files(word, files)
    url   = URI.parse(BASE_URL + "/" + word)
    name  = "/tmp/" + word + ".html"
    file  = File.open(name, "w") #overwrite
    begin
      write_file(file, url)
      files << name
      file.close
    rescue Exception
      @logger.fatal("Got an error: #{$!}, wrong spelling?") #squelch
      raise
    end
    file    = File.open(name, "r") # now reopen to read only
    mp3_url = nil
    file.each_line do |line|
      md = line.match(/.+play_w2\("(.+)"\).+/)
      if (md)
        mp3_url="http://img.tfd.com/hm/mp3/#{md[1]}.mp3"
        break
      end
    end
    if mp3_url
      mp3_name = "/tmp/" + word + ".mp3"
      mp3      = File.open(mp3_name, "wb") #overwrite
      begin
        write_file(mp3, mp3_url)
        files << mp3_name
        mp3.close
      rescue
        @logger.fatal("Sound file could not be downloaded") #squelch
        raise
      end
    else
      @logger.fatal("expected mp3_url (http://img.tfd.com/hm/mp3/<file>.mp3) not found in the page for word: #{word}, giving up")
      raise
    end
  end

end
