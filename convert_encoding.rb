Dir["erb/**/*"].each do |f|
  File.rename(f, "#{f}_old")
  system("iconv -f ISO-8859-1 -t UTF-8  #{f}_old > #{f}")
end