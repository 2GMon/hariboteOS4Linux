#!/usr/bin/ruby

def main
  if ARGV.size != 2
    usage
  end

  data = []

  File.open(ARGV[0]) do |f|
    f.each do |line|
      if /^\./ =~ line || /^\*/ =~ line
        line = line.chomp
        line = line.gsub(".", "0")
        line = line.gsub("*", "1")
        data << line.to_i(2)
      end
    end
  end

  char = "char hankaku[4096] = {\n"
  size = data.size
  data.each_with_index do |elem, index|
    elem = sprintf("0x%02x", elem)
    if index == size - 1
      char += elem + "\n};"
    elsif index % 16 == 15
      char += elem + ",\n"
    else
      char += elem + ","
    end
  end

  c_src = File.open(ARGV[1], 'w')
  c_src.puts(char)
  c_src.close
end

def usage
  puts "usage: makefont.rb [font src] [c src file]"
end

main
