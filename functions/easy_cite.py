from google.cloud import vision
import io

#image similarity
#
#
#input an image output a similarity score
def textbook_recognition():
    pass

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

quotation_maker('../math1.jpg')
