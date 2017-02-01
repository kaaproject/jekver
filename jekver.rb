#!/usr/bin/env ruby
require 'fileutils'
require 'colorize'
require "./#{File.dirname(__FILE__)}/src/tst_deploy.rb"
require 'optparse'

begin
  # Parce CLI arguments
  options={}
  OptionParser.new do |opts|
    opts.banner = "Usage: example.rb [options] PROJECT_PATH"
    opts.on('-p', '--project PROJECT_NAME', 'Project name') { |v| options["project"] = v }
    opts.on('-r', '--remote REMOTE', 'Set default remote for repository') { |v| options["remote"] = v }
    opts.on('-s', '--start-from TAG','Set minimal tag') { |v| options["startFromTag"] = v }
    opts.on('-l', '--latest TAG','Set tag to generate redirection pages from "latest" links') { |v| options["latest"] = v }
    opts.on('-c', '--add-current', 'Add current branch to gh-pages') { |v| options["addCurrent"] = v }
    opts.on('-d', '--deploy', 'deploy documentation into gh-pages') { |v| options["deploy"] = v }
  end.parse!
  puts options
  if ARGV.empty?() or !File.directory?(ARGV[0]) or !File.directory?("#{ARGV[0]}/.git")
    puts "Brocken or missing target project path"
  else
    confFile = "#{ARGV[0]}/.jekver.yml"
    if File.file?(confFile)
      puts "Loading configuration from #{confFile}".green
      conf = YAML.load_file(confFile)
    else
      puts "Missing conf file #{confFile} using empty defaults".yellow
      confFile = ".jekver.yml" # TODO use pat relative from script
      conf = {}
    end
    options.each {|k,v| conf[k]=v}
    conf["path"] = File.absolute_path(ARGV[0])
    dp = Deploy.new(conf)
  end
rescue => error
  puts "Error: " + error.message
  puts error.backtrace
end
