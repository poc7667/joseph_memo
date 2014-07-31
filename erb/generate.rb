require 'pry'
require 'pry-nav'
require 'pry-byebug'
require 'erb'
require 'erubis'
require 'awesome_print'
require 'pathname'
require './assets.rb'

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
    case user[:imgs].count 
    when 0
      articles[:no_photo] << user.clone
    when 1
      articles[:single_photo] << user.clone
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
group_articles_type(Assets.new.load).each do |group|
  next if group.last.count == 0
  article_type = group.first.to_s
  @partials << Partial.new("#{article_type}.erb", group.last)
end

index = Partial.new("index.erb", @partials)
File.open('../index.html', 'wb+') do |f|
  f.write(index.render)
end

# partials = %w(videos.erb non_photos.erb sigle_photo.erb)
# partials.each do |file_name|
#   p file_name
#   p3=get_partial(file_name)
#   binding.pry
# end

# im_file = File.open('index.erb')
# im_tmpl = im_file.read
# memo = MemoList.new(get_users, im_tmpl)
# binding.pry
