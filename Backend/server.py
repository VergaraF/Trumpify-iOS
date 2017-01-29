# -*- coding: utf-8 -*-
from __future__ import print_function, unicode_literals

import sys
import semantria
import uuid
import time
from flask import Flask, request, send_from_directory
from flask_restful import Resource, Api
import json
import text_generation as trumpAI

app = Flask(__name__)
api = Api(app)


def onRequest(sender, result):
    print("\n", "REQUEST: ", result)

def onResponse(sender, result):
    print("\n", "RESPONSE: ", result)

def onError(sender, result):
    print("\n", "ERROR: ", result)

def onDocsAutoResponse(sender, result):
    print("\n", "AUTORESPONSE: ", len(result), result)

def onCollsAutoResponse(sender, result):
    print("\n", "AUTORESPONSE: ", len(result), result)

def getDocumentThemes(textSubmitted):
    print("Semantria Detailed mode demo ...")
    print("")

    # the consumer key and secret
    key = "e6376d5a-2175-4c05-930d-83d1ff52453b"
    secret = "3c4c4ae6-94fe-42da-800c-828fa991318f"

    # Task statuses
    TASK_STATUS_UNDEFINED = 'UNDEFINED'
    TASK_STATUS_FAILED = 'FAILED'
    TASK_STATUS_QUEUED = 'QUEUED'
    TASK_STATUS_PROCESSED = 'PROCESSED'


    # Creates JSON serializer instance
    serializer = semantria.JsonSerializer()
    # Initializes new session with the serializer object and the keys.
    session = semantria.Session(key, secret, serializer, use_compression=True)

    # Initialize session callback handlers
    # session.Request += onRequest
    # session.Response += onResponse
    session.Error += onError
    # session.DocsAutoResponse += onDocsAutoResponse
    # session.CollsAutoResponse += onCollsAutoResponse

    subscription = session.getSubscription()

    initialTexts = []
    results = []
    tracker = {}
    documents = []

    doc_id = str(uuid.uuid4())
    documents.append({'id': doc_id, 'text': textSubmitted})
    tracker[doc_id] = TASK_STATUS_QUEUED

    res = session.queueBatch(documents)

    if res in [200, 202]:
        print("{0} documents queued successfully.".format(len(documents)))
        documents = []

    if len(documents):
        res = session.queueBatch(documents)
        if res not in [200, 202]:
            print("Unexpected error!")
            sys.exit(1)
        print("{0} documents queued successfully.".format(len(documents)))

    print("")

    while len(list(filter(lambda x: x == TASK_STATUS_QUEUED, tracker.values()))):
        time.sleep(0.5)
        print("Retrieving your processed results...")

        response = session.getProcessedDocuments()
        for item in response:
            if item['id'] in tracker:
                tracker[item['id']] = item['status']
                results.append(item)

    print("")

    #print(textSubmitted)

    for data in results:
        # Printing of document sentiment score
        print("Document {0} / Sentiment score: {1}".format(data['id'], data['sentiment_score']))


        print(data)
        if "auto_categories" in data:
            for auto_categories in data["auto_categories"]:
                for categories in auto_categories["categories"]:
                    if categories["sentiment_score"] == data["sentiment_score"]:
                        return (categories["title"])

        return("Nothing was found")


class inputAnalysisAndAIResponse(Resource):
    def get(self, text):
        # perform text analysis
        # get value from trump AI
        topic = getDocumentThemes(text).replace("_", " ")
        if(topic == "Nothing was found"):
            return "Believe me folks, I didn't receive anything to respond to... but I can give you some alternative facts if you'd like."
        print (topic)

        sentenceByAI = trumpAI.acceptRequest(topic)
        print(sentenceByAI)

        return sentenceByAI

api.add_resource(inputAnalysisAndAIResponse, '/trump/<string:text>')

if __name__=='__main__':
   # app.run(host='142.157.101.138')
    app.run(host='10.0.0.151')


#getDocumentThemes("I had an awful day at work")

