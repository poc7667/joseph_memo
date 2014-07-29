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
  raw_fpath = Pathname.new(f_path).basename.to_s
  m = raw_fpath.scan(/(.*)(\?)/)
  if m.count >0
    return m[0][0]
  else
    return raw_fpath
  end
end

def get_asset_fpath(url)
  if url.include? '.js'
    "js/#{get_basename(url)}" 
  elsif url.include? '.css'
    "css/#{get_basename(url)}"      
  end
end


class HttpDownloader
  def initialize(resource_type, url)
    FileUtils::mkdir_p resource_type
    download(url, resource_type)    
  end
  def download(url, resource_type)
    Dir.chdir(resource_type)
    system("curl #{url} -o #{get_basename(url)}" ) unless File.file?(get_basename(url))
    Dir.chdir('../')
  end
end

class RemoteAssetsDownloader
  def initialize uri_path
    @page = Nokogiri::HTML(open(uri_path))
    @assets = {js: [], css: []}
    get_assets
    do_download
    export_html
  end

  def export_html
    tidy = Nokogiri::XSLT File.open('tidy.xsl')
    nice = tidy.transform(@page).to_html    
    File.open("new.html", "w") { |io| io.write(nice) }
  end
  
  def do_download
    @assets.each do |resource_type, values|
      values.each do |url, template|
        HttpDownloader.new(resource_type.to_s, url)
      end
    end
  end

  def get_assets
    [['link', 'href', 'css'],['script', 'src', 'js']].each do |assets_type, node_attr, ext_name|
      @page.css(assets_type).each do |node|
        begin
          url_path = node.attributes[node_attr].value          
          if url_path.include? ".#{ext_name}" and url_path.include? "http" # if url contains .css or .js
            @assets[ext_name.to_sym] << [url_path]             
            if get_asset_fpath(url_path)
              node.attributes[node_attr].value = get_asset_fpath(url_path).strip
              ap(node.attributes[node_attr])
            else
              binding.pry
            end
          end
        rescue Exception => e
          p node.attributes[node_attr]
          p e
        end
      end
    end
  end # end get_assets
end

dl = RemoteAssetsDownloader.new(ARGV[0])
