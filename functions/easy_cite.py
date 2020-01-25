from skimage.measure import compare_ssim as ssim
import numpy as np
import cv2

from PIL import Image

import time

#image similarity
#
#
#input an image output a similarity score
def textbook_recognition(imgA,imgB):
    size = 300,200

    #force dimensions to match
    imageA = Image.open(imgA)
    imageB = Image.open(imgB)
    
    im_resizedA = imageA.resize(size, Image.ANTIALIAS)
    im_resizedA.save("my_image_resized.png", "PNG")
    im_resizedA = np.array(im_resizedA)

    im_resizedB = imageB.resize(size, Image.ANTIALIAS)
    im_resizedB.save("my_image_resizedb.png", "PNG")
    im_resizedB = np.array(im_resizedB)

    # the 'Mean Squared Error' between the two images is the
    # sum of the squared difference between the two images;
    # NOTE: the two images must have the same dimension
    err = np.sum((im_resizedA.astype("float") - im_resizedB.astype("float")) ** 2)
    err /= float(im_resizedA.shape[0] * im_resizedA.shape[1])

    return err

final_images = [ '../images/human_rights_final.JPG'
                ,'../images/communications_final.JPG'
                ,'../images/calculus_final.JPG']

images = ['../images/sunset_test.jpg'
          ,'../images/communications_phone.jpg'
          ,'../images/human_rights_reader_phone.jpg'
          ,'../images/math1.jpg']



#for fp in final_images:
#    for ip in images:
#        print('final:',fp,'image:',ip)
#        print('score: ', textbook_recognition(fp, ip))
#

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
    print('Texts:')

    for text in texts:
        print('\n"{}"'.format(text.description))

        vertices = (['({},{})'.format(vertex.x, vertex.y)
                    for vertex in text.bounding_poly.vertices])

        print('bounds: {}'.format(','.join(vertices)))

    return texts

quotation_maker('../images/math1.jpg')
