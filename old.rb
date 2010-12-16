#!/usr/bin/env ruby
require 'open-uri'
#require 'nokogiri'


class Dictionary
  attr_accessor :url

  def initialize(url)
    @url = url
  end

  def get_sound_file(word)
    full = get_full_url(word)
    open(full,
         "User-Agent" => " Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.3) Gecko/20100423 Ubuntu/10.04 (lucid) Firefox/3.6.3"
    ) do |f|
      line = nil
      f.each_line do |l|
        if l =~ /play_w2/
          line = l
          break
        end
      end
      md     = line.match /.+play_w2\("(.+)"\).+/
      mp3_url="http://img.tfd.com/hm/mp3/#{md[1]}.mp3"
      puts mp3_url
      f = "/tmp/#{md[1]}.mp3"
      open(mp3_url, 
           "User-Agent" => " Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.3) Gecko/20100423 Ubuntu/10.04 (lucid) Firefox/3.6.3") do |rf|
        require 'net/http'

        Net::HTTP.start("img.tfd.com") { |http|
          resp = http.get(mp3_url)
          open(f, "wb") { |file|
            file.write(resp.body)
          }
        }
      end
      system("sox --combine sequence #{f} #{f}.wav")
      system("play #{f}.wav")
      File.delete(f)
      File.delete("#{f}.wav")
    end
  end

  def get_full_url(word)
    # should be overridden by subclasses
  end

end

class TFD < Dictionary
  def initialize
    super("http://www.thefreedictionary.com")
  end

  def get_full_url(word)
    url+"/"+word
  end
end

tfd = TFD.new()
tfd.get_sound_file(ARGV[0])
