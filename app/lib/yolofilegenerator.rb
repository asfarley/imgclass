require 'fileutils'

class YoloFileGenerator
  TEST_HOLDOUT_RATIO = 0.1

  def YoloFileGenerator.generate_output_directory_if_not_exist(directory)
    if (not File.exist?(directory))
      FileUtils::mkdir_p directory
    end
  end

  def YoloFileGenerator.generate_all_yolo_training_files(directory, image_file_paths, names_list)
    generate_output_directory_if_not_exist(directory)
    generate_train_test_txt(directory, image_file_paths)
    generate_obj_data(directory, names_list)
    generate_obj_names(directory, names_list)
    generate_yolo_obj_cfg(directory, names_list)
  end

  def YoloFileGenerator.generate_train_test_txt(directory, image_file_paths)
    num_images_total = image_file_paths.count
    num_test_holdout = 0.1*num_images_total
    shuffled_images = image_file_paths.shuffle

    train_set = shuffled_images[num_test_holdout...-1]
    train_filename = File.join(directory, "train.txt")
    if(File.exist?(train_filename))
      File.delete(train_filename)
    end
    File.open(train_filename, 'w') { |file|
      train_set.each do |train_image|
        file.write(train_image + "\n")
      end
    }

    test_set = shuffled_images[0...num_test_holdout]
    test_filename = File.join(directory, "test.txt")
    if(File.exist?(test_filename))
      File.delete(test_filename)
    end
    File.open(test_filename, 'w') { |file|
      test_set.each do |test_image|
        file.write(test_image + "\n")
      end
    }
  end

  def YoloFileGenerator.generate_obj_data(directory, names_list)
    obj_data_string = "classes=#{names_list.count}\ntrain = train.txt\nvalid = test.txt\nnames = cfg/obj.names\nbackup = backup/"
    this_filename = File.join(directory, "obj.data")
    if(File.exist?(this_filename))
      File.delete(this_filename)
    end
    File.open(this_filename, 'w') { |file|
      file.write(obj_data_string)
    }
  end

  def YoloFileGenerator.generate_obj_names(directory, names_list)
    names_string = names_list.inject(""){ |appended_string, name| appended_string + name + "\n" }
    this_filename = File.join(directory, "obj.names")
    if(File.exist?(this_filename))
      File.delete(this_filename)
    end
    File.open(this_filename, 'w') { |file|
      file.write(names_string)
    }
  end

  def YoloFileGenerator.generate_yolo_obj_cfg(directory, names_list)
    obj_cfg_string =
"[net]
batch=64
subdivisions=1
height=416
width=416
channels=3
momentum=0.9
decay=0.0005
angle=0
saturation = 1.5
exposure = 1.5
hue=.1

learning_rate=0.0001
max_batches = 45000
policy=steps
steps=100,25000,35000
scales=10,.1,.1

[convolutional]
batch_normalize=1
filters=32
size=3
stride=1
pad=1
activation=leaky

[maxpool]
size=2
stride=2

[convolutional]
batch_normalize=1
filters=64
size=3
stride=1
pad=1
activation=leaky

[maxpool]
size=2
stride=2

[convolutional]
batch_normalize=1
filters=128
size=3
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=64
size=1
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=128
size=3
stride=1
pad=1

activation=leaky
[maxpool]
size=2
stride=2

[convolutional]
batch_normalize=1
filters=256
size=3
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=128
size=1
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=256
size=3
stride=1
pad=1
activation=leaky

[maxpool]
size=2
stride=2

[convolutional]
batch_normalize=1
filters=512
size=3
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=256
size=1
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=512
size=3
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=256
size=1
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=512
size=3
stride=1
pad=1
activation=leaky

[maxpool]
size=2
stride=2

[convolutional]
batch_normalize=1
filters=1024
size=3
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=512
size=1
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=1024
size=3
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=512
size=1
stride=1
pad=1
activation=leaky

[convolutional]
batch_normalize=1
filters=1024
size=3
stride=1
pad=1
activation=leaky


#######

[convolutional]
batch_normalize=1
size=3
stride=1
pad=1
filters=1024
activation=leaky

[convolutional]
batch_normalize=1
size=3
stride=1
pad=1
filters=1024
activation=leaky

[route]
layers=-9

[reorg]
stride=2

[route]
layers=-1,-3

[convolutional]
batch_normalize=1
size=3
stride=1
pad=1
filters=1024
activation=leaky

[convolutional]
size=1
stride=1
pad=1
filters=#{(names_list.count + 5)*5}
activation=linear

[region]
anchors = 1.08,1.19,  3.42,4.41,  6.63,11.38,  9.42,5.11,  16.62,10.52
bias_match=1
classes=#{names_list.count}
coords=4
num=5
softmax=1
jitter=.2
rescore=1

object_scale=5
noobject_scale=1
class_scale=1
coord_scale=1

absolute=1
thresh = .6
random=0
"
    this_filename = File.join(directory, "yolo-obj.cfg")
    if(File.exist?(this_filename))
      File.delete(this_filename)
    end
    File.open(this_filename, 'w') { |file|
      file.write(obj_cfg_string)
    }
  end

end
