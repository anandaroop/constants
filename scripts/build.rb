require './lib/source_of_truth'

# read the tree of json files from the filesystem
source_of_truth = SourceOfTruth.new
puts "Source of truth"
puts "---------------\n\n"
puts (JSON.pretty_generate source_of_truth.data) << "\n\n"

# write a new version of the js package
puts "Writing Javascript package..."
source_of_truth.update_javascript_package!
puts "Done.\n\n"
