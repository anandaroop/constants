require 'fileutils'
require 'json'

class String
  def snakeify
    self
    .split(/\W/).reject { |s| s.nil? || s.length.zero? }
    .map(&:downcase)
    .join("_")
    .to_s
  end

  def camelify(initialCap: false)
    self
    .split(/\W/).reject { |s| s.nil? || s.length.zero? }
    .map(&:capitalize).tap do |parts|
      parts.first.downcase! unless initialCap
    end
    .join
    .to_s
  end
end

class SourceOfTruth
  attr_reader :data

  DATA_PATH = "./source-of-truth"
  JAVASCRIPT_PACKAGE_ROOT = "./packages/javascript"
  JAVASCRIPT_SRC_ROOT = File.join JAVASCRIPT_PACKAGE_ROOT, "src"
  RUBY_PACKAGE_ROOT = "./packages/ruby"
  RUBY_LIB_ROOT = File.join RUBY_PACKAGE_ROOT, "lib"

  def initialize(path= DATA_PATH)
    @path = path
    @data = {}
    parse_json_files!
  end

  def update_javascript_package!
    FileUtils.remove_entry JAVASCRIPT_SRC_ROOT if Dir.exists? JAVASCRIPT_SRC_ROOT
    FileUtils.mkdir JAVASCRIPT_SRC_ROOT

    # to accumulate requires and exports for the root index.js file
    requires = []
    exports = []

    # spit out the various constant js files
    @data.each do |path, data|
      puts "--> #{path}"
      file_path = File.join(JAVASCRIPT_SRC_ROOT, path) << ".js"
      parent_dir = File.dirname(file_path)
      package_name = File.basename(path)
      FileUtils.mkdir_p(parent_dir)
      File.write(file_path,
        <<~EOF
        module.exports = #{JSON.pretty_generate(data)}
        EOF
      )

      requires << %Q{const #{path.camelify(initialCap: true)} = require('./src/#{path}')}
      exports << %Q{#{path.camelify(initialCap: true)}}
    end

    # spit out the root file
    file_path = File.join(JAVASCRIPT_PACKAGE_ROOT, "index") << ".js"
    File.write(file_path,
      <<~EOF
      #{requires.join("\n")}

      module.exports = {
        #{exports.join(",\n\t")}
      }
      EOF
    )
  end

  def update_ruby_gem!
    FileUtils.remove_entry RUBY_LIB_ROOT if Dir.exists? RUBY_LIB_ROOT
    FileUtils.mkdir RUBY_LIB_ROOT

    # to accumulate requires and exports for the root rb file
    requires = []

    # spit out the various constant rb files
    @data.each do |path, data|
      puts "--> #{path}"
      file_path = File.join(RUBY_LIB_ROOT, "constants", path.snakeify) << ".rb"
      parent_dir = File.dirname(file_path)
      package_name = File.basename(path)
      FileUtils.mkdir_p(parent_dir)
      File.write(file_path,
        <<~EOF
        module Constants
          module #{path.camelify.capitalize}
            #{path.snakeify.upcase} = #{data.inspect}
          end
        end
        EOF
      )

      requires << %Q{require 'constants/#{path.snakeify}'}
    end

    # spit out the root rb file
    file_path = File.join(RUBY_LIB_ROOT, "constants.rb")
    File.write(file_path,
      <<~EOF
      module Constants
        #{requires.join("\n\t")}
      end
      EOF
    )
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
