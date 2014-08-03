# encoding: utf-8
Encoding.default_external = "UTF-8"
require 'pry'
require 'pry-nav'
require 'pry-byebug'
require 'erb'
require 'erubis'
require 'awesome_print'
require 'pathname'
helper_file = File.expand_path('user_assets.rb', File.dirname(__FILE__))
require helper_file

@articles = {}
def get_partial(file_name)
  ERB.new(File.new(file_name).read).result(binding)
end

def group_articles_type(assets)
  articles = {
    no_photo: [],
    single_photo: [],
    multi_photos: []
  }
  assets.each do |user|
    case (user[:imgs].count+user[:videos].count)
    when 0
      articles[:no_photo] << user.clone
    else
      articles[:multi_photos] << user.clone
    end
  end
  articles
end

class MemoList
  include ERB::Util
  attr_accessor :users, :template, :date

  def initialize(users, template)
    @users = users
    @template = template
  end

  def render()
    ERB.new(@template).result(binding)
  end

  def save(file)
    File.open(file, "w+") do |f|
      f.write(render)
    end
  end
end

class Partial
  include ERB::Util
  def initialize(template_path, articles=[])
    @articles = articles
    @template = File.open(template_path).read 
  end
  def render
    ERB.new(@template).result(binding)
  end
end

@partials=[]
group_articles_type(UserAssets.new.load).each do |group|
  next if group.last.count == 0
  article_type = group.first.to_s
  @partials << Partial.new("#{article_type}.erb", group.last)
end

index = Partial.new("index.erb", @partials.shuffle)
output_file = File.expand_path('../index.html', File.dirname(__FILE__))
File.open(output_file.to_s, 'wb+') do |f|
  f.write(index.render)
end