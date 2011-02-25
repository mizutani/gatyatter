# -*- coding: utf-8 -*-
require 'rubygems'
require 'twitter'
require 'yaml'
require './gatyatter_study'
class Tweet
  def initialize
    @study = Study.new
    account = YAML.load_file 'account.yml'
    Twitter.configure do |config|
      config.consumer_key = account['sk']
      config.consumer_secret = account['ce']
      config.oauth_token = account['at']
      config.oauth_token_secret = account['ats']
    end
  end
  def update
    message = @study.random_return "私"
    Twitter.update(message.join)
  end
end
tweet = Tweet.new
tweet.update
