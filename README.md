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

#### Server Provisioning and Deployment
 1. Create AWS EC2 t2.micro Ubuntu 16.04 instance
 2. SSH into server
 3. ```>> git clone https://github.com/asfarley/imgclass.git && cd imgclass```
 4. Follow instructions in provision.sh to create a new user
 5. Execute ```>> ./provision.su``` on server
 6. Close SSH connection
 7. In local development environment, execute ```>> cap production deploy```
 8. In local development environment, execute ```>> cap production rails:rake:db:setup```
 9. Login to EC2 instance URL landing page as administrator (default account: admin@imgclass.com, password: password). Upload image URLs textfile and define labels
 10. Assign labeling jobs to workers
 11. Workers log in to EC2 instance URL landing page (worker@imgclass.com, password: password) and label images
 12. Adming downloads labelled training set

#### Development Environment Setup
 1. Clone imgclass repo
 2. Install rbenv, ruby, etc (follow provision.sh script)
 3. Launch development server using launch.sh

The recommended format for inputing images to be tagged is a textfile with each line containing an image URL, ex:  
https://s3-us-west-2.amazonaws.com/imgclass-images/LargeSet6200Images/0001.jpg

#### Technical Background

The imgclass application code contains the following models:
 * ImageLabelSet: The main concept linking a set of images to a set of possible tags, and the results from user tagging.
 * ImageLabel: A user's tagged results from a single image
 * Image: A single image to be tagged, possible by multiple users
 * Job: A group of ImageLabels assiged to a particular worker
 * Label: One of several possible object types that may occur in a given ImageLabelSet
 * User: Either an admin (capable of uploading ImageLabelSets and assigning jobs) or a worker (capable of tagging images).

Images were previously stored directly on the Rails application server but can now be stored on an external server and referenced by URL. This is the recommended choice.

Image tags are represented as JSON-formatted rectangles:

```[{"x":0.262,"y":0.35231316725978645,"width":0.22,"height":0.23843416370106763,"classname":"Car"},{"x":0.908,"y":0.5338078291814946,"width":0.086,"height":0.18505338078291814,"classname":"Car"},{"x":0.696,"y":0.042704626334519574,"width":0.054,"height":0.08896797153024912,"classname":"Car"},{"x":0.618,"y":0.03202846975088968,"width":0.062,"height":0.08185053380782918,"classname":"Car"},{"x":0.65,"y":0.1103202846975089,"width":0.008,"height":0.0035587188612099642,"classname":"Car"},{"x":0.658,"y":0.1103202846975089,"width":0.052,"height":0.099644128113879,"classname":"Car"},{"x":0.568,"y":0.08185053380782918,"width":0.08,"height":0.09608540925266904,"classname":"Car"},{"x":0.578,"y":0.14590747330960854,"width":0.11,"height":0.15658362989323843,"classname":"Car"},{"x":0.48,"y":0.16370106761565836,"width":0.092,"height":0.1387900355871886,"classname":"Car"},{"x":0.006,"y":0.17793594306049823,"width":0.092,"height":0.15302491103202848,"classname":"Car"}]```

The image-tagging page renders bounding-boxes as SVG. The form transmit a JSON representation of the bounding-box set to the Rails server for storage.

The performance demands on the server should be relatively light-weight using the external URL strategy.
