#!/usr/bin/env ruby
require 'yaml'
require 'colorize'
require 'fileutils'
require "#{File.dirname(__FILE__)}/create_global_toc.rb"

class Version
   def initialize(version,display)
       @version=version
       @display=display
   end
end

class Deploy
  def initialize(path = ".")
    if path.nil?
        path = "."
    end
    if !File.directory?(path) or !File.directory?("#{path}/.git")
      puts "Brocken target path"
    end

    fillDefaults(path)
    test_docs
    @conf["tags"].each do |tag|
        puts "Processing tag #{tag}"
        collect_docs_from_verion(tag)
    end
    if @conf["addCurrent"] == "true"
      collect_docs_from_verion('current')
    end
    generate_jekyll_data()
    generate_latest_structure(@conf["jekyll_root"])
    gm = GlobalMenu.new(@conf["jekyll_root"])
    gm.process()
  end

  def generate_latest_structure(path)
    config_data = YAML.load_file("#{path}/_data/generated_config.yml")
    docs_root = config_data["docs_root"]
    latest_version = config_data["version"]
    Dir.chdir "#{path}/#{docs_root}/#{latest_version}"
    FileUtils.rm_rf("../latest")
    redirect_content =
            "---\n" \
            "layout: redirected\n" \
            "sitemap: false\n" \
            "redirect_to: $LATEST\n"\
            "---"
    Dir.glob("**/index.md").each do |file_name|
        FileUtils.mkdir_p(File.dirname("../latest/#{file_name}"))
        file = File.new("../latest/#{file_name}","w")
        file.write(redirect_content)
    end
  end

  def test_docs()
      puts "Test deploy for #{@conf['curr_tag']}".green
      if !File.directory?(@conf["jekyll_root"])
        Dir.mkdir(@conf["jekyll_root"])
        `cp -R gh-pages-stub/* #{@conf["jekyll_root"]}`
        
      end
      puts @conf
  end

  def collect_docs_from_verion(version)
      tmp_path = "#{@conf["path"]}/tmp/#{version}"
      FileUtils.mkdir_p(tmp_path)
      if version == 'current'
          `cp -R #{@conf["path"]}/* #{tmp_path}`
      else        
          `git -C #{@conf["path"]} archive #{version} | tar -x -C #{tmp_path}`
      end
      FileUtils.mkdir_p("#{@conf["jekyll_root"]}/doc/")
#      if File.directory?("#{tmp_path}/doc")
#          dst = "#{@conf["jekyll_root"]}/doc/#{version}"
#          `rm -rf #{dst}` if File.directory?("#{dst}")
#          `ln -s #{tmp_path}/doc #{dst}`          
#      end
      @conf["java_docs"].each do |docs|
          docs.each do |key,value|
              puts key,value
              folders = value["docs"].values.collect {|file| "#{tmp_path}/#{value["path"]}/#{file}" }
              if (!(folders.all? {|file| File.directory?(file)}))
                  `cd #{tmp_path}/#{value["path"]} && #{value["cmd"]}`
              end
              value["docs"].each do |k,v|
                  if File.directory?("#{tmp_path}/#{value["path"]}/#{v}")
                    FileUtils.mkdir_p("#{@conf["jekyll_root"]}/#{value["target"]}/#{k}/#{version}")
                    FileUtils.copy_entry(
                        "#{tmp_path}/#{value["path"]}/#{v}",
                        "#{@conf["jekyll_root"]}/#{value["target"]}/#{k}/#{version}/"
                    )
                  elsif File.exist?("#{tmp_path}/#{value["path"]}/#{v}")
                  else
                    puts "Failed to found generated doc #{tmp_path}/#{value["path"]}/#{v}".red
                  end
              end
          end
      end
  end

  def generate_jekyll_data()
      FileUtils.mkdir_p("#{@conf["jekyll_root"]}/_data")
      generated_config = {}
      generated_config["version"] = @conf["latest"]
      generated_config["docs_root"] = "doc"
      File.open("#{@conf["jekyll_root"]}/_data/generated_config.yml", 'w') { |f| YAML.dump(generated_config, f) }
  end

  def fillDefaults(repo_path)
    confFile = "#{repo_path}/.jekver.yml"
    if File.file?(confFile)
      puts "Loading configuration from #{confFile}".green
      @conf = YAML.load_file(confFile)
    else
      puts "Missing conf file #{confFile} using defaults".yellow
      confFile = ".jekver.yml" # TODO use pat relative from script
      @conf = {}
    end
    @conf["path"] = File.absolute_path(repo_path)
    if !@conf.has_key?("project")
      @conf["project"] = "default"
    end
    @conf["tags"] = `git -C #{@conf["path"]} tag`.split(/\n/).select{ |i| i[/v[0-9]+\.[0-9]+\.[0-9]+/] }
    #@conf["tags"] = @conf["tags"].sort_by{|t| tmp = t.split(/v|\./); tmp[1]*1000*1000+tmp[2]*1000+tmp[3]}
    if @conf.has_key?("startFromTag")
        vr = @conf["startFromTag"].scan(/v(\d*)\.(\d*)\.(\d*)/)[0].map {|i| i.to_i}
        @conf["tags"] = @conf["tags"].reject{
            |t| v=t.scan(/v(\d*)\.(\d*)\.(\d*)/)[0].map{|i| i.to_i};
            v[0] < vr[0] || (v[0] == vr[0] && v[1] < vr[1]) || (v[0] == vr[0] && v[1] == vr[1] && v[2] < vr[2]) 
        }
    else
        puts "Missing tag startFromTag using all tags".yellow
    end
    @conf["curr_tag"] = `git -C #{repo_path} tag --contains`
    @conf["curr_tag"] = "current" \
            if @conf["curr_tag"].empty?
    @conf["jekyll_root"] =  File.absolute_path( \
            "#{@conf["path"]}/test-#{@conf["project"]}-pages-#{@conf["curr_tag"]}") \
            unless @conf.has_key?("jekyll_root")
    @conf["autogen-docs"]= "#{@conf["jekyll_root"]}/autogen-docs" unless @conf.has_key?("autogen-docs")
    @conf["latest"] = @conf["curr_tag"] \
            unless @conf.has_key?("latest")
  end
end

