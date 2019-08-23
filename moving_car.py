import numpy as np
import cv2
import matplotlib.pyplot as plt
import pandas as pd

import keras 
from keras.layers import *
from keras.models import Sequential, Model

from keras.applications.inception_v3 import InceptionV3, decode_predictions
from keras.applications.mobilenet import MobileNet, decode_predictions

from keras.applications.inception_v3 import preprocess_input

import os
from PIL import Image
import glob
from pickle import dump, load

from keras.preprocessing import image

class moving_cars:
    def __init__(self, video):
        self.video = video 
        
    def preprocess(self,path):
        img = image.load_img(path, target_size=(224, 224))
        x = image.img_to_array(img)
        x = np.expand_dims(x, axis=0)
        x = preprocess_input(x)
        return x
    
    def prediction(self):
        cars = ['streetcar', 'trailer_truck', 'freight_car', 'cab', 'hack', 'taxi', 'taxicab', 'racer', 'race_car', 'racing_car', 'jeep', 'landrover', 'minivan', 'beach_wagon', 'station_wagon', 'wagon', 'estate_car', 'beach_waggon', 'station_waggon', 'waggon', 'car_wheel']
        model = MobileNet(weights='imagenet')
        model_new = Model(model.input, model.layers[-1].output)
        predictions = []
        seconds = 1
        fps = self.video.get(cv2.CAP_PROP_FPS) # Gets the frames per second
        path = 'lat_img.jpg'
        print(fps)
#         ret, frame = self.video.read()
#         print(ret)
#         print(type(frame))
#         plt.imshow(frame)
        multiplier = fps * seconds
        count = 0
        
        while(self.video.isOpened() == False):
            print(0)

        while(self.video.isOpened() == True):
#             print(1)
            ret, frame = self.video.read()
#           frame = self.preprocess(frame)
            if(ret == True):
                frameId = int(round(self.video.get(1)))

                if(frameId % round(multiplier) == 0):
                    cv2.imwrite(path, frame)
                    count += 1
                    frame = self.preprocess(path)
                    dec_preds = decode_predictions(model_new.predict(frame), top=3)[0]
                    print(dec_preds)
                    flag = 0
                    # time.sleep(1)
                    for i in range(len(dec_preds)):
                        if(dec_preds[i][1] in cars):
                            flag = 1
                    predictions.append(flag)

                if(count>=5):
                    self.video.release()
                    break
            
        thresh = 0
            
        for i in range(len(predictions)-3):
            if thresh >= 3:
                break
            for j in range(i, i+3):
                if predictions[j] == 1:
                    thresh += 1
                else:
                    thresh = 0
                        
        if thresh>=3:
            return True, predictions
        else:
            return False, predictions