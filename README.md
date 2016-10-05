# imgclass

imgclass is a server application used for labeling large sets of images. Jobs (sets of 5000 images) can be assigned to individual workers for labeling.

The variety of possible labels for images in a set is completely customizable. For example:  
```car, van, bus, SUV, truck, person, motorcycle, bicycle, none```  
or  
```cat, dog, turtle, bird```  
etc

imgclass is intended to be used for neural network research in the construction of supervised training sets.

Once the complete image set has been labeled, a textfile containing labels for each image can be downloaded.

## Installation/Usage
1. Install Rails (tested with Rails 4 on Ubuntu 15.10)
2. Clone imgclass repository
3. Prepare site
    1. Create database (rake db:create)
    1. Install Gems etc
    1. Set config values for your environment
4. Upload image set and define labels
5. Assign labeling jobs to workers
6. Download completed training sets
