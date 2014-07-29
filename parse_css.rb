require 'rubygems'
require 'nokogiri'
require 'restclient'
require 'open-uri'
require 'awesome_print'
require 'pry'
require 'pry-nav'
require 'pathname'
require 'net/http'
require 'fileutils'

class ParseCss
  def initialize(css_fpath)
    open(css_fpath, 'r').each do |line|
      m = line.scan /(.*)(url\()(.*)(\))/
      if m.count > 0
        file = m[0][2]
        FileUtils::mkdir_p Pathname.new(file).dirname.to_s
      end
    end
  end
end

ParseCss.new(ARGV[0])