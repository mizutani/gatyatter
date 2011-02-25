# -*- coding: utf-8 -*-
require './gatyatter_study'
study = Study.new
#study.text_wakati "今日の気分は俺は最悪です!\n頑[張りま]しょ『』[]う！！http:sssss!!寝る" 
def reset_d
  study = Study.new
  open('tweet_log.txt', 'r') do |f|
    while line = f.gets
      (study.text_wakati(line))
    end
  end
  open('data.yaml', 'w'){|f| f.puts study.ttt.to_yaml}
end
def show_data
  require 'pp'
  study = Study.new
  pp study.ttt
end
reset_d
show_data
