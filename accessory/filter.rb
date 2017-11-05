require 'fileutils'

directory = ARGV[0]

Dir.chdir(directory)
folders = Dir.glob('*').select {|f| File.directory? f}

n_total = 0
n_bad = 0

folders.each do |folder| 
	n_total += 1
	textfiles_in_folder = Dir[folder + "/*.txt"]
	target_textfile = textfiles_in_folder[0]
	if(File.size(target_textfile) <= 1)
		n_bad += 1
		puts "Possible bad target deleted: #{target_textfile}"
		FileUtils.rm_rf(folder)
		#else
		#puts "Size was #{File.size(target_textfile)}"
	end
end

puts "#{n_bad} potential bad images (%#{100.0*n_bad/n_total}) deleted out of #{n_total} total."

puts "Removing deleted files from training and test sets..."
if File.exist?(directory + "/test.txt")
	File.open(directory + "/test_filtered.txt", "w") do |f|     
		File.readlines(directory + "/test.txt").each do |line|
			image_folder_path = directory + "/" + File.basename(line, ".*")
			puts "Looking for #{image_folder_path}"
			if File.exist?(image_folder_path)
				f.write(line)
			end
		end
	end
end

if File.exist?(directory + "/train.txt")
	File.open(directory + "/train_filtered.txt", "w") do |f|     
		File.readlines(directory + "/train.txt").each do |line|
			image_folder_path = directory + "/" + File.basename(line, ".*")
			puts "Looking for #{image_folder_path}"
			if File.exist?(image_folder_path)
				f.write(line)
			end
		end
	end
end