Looking for an experienced Rails developer to check over my application for bugs and UX issues.

The application is a tool for users to upload and farm out image tagging. Tagging is performed by workers manually selecting rectangles in images. So there will be 2 classes of users: Paying users who upload image sets to be tagged, and paid workers who perform the tagging. 

The web server doesn't need to include payment processing functionality, I'll handle that seperately for now. I just want to make sure I have a solid application for uploading large image sets and downloading the tagged results. 

You can check out the live server here:
imgclass.com

And the github repo is here:
https://github.com/asfarley/imgclass

The main items on my priority list are:
-get some unit tests written
-fix loose ends, UX issues, etc
-ensure application is reliable
-add safety checks at various points (make sure user doesn't upload more files than remaining server HDD space, etc)

I don't expect to necessarily have a single person fix everything on my list. I would prefer a senior developer to charge for an hour or two to download the repo, get the application launched and have a quick look a the code. Then we can discuss how to move forward from there. 

If things go well, I may want to integrate a payment processing API and move the image files to S3, but that's a couple of months down the road.





There isn't any more documentation, but I'm happy to provide more explanation
The purpose of this application is to generate a training set for neural networks (machine learning)
So the paying users upload sets of images to be classified
Then, workers log on to classify images by hand
Then, the paying users download the set of classified images, so they can use it to train a neural network
It's actually a pretty simple application; basically it just displays an image, and the user draws SVG rectangles over the image using Javascript
then the list of SVG rectangles is sent to the server 
You don't really need to know anything about neural networks though
As far as this application is concerned, it's just an image-tagging website


server ip
ec2-35-165-73-193.us-west-2.compute.amazonaws.com
ssh -i /Users/Apple/Documents/imgclass/shared.pem ubuntu@ec2-35-165-73-193.us-west-2.compute.amazonaws.com