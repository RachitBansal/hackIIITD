import numpy as np
import os
import cv2
from keras.layers import *

def preprocess(self,img):
    np.resize(img,(299,299))
    x = image.img_to_array(img)
    x = np.expand_dims(x, axis=0)
    x = preprocess_input(x)
    return x

car_cascade = cv2.CascadeClassifier('car.xml')

video = cv2.VideoCapture('moving_cars.mp4')

while True:
	ret, frame = video.read()
	gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY) 
	cars = car_cascade.detectMultiScale(gray, 1.1, 1) 
	print(cars)
    
	for (x,y,w,h) in cars: 
		cv2.rectangle(frame,(x,y),(x+w,y+h),(0,0,255),2) 

	cv2.imshow('video2', frame)
	if cv2.waitKey(33) == 27: 
		break

    # video.release()

	# cv2.destroyAllWindows()