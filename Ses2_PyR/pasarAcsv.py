import csv
import json

fields = ['created_at', 'user', 'text']

tweets = []
with open("datos/streamin.json") as infile:
    for line in infile:
        tweet= json.loads(line)
        information = []
        for field in fields:
            if field not in tweet:
                information.append('')
            elif field == 'user':
                information.append(tweet['user']['screen_name'])
                information.append(tweet['user']['id_str'])
            else:
                information.append(tweet[field])
        tweets.append(information)

with open("datos/streamin.csv", "w",encoding='utf-16') as outfile:
    csvwriter = csv.writer(outfile)
    csvwriter.writerow(['created_at', 'screen_name','id', 'text']) 
    csvwriter.writerows(tweets)
