#!/usr/bin/env ruby
require 'yaml'
require 'colorize'
require 'fileutils'
require "#{File.dirname(__FILE__)}/create_global_toc.rb"

class Deploy
  def initialize(conf)
    fillDefaults(conf)
    generate_jekyll_data()
    @conf["tags"].each do |tag|
      puts "Processing tag #{tag}"
      collect_docs_from_verion(tag)
    end
    if @conf["addCurrent"]
      collect_docs_from_verion('current')
    end
    generate_latest_structure(@conf["jekyll_root"])
    gm = GlobalMenu.new(@conf["jekyll_root"])
    gm.process()
    if @conf["deploy"]
      commit_jekyll_data()
    end
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

  def copy_doc_cp(src,dst)
    puts "mkdir  #{dst}"
    if File.exists?(src) || File.directory?(src)
      FileUtils.mkdir_p(dst)
      FileUtils.copy_entry(src,dst)
    else
      puts "Failed to find generated doc #{src}".red
    end
  end

  def copy_doc_ln(src,dst)
    puts "Going to create sym link for #{dst}"
    if File.exists?(src) || File.directory?(src)
      #FileUtils.mkdir_p(File.dirname(dst))
      File.symlink src,dst
    else
      puts "Failed to find generated doc #{src}".red
    end
  end

  def collect_docs_from_verion(version)
    tmp_path = "#{@conf["path"]}/tmp/#{version}"
    if File.directory?(tmp_path)
      `rm -rf #{tmp_path}`
    end
    FileUtils.mkdir_p(tmp_path)
    copy_doc = lambda {|src,dst| copy_doc_cp(src,dst)}
    if version == 'current'
      copy_doc = lambda {|src,dst| copy_doc_ln(src,dst)}
      tmp_path = "#{@conf["path"]}"
      #`tar -C #{@conf["path"]} -c --exclude tmp --exclude .git --exclude #{@conf["jekyll_root"]} . | tar -x -C #{tmp_path}`
    else
      `git -C #{@conf["path"]} archive #{version} | tar -x -C #{tmp_path}`
    end
    @conf["jekdocs"].each do |docs|
      docs.each do |key,value|
        puts key,value
        folders = value["copy"]
            .select {|item|  item.has_key?("src")}
            .collect {|item| "#{tmp_path}/#{value["path"]}/#{item["src"]}" }
        if !(folders.all? {|file| File.directory?(file)})
          if File.directory?("#{tmp_path}/#{value["path"]}")
            `cd #{tmp_path}/#{value["path"]} && #{value["cmd"]}`
          else
            puts "Failed to found path #{tmp_path}/#{value["path"]} to build docs".red
          end
        end
        value["copy"]
            .select {|item|  item.has_key?("src") and item.has_key?("dst")}
            .each do |item|
          copy_doc.call(
              "#{tmp_path}/#{value["path"]}/#{item["src"]}",
              "#{@conf["jekyll_root"]}/#{value["target"]}/#{item["dst"]}/#{version}"
          )
        end
      end
    end
  end

  def generate_jekyll_data()
    puts "Generate Jekver data".green
    if File.directory?(@conf["jekyll_root"])
      `rm -rf #{@conf["jekyll_root"]}`
    end
    if @conf["deploy"]
      if `git -C #{@conf["path"]} branch --list gh-pages`.empty?()
        remote = `git -C #{@conf["path"]} remote`.split("\n")
        remote = remote.select{|r| r == 'origin'}+ remote.reject{|r| r == 'origin'}
        remote = remote.map{|r| r + "/gh-pages"}
        remote = remote.detect{|r| `git -C #{@conf["path"]} branch -r --list gh-pages`.empty?() }
        `git -C #{@conf["path"]} checkout #{remote} -b gh-pages`
      end
      `git clone #{@conf["path"]} #{@conf["jekyll_root"]} -b gh-pages`
      `rm -rf #{@conf["jekyll_root"]}/*`
    else
      FileUtils.mkdir_p(@conf["jekyll_root"])
    end
    `cp -R #{@conf["jek_path"]}/gh-pages-stub/* #{@conf["jekyll_root"]}`

    FileUtils.mkdir_p("#{@conf["jekyll_root"]}/_data")
    generated_config = {}
    generated_config["version"] = @conf["latest"]
    generated_config["docs_root"] = "docs"
    puts "Generate generated_config.yml".green
    File.open("#{@conf["jekyll_root"]}/_data/generated_config.yml", 'w') { |f| YAML.dump(generated_config, f) }
    @conf["jekconf"].each { |e| e["src"] = "#{@conf["path"]}/.jekver/#{e["src"]}" }
    @conf["jekconf"].each { |e| e["dst"] = "#{@conf["jekyll_root"]}/#{e["dst"]}" }
    @conf["jekconf"].select { |e| File.exists?(e["src"])}.each { |e|FileUtils.cp(e["src"],e["dst"]) }
    #@conf["jekconf"].select { |e| File.directory?(e["src"])}.each { |e|FileUtils.cp_r(e["src"],e["dst"]) }  
  end

  def commit_jekyll_data()
    puts "Going to commit gh-pages".green
    `git -C #{@conf["jekyll_root"]} add *`
    `git -C #{@conf["jekyll_root"]} commit -m 'Updated gh-pages with jekver'`
  end

  def fillDefaults(conf)
    @conf = conf
    if !@conf.has_key?("project")
      @conf["project"] = "default"
    end
    @conf["jek_path"] = "#{File.dirname(__FILE__)}/.."
    @conf["tags"] = `git -C #{@conf["path"]} tag`.split(/\n/).select{ |i| i[/v[0-9]+\.[0-9]+\.[0-9]+/] }
    #@conf["tags"] = @conf["tags"].sort_by{|t| tmp = t.split(/v|\./); tmp[1]*1000*1000+tmp[2]*1000+tmp[3]}
    if @conf.has_key?("startFromTag")
      vr = @conf["startFromTag"].scan(/v(\d*)\.(\d*)\.(\d*)/)[0].map {|i| i.to_i}
      @conf["tags"] = @conf["tags"].reject {
          |t| v=t.scan(/v(\d*)\.(\d*)\.(\d*)/)[0].map{|i| i.to_i};
          v[0] < vr[0] || (v[0] == vr[0] && v[1] < vr[1]) || (v[0] == vr[0] && v[1] == vr[1] && v[2] < vr[2])
        }
    else
      puts "Missing tag startFromTag using all tags".yellow
    end
    @conf["curr_tag"] = `git -C #{@conf["path"]} tag --contains`.strip
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
