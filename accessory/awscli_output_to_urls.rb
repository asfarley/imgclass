#
#
# awscli_output_to_urls.rb
# This script takes an input file (output from the aws-cli client, typically the ls --recursive command) 
# and a bucket name and converts each line to a single URL, if applicable. The output file is named image_urls.txt.
#
# Usage:
# ruby awscli_output_to_urls.rb image_files.txt bucketname region

require 'byebug'

if(ARGV.count != 3)
	puts "This script requires exactly 3 arguments."
	exit
end

input_file = ARGV[0]
bucket_name = ARGV[1]
region = ARGV[2]

puts "Processing from file #{input_file}, bucket: #{bucket_name} and region: #{region}"


## 
## Amazon bucket link format:
## https://s3-[region].amazonaws.com/[bucket]/[path]
##

File.open("image_urls.txt","w") { |f| 
	File.readlines(input_file).each do |line|
		#byebug
		if (line.include? "jpg")
			image_subpath = line.split(" ").last
			image_url = "https://s3-#{region}.amazonaws.com/#{bucket_name}/#{image_subpath}"
			f.puts(image_url)
		end
	end
}

puts "Done."