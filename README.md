imgclass
--------

imgclass is a server application used for tagging (selecting bounding boxes around objects of interest) large sets of images. Jobs can be assigned to individual workers for tagging.

The variety of possible labels for images in a set is completely customizable. For example:  
```car, van, bus, SUV, truck, person, motorcycle, bicycle, none```  
or  
```cat, dog, turtle, bird```  
etc

imgclass is intended to be used for neural network research in the construction of supervised training sets.

Once the complete image set has been labeled, a textfile containing bounding boxes for each image can be downloaded.

Installation/Usage:
1. Install Rails (tested with Rails 5 on Ubuntu 16.04, Windows 10 and Mac OSX)
2. Clone imgclass repository
3. Create database (rake db:create), install Gems etc
4. Upload image URLs textfile and define labels
5. Assign labeling jobs to workers
6. Download completed training sets

The recommended format for inputing images to be tagged is a textfile with each line containing an image URL, ex:
https://s3-us-west-2.amazonaws.com/imgclass-images/LargeSet6200Images/0001.jpg
