# -*- coding: utf-8 -*-
require 'rubygems'
require 'MeCab'
#require 'psych'
require 'yaml'
require 'kconv'
#YAML::ENGINE.yamler = 'psych'
class Hash 
  def random_key 
    array = []
    self.keys.each {|k| array << k}
    return array[rand(array.size)]
  end 
end
class Study
  def initialize
    @data = YAML.load_file 'data.yaml'
    @data ||= {}
    @wakati = MeCab::Tagger.new('-o wakati')
  end
  def marukohu text
    first = text.shift
    second = text.shift
    text.each do |t|
      @data[first] ||= {}
      @data[first][second] ||= []
      @data[first][second] << t unless @data[first][second].index(t)
      first, second = second, t
    end
  end
  #受け取ったテキストを分かち書きにして出力
  def text_wakati x
    x.split(/\n|!|\?|？|！|。/).each do |text|
      text = filter text
      next if text == "" || text == false
      wakati = []
      @wakati.parse(text).split(/\n/).each do |line|
        tmp = line.split(/,/).shift.split(/\s/).shift.toutf8
        wakati << tmp
      end
      marukohu wakati
    end
  end
  def filter text
    return false if text =~ /http\S+/
    text.gsub!(/@\S+\s/, "")
    text.gsub!(/\[.*?\]|\{.*?\}|【.*?】|（.*?）|\(.*?\)|「.*?」|『.*?』|［.*?］|〈.*?〉|〔.*?〕/, "")
    text.gsub!(/俺|僕|自分|おれ/, '私')
    text
  end
  #ユーザから受け取ったテキストの名詞を取得
  def user_text text
    meishi = []
    @wakati.parse(text).split(/\n/).each do |line|
      meishi << $2 if line.toutf8 =~ /\S+\s+名詞,\S+,(\*,)+(\S+),\S+,\S+/
    end
    meishi
  end
  def front_text key1, key2
    return_text = []
    while 
        text = []
      @data.each do |first, value|
        value.each do |second, v|
          next unless v.index(key2) && second == key1
          text << first unless text.index(first)
        end
      end
      break if text.empty?
      return_text.unshift(text.sample)
      key1, key2 = return_text[0], key1
    end
    return_text
  end
  def text_return key_word 
    word = []
    @data.each do |first, value|
      value.each do |second, v|
        #word << [first, second, value] if second == key_word
        word << [first, second] if v.index(key_word)
      end
    end
    word.sample
  end
  #ランダムに文書を生成
  def random_return first = nil
    t = []
    first ||= @data.random_key
    second = @data[first].random_key
    t << first << second
    while true
      tmp = @data[first][second][rand(@data[first][second].size)]
      break if tmp =~ /EOS|。/
      t << tmp
      first, second = second, tmp
    end
    t
  rescue => e
    # p e.message
    random_return
  end
  def start text
    open('tweet_log.txt', 'a'){|f| f.puts text}
#    open('/home/hentaishinshi/webdav/tweet_log.txt', 'a'){|f| f.puts text}
    text_wakati(text)
    keys = user_text text
    key = keys.sample
    a = text_return key
    b = front_text a[0], a[1]
    c = random_return key
    (b + a + c).join
  rescue
    random_return.join
  ensure
    open('data.yaml', 'w'){|f| f.puts @data.to_yaml}
  end
  def ttt
    @data
  end
end

