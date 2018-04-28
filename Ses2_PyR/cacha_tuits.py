import config
import csv

import tweepy
import json

authentication = tweepy.OAuthHandler(config.consumer_key, config.consumer_secret)
authentication.set_access_token(config.access_token, config.access_secret)

api = tweepy.API(authentication)

#en config.py van las credenciales

from tweepy import Stream
from tweepy.streaming import StreamListener

class TwitterListener(StreamListener):

    def on_data(self,data):
        tweet=json.loads(str(data))
        print(tweet['text'])
        with open("datos/streamin.json","a") as archivo:
            archivo.write(json.dumps(tweet))
            archivo.write('\n')
        return(True)

    def on_error(self, status):
        print(status)



try:
            twitter_stream = Stream(authentication, TwitterListener())
            twitter_stream.filter(track=['#DebateINE', '#DebateDelDebate','anaya'], async=True)

except:
            pass



