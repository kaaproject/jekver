#!/usr/bin/env ruby
require 'fileutils'
require "./#{File.dirname(__FILE__)}/gh-pages-stub/_scripts/tst_deploy.rb"

begin
    dp = Deploy.new(path = ARGV[0])
rescue => error
    puts "Error: " + error.message
    puts error.backtrace
end
