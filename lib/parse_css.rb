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
    @url_prefix = 'http://turbo.themezilla.com/memo/wp-content/themes/memo'
    open(css_fpath, 'r').each do |line|
      m = line.scan /(.*)(url\()(.*)(\))/
      if m.count > 0
        file = m[0][2]
        FileUtils::mkdir_p Pathname.new(file).dirname.to_s
        system("curl #{@url_prefix}/#{file} -o #{file}" )
      end
    end
  end
end

ParseCss.new(ARGV[0])