require 'pry'
require 'pry-nav'
require 'pry-byebug'
require 'erb'
require 'erubis'
require 'awesome_print'
require 'pathname'

class Assets
  attr_accessor :result
  def initialize
    @root_path = Pathname.new(File.expand_path('..', File.dirname(__FILE__)))
    self.result = []
  end

  def get_images(user_folder, user)
    Dir["#{user_folder}/images/*"].each do |img|
      user[:imgs] <<  Pathname.new(img).relative_path_from(@root_path).to_s
    end        
  end

  def get_article(user_folder, user)
    File.open(Dir["#{user_folder}/*txt"].first).each_with_index do |line, i|
      if 0==i
        user[:title] = line.rstrip
      else
        user[:content] << line.rstrip
      end
    end    
  end

  def load
    assets_folder = File.expand_path('../users', File.dirname(__FILE__))
    Dir["#{assets_folder}/*"].each do | user_folder |
      user = {name:'',imgs:[], title: '', content: []}      
      get_images(user_folder, user)
      get_article(user_folder, user)
      user[:name] = user_folder.split('/').last
      self.result << user.clone
    end
    result
  end
end

