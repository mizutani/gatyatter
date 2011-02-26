# -*- coding: utf-8 -*-
require 'rubygems'
require 'twitter'
require 'yaml'

class Replay
  def initialize
#アカウントを読み込む
    account = YAML.load_file 'account.yml'
#Twitterへログイン
    Twitter.configure do |config|
      config.consumer_key = account['sk']
      config.consumer_secret = account['ce']
      config.oauth_token = account['at']
      config.oauth_token_secret = account['ats']
    end
  end
#リプライ率の設定
  def probability
    list = {}
#フォローしてるユーザの情報を取得
    Twitter.friends['users'].each do |item|
#総Tweet数
      count = item['statuses_count']
#Twitter利用開始から今までの時間
      time = Time.now - Time.parse(item['created_at'])
#一日あたりの平均Tweet数
      ave = (count.to_i / (time / 86400)).to_i + 1
#リプライ率
      proba = 30 * (100 / ave)
      list[item['screen_name']] = proba
    end
#ファイルにYAMLで書き込み
     open('user_list.yml', 'w'){|f| f.puts list.to_yaml}
  end
end
replay = Replay.new
replay.probability
