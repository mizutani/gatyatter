# -*- coding: utf-8 -*-
require 'rubygems'
require 'twitter'
require 'yaml'
class Replay
  def initialize
    account = YAML.load_file 'account.yml'
    Twitter.configure do |config|
      config.consumer_key = account['sk']
      config.consumer_secret = account['ce']
      config.oauth_token = account['at']
      config.oauth_token_secret = account['ats']
    end
  end
  def probability
    list = {}
    Twitter.friends['users'].each do |item|
      count = item['statuses_count']
      time = Time.now - Time.parse(item['created_at'])
      ave = (count.to_i / (time / 86400)).to_i + 1
      proba = 30 * (100 / ave)
      list[item['screen_name']] = proba
    end
     open('user_list.yml', 'w'){|f| f.puts list.to_yaml}
  end
end
replay = Replay.new
replay.probability
