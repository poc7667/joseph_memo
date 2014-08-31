# encoding: utf-8
require 'pry'
require 'pry-nav'
require 'pry-byebug'
require 'erb'
require 'erubis'
require 'awesome_print'
require 'pathname'


class UserAssets
  attr_accessor :result
  def initialize
    @root_path = Pathname.new(File.expand_path('..', File.dirname(__FILE__)))
    @name_tag="name:"
    self.result = []
  end

  def get_images(user_folder, user)
    Dir["#{user_folder}/**/*"].each do |img|
      if img =~ /.*(jpg|png|gif)$/
        user[:imgs] <<  Pathname.new(img).relative_path_from(@root_path).to_s
      end
    end
  end

  def get_article(user_folder)
    Dir["#{user_folder}/**/*"].each do |f|
      if f =~ /.*txt$/
        return f
      end
    end
    return nil
  end

  def convert_youtube_url(youtube_url)
    begin
      regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
      m = youtube_url.scan(regExp)
      return "http://www.youtube.com/embed/#{m[0].last}".strip
    rescue Exception => e
      return ''
    end

  end

  def get_username_from_txt(line)
    line.sub(@name_tag, '').strip
  end

  def get_article_content(user_folder, user)
    begin

      File.open(get_article(user_folder)).each_with_index do |line, i|
        if 0==i
          user[:title] = line.rstrip
        elsif line.include? "youtube"
          line.strip!
          if line.include? 'embed'
            user[:videos] << line
          else
            user[:videos] << convert_youtube_url(line)
          end
        elsif line.start_with? @name_tag
            user[:name] = get_username_from_txt(line)
        else
          user[:content] << line.rstrip
        end
      end
    rescue Exception => e
      user[:title] = "找不到相關的留言文字檔案"
    end

  end

  def load
    assets_folder = File.expand_path('../users', File.dirname(__FILE__))
    Dir["#{assets_folder}/*"].each do | user_folder |
      next unless File.directory?(user_folder)
      user = {name: nil,imgs:[], videos: [], title: '', content: []}
      get_images(user_folder, user)
      get_article_content(user_folder, user)
      user[:name] ||= user_folder.split('/').last
      if (user[:imgs].count + user[:videos].count + user[:content].count )> 0
        self.result << user.clone
      end
    end
    result
  end
end
