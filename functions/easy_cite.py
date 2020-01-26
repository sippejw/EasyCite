from skimage.measure import compare_ssim as ssim
import numpy as np
import cv2

from PIL import Image

import time
import datetime

import pyrebase
from firebase import Firebase

import os

#image similarity
#
#
#input an image output an ISBN as an integer
def textbook_recognition(imgA,imgB):
    size = 300	,200

    #force dimensions to match
    imageA = Image.open(imgA)
    imageB = Image.open(imgB)
    
    im_resizedA = imageA.resize(size, Image.ANTIALIAS)
    im_resizedA.save("my_image_resized.png", "PNG")
    im_resizedA = np.array(im_resizedA)
    

    im_resizedB = imageB.resize(size, Image.ANTIALIAS)
    im_resizedB = np.array(im_resizedB)


    # the 'Mean Squared Error' between the two images is the
    # sum of the squared difference between the two images;
    # NOTE: the two images must have the same dimension
    err = np.sum((im_resizedA.astype("float") - im_resizedB.astype("float")) ** 2)
    err /= float(im_resizedA.shape[0] * im_resizedA.shape[1])

    return err

from google.cloud import vision
import io

#google vision api
#currently just prints the text and returns the text object
#
#takes in a path to an image and returns the text object
def quotation_maker(image_path):
    path = image_path

    client = vision.ImageAnnotatorClient()

    with io.open(path, 'rb') as image_file:
        content = image_file.read()

    image = vision.types.Image(content=content)

    response = client.text_detection(image=image)
    texts = response.text_annotations

    return texts[0].description

quotation_maker('../images/humanrights1.JPG')

config = {"apiKey"		: "AIzaSyBvzqpTNHhk-aP0ROFyspt_PV0y5P6Fho0"
         ,"authDomain"		: "digital-ethos-200423.firebaseapp.com"
         ,"databaseURL"		: "https://digital-ethos-200423.firebaseio.com"
         ,"projectId"		: "digital-ethos-200423"
         ,"storageBucket"	: "digital-ethos-200423.appspot.com"
         ,"messagingSenderId"	: "30458395453"
         ,"appId"		: "1:30458395453:web:9eb870fd301c500aac6354"
         ,"measurementId"	: "G-E6PX1988X0"}

firebase = Firebase(config)
pyrebase = pyrebase.initialize_app(config)
db = pyrebase.database()
storage = firebase.storage()

#need to automate the building of final_images

for key, value in zip(db.child("catalog").get().val().keys(),db.child("catalog").get().val().values()):
    entry_image_path = value["cover_image"]
    #print(entry_image_path[37:])
    storage.child(entry_image_path[37:]).download('../final_images/' + key + '.jpg', None)


fimage_directory = os.fsencode('../final_images/')
final_images = []
for fp in os.listdir(fimage_directory):
    filename = os.fsdecode(fp)
    #print("filename",filename)
    final_images.append(filename)
print("final_images-------\n",final_images,"\n--------")

#lower to make the threshold more strict
THRESHOLD = 16000

db.child("uploads").remove()

def stream_handler(message):
    print(message)
    if message["event"] == "put": #confirm it's a put
        if message["data"] == None:
            return
        message_data = message["data"]
        print('message_data', message_data)

        #handle placeholder data
        if message_data["type"] == "blank":
            pass
        elif message_data["type"] == "cover": #confirm it's a cover type
            link_to_image = message_data["image"] #save link to image
            image_path_storage = link_to_image[37:]
            storage.child(image_path_storage).download("downloaded.jpg", None)

            errors = []
            #cycle through all final images
            for fp in final_images:
                #append the resulting error to the list of errors
                errors.append(textbook_recognition("./downloaded.jpg",'../final_images/' + fp))

            min_index = np.argmin(errors) #get the index of the minimum error
            print('min error: ', errors[min_index])
            if errors[min_index] > 16000:
                print("------\nDOESN'T MEET THRESHOLD\n--------")
                pass
            print(errors)
            #print('min_index',min_index)

            isbn = final_images[min_index]
            isbn = isbn[:isbn.find('.jpg')]

            catalog_val = db.child("catalog").child(isbn).get().val()

            data = { "time":str(datetime.datetime.now()),
            "cover_image":catalog_val["cover_image"],
            "title":catalog_val["title"] }

            db.child("library").child(isbn).set(data)
            db.child("uploads").child(message["path"][1:]).remove()

        elif message_data["type"] == "quote":
            link_to_image = message_data["image"] #save link to image
            image_path_storage = link_to_image[37:]
            storage.child(image_path_storage).download("downloaded.jpg", None)

            description = quotation_maker('./downloaded.jpg')

            isbn = message["data"]["isbn"]
            try:
                cites = db.child("library").child(isbn).child("citations").get().val() #{0:"asdfasdf",1:"fdasfdsa" ... etc.}
                citation_counter = max(cites.values())+1
            except:
                citation_counter = 0
            data = {citation_counter:description}

            db.child("library").child(isbn).child("citations").set(data)


my_stream = db.child("uploads").stream(stream_handler)
