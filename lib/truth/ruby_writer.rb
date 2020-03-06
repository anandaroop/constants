class RubyWriter
  RUBY_PACKAGE_ROOT = "./packages/ruby"
  RUBY_LIB_ROOT = File.join RUBY_PACKAGE_ROOT, "lib"

  def self.write(data)
    new(data).write!
  end

  def initialize(data)
    @data = data
  end

  def write!
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
end

