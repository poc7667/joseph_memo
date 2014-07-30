require 'pry'
require 'pry-nav'
require 'pry-byebug'
require 'erb'
require 'erubis'
require 'awesome_print'
def get_users
  %w(a b c)
end
# tmpl = ERB.new im_file, nil, "%"
# p tmpl.result(binding)

def get_partial(file_name)
  ERB.new(File.new(file_name).read).result(binding)
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
  def initialize(articles, template_path)
    @articles = articles
    @template = File.open(template_path).read 
  end
  def render
    ERB.new(@template).result(binding)
  end
end
non_photos_articles =[
  {
    title: "who r you",
    content: "dildo"
    },
  {
    title: "who r you2",
    content: "dildo"
  }
]
video_articles =[
  {
    video_path: "http://123",
    title: "hdiqhd",
    content: "djifje"
  }
]

non_photos_partial = Partial.new(non_photos_articles, 'non_photos.erb')
videos_partial = Partial.new(video_articles, 'videos.erb')
puts videos_partial.render
# puts vv.render
binding.pry

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
