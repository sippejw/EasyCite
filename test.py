from google.cloud import vision

image_uri = "gs://digital-ethos-200423.appspot.com/tmp_quotes/IMG_0640.JPG" 
client = vision.ImageAnnotatorClient()
image = vision.types.Image()
image.source.image_uri = image_uri

response = client.text_detection(image=image)

for text in response.text_annotations:
    print('=' * 79)
    print(f'"{text.description}"')
    vertices = [f'({v.x},{v.y})' for v in text.bounding_poly.vertices]
    print(f'bounds: {",".join(vertices)}')
