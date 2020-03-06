require 'fileutils'
require 'json'

require_relative 'truth/javascript_writer'
require_relative 'truth/ruby_writer'
require_relative 'util/string'

class Truth
  attr_reader :data

  DATA_PATH = "./source-of-truth"

  def self.update!
    truth = new(path = DATA_PATH)

    puts "Writing Javascript package..."
    truth.update_javascript_package!
    puts "Done.\n\n"

    puts "Writing Ruby gem..."
    truth.update_ruby_gem!
    puts "Done.\n\n"
  end

  def initialize(path = DATA_PATH)
    @path = path
    @data = {}
    parse_json_files!
  end

  def update_javascript_package!
    JavascriptWriter.write @data
  end

  def update_ruby_gem!
    RubyWriter.write @data
  end

  private

  def parse_json_files!
    file_list = Dir.glob("source-of-truth/**/*.json")

    file_list.each do |path|
      key = File.join(File.dirname(path), File.basename(path, ".json")).gsub!(/^source-of-truth\//, '')
      @data[key] = JSON.parse(File.read(path))
    end
  end
end
