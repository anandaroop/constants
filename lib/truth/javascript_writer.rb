class JavascriptWriter
  JAVASCRIPT_PACKAGE_ROOT = "./packages/javascript"
  JAVASCRIPT_SRC_ROOT = File.join JAVASCRIPT_PACKAGE_ROOT, "src"

  def self.write(data)
    new(data).write!
  end

  def initialize(data)
    @data = data
  end

  def write!
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
end

