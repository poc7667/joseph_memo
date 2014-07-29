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
Pry.config.editor = "vim"

def get_basename(f_path)
  Pathname.new(f_path).basename.to_s
end

def template(url)
  if url.include? 'js'
    "<script src=\"js/#{get_basename(url)}\" type=\"text/javascript\"></script>"
  elsif url.include? 'css'
    "<link href=\"css/#{get_basename(url)}\" media=\"all\" rel=\"stylesheet\" type=\"text/css\"></link>"
  end
end

class HttpDownloader
  def initialize(resource_type, url)
    FileUtils::mkdir_p resource_type
    download(url, resource_type)
  end
  def download(url, resource_type)
    Dir.chdir(resource_type)
    system("wget #{url} > /dev/null" ) unless File.file?(get_basename(url))
    Dir.chdir('../')
  end
end

class RemoteAssetsDownloader
  def initialize uri_path
    @page = Nokogiri::HTML(open(uri_path))
    @assets = {js: [], css: []}
    get_assets
    do_download
    ap(@assets)
  end

  def export_html
    tidy = Nokogiri::XSLT File.open('tidy.xsl')
    nice = tidy.transform(@page).to_html    
    File.open("new.html", "w") { |io| io.write(nice) }
  end
  
  def do_download
    f = open('html.txt', 'w')
    @assets.each do |resource_type, values|
      values.each do |url, template|
        HttpDownloader.new(resource_type.to_s, url)
        f.puts template
      end
    end
    f.close
  end

  def get_assets
    ['link','script'].each do |assets_type|
      @page.css(assets_type).each do |node|
        begin
          if assets_type=='link'
            url_path = node.attributes["href"].value 
            @assets[:css] << [url_path, template(url_path)] if url_path.include? ".css"
          elsif assets_type=='script'
            url_path = node.attributes["src"].value
            @assets[:js] << [url_path, template(url_path)] if url_path.include? ".js"
          end
        rescue Exception => e
        end
      end
    end
  end
end

dl = RemoteAssetsDownloader.new(ARGV[0])
