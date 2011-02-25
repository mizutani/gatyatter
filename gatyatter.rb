# -*- coding: utf-8 -*-
require 'rubygems'
require 'eventmachine'
require './userstream'
Thread.new do
  while true
    begin
      EM::run do
        EM.add_periodic_timer(3600){
          system("ruby ./tweet.rb")
        }
        EM.add_periodic_timer(86400){
          system("ruby ./user_list.rb")
        }
      end
    rescue => e
      open('log.txt', 'a') do |f|
        f.puts "#{Time.now}: #{e.message}"
      end
      next
    end
  end
end

while true
  begin
    twitter = User_stream.new
    twitter.start
  rescue Timeout::Error, StandardError => e
    #puts e.message
    #puts e.backtrace
    open('log.txt', 'a') do |f|
      f.puts "#{Time.now}: #{e.message}"
    end
    next
  end
end
