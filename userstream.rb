# -*- coding: utf-8 -*-
require 'net/https'
require 'oauth'
require 'json'
require './gatyatter_study'
class User_stream
  def initialize
    #oauth認証設定
    @study = Study.new
    account = YAML.load_file 'account.yml'
    @user_list = YAML.load_file 'user_list.yml'
    @consumer = OAuth::Consumer.new(account["sk"], account["ce"], :site => 'http://twitter.com')
    @access_token = OAuth::AccessToken.new(@consumer, account["at"], account["ats"])
    @uri = URI.parse('https://userstream.twitter.com/2/user.json')
    @https = Net::HTTP.new(@uri.host, @uri.port)
    @https.use_ssl = true
    @https.verify_mode = OpenSSL::SSL::VERIFY_NONE if @https.use_ssl?
  end
#Twitterへ投稿
  def update status
    message = status['text']
#messageがnilなら投稿をしない
    return if message == nil
#投稿者名取出す
    user = status['user']['screen_name']
    #in_reply_to_screen_name"=>"TManagement",
#自分宛のリプライを取出す
    if status['in_reply_to_screen_name'] == 'gatyatter'
      #外部処理に投げる
      data = @study.start($1) if message =~ /^@gatyatter (.+)/
    elsif @user_list.key? user
#設定したリプライ率以下ならリプライを返す
      return unless @user_list[user] > rand(10000)
      data = @study.start(message)
    end
    # @access_token.post('http://api.twitter.com/1/statuses/update.json',
    #                   'status' => "@#{user} #{data}",
    #                   'in_reply_to_status_id' => status['id'])
  end
  def start
    @https.start do |https|
      request = Net::HTTP::Get.new(@uri.request_uri)
      request.oauth!(@https, @consumer, @access_token)
      buf = ""
      @https.request(request) do |response|
        response.read_body do |chunk|
          # この処理をしないとうまく読み取れない（あんまりよく分かってない）
          buf << chunk
          # 改行コードで区切って一行ずつ読み込み
          while (line = buf[/.+?(\r\n)+/m]) != nil 
            begin
              buf.sub!(line,"") # 読み込み済みの行を削除
              line.strip!
              status = JSON.parse(line)
              #流れてるデータ確認用
              #pp status
            rescue
              break # parseに失敗したら、次のループでchunkをもう1個読み込む
            end
            #自分宛のリプライを取り出す
            begin
              update status
            rescue => e
              open('log.txt', 'a'){|f| f.puts "Time#{Time.now} Message:#{e.message} TweetUser:#{status['user']['screen_name']}"}
              #p e.message
              #p e.backtrace
              next
            end
          end
        end
      end
    end
  end
end
