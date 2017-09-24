# extract_random_subset.rb
#
# This script takes a folder of images as input. It extracts a randomized subset
# of images within the folder and copies them to an output folder.
# 
# The first argument is the path to the input images. The second argument is the number of random images
# to extract.
# 
# Example:
# ruby extract_random_subset.rb ./Images 100
# Output: ./RandomSubset
#
# Alexander Farley
# 2017-08-20
require 'fileutils'
require 'pry'

#Parse command-line arguments
if (ARGV.count < 2)
	puts "This script requires two arguments: a path to the folder containing image, and the number of images to extract."
	exit
end

#Get all movie files in this subdirectory
in_directory = ARGV[0]
num_images = ARGV[1].to_i
out_directory = "./RandomSubset"

files = Dir["#{in_directory}/**/*.*"]
accepted_formats = [".jpg"]
image_files = files.select { |pathstring| accepted_formats.include? File.extname(pathstring) }

#Check if files exist in output location
if Dir.exist? out_directory	
	FileUtils.remove_dir(out_directory)
end
Dir.mkdir out_directory


image_files_random_selection = image_files.sample(num_images)
image_files_random_selection.each do |image_path|
	basename = File.basename(image_path)
	new_path = File.join(out_directory, basename)
	FileUtils.cp(image_path, new_path)
end