import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import datetime
from google.cloud import storage
from collections import Counter

# global parameters
radius = 1
absolute_threshold = 7
fractional_threshold = 0.75
currentTime = datetime.datetime.now()

#===========================================================================================================================================================================

# cloud storage functions
storage_client = storage.Client()

def download_blob(bucket_name, source_blob_name, destination_file_name):
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(source_blob_name)
    blob.download_to_filename(destination_file_name)
    return destination_file_name

def delete_blob(bucket_name, blob_name):
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(blob_name)

    blob.delete()

#===========================================================================================================================================================================

# firetore database work
cred = credentials.Certificate('auth.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

# deletes all challan requests of passed registration number
def garbage_collect(registration_number):
    docs = db.collection(u'Challan Requests').where(u'registration_number', u'==', data["registration_number"])
    for doc in docs:
        db.collection(u'Challan Requests').document(doc.id).delete()

#listener
def on_snapshot(doc_snapshot, changes, read_time):
    try:
        #print(u'{}'.format(type((doc_snapshot[-1])))) #ignore
        data = doc_snapshot[-1].to_dict()
        #print(data["location"].latitude, data["location"].longitude) #ignore
        rr = data.get("proof_resource_reference", None)
        # if proof resource is provided
        if rr! = None:
            # download resource
            download_blob("proofs_offense", rr, "temp.mp4")
            # check validity
            model = rac_bansal.ml.model() #__________________________________________________________________________________________to be implemented
            value = model.predict("video/temp.mp4") #________________________________________________________________________________to be implemented
            # if invalid delete
            if value == False:
                delete_blob("proofs_offense", rr)
                rr = None

        # counting the number of reports and listing all people who reported
        reg_number_query = db.collection(u'Challan Requests').where(u'registration_number', u'==', data["registration_number"])
        count_reports = 0
        reporters = []
        latitude_min = data["location"].latitude - radius
        latitude_max = data["location"].latitude + radius
        longitude_min = data["location"].longitude - radius
        longitude_max = data["location"].longitude + radius
        for doc in reg_number_query:
            temp_data = doc.to_dict()
            lat = temp_data["location"].latitude
            long = temp_data["location"].longitude
            if lat>=latitude_min and lat<=latitude_max and long>=longitude_min and long<=longitude_max:
                count_reports += 1
                reporters.append(data["reporter"])

        # counting active users in area
        active_users_in_area = 0
        active_users = db.collection(u'Active Users')
        for doc in active_users:
            temp_data = doc.to_dict()
            lat = temp_data["location"].latitude
            long = temp_data["location"].longitude
            if lat>=latitude_min and lat<=latitude_max and long>=longitude_min and long<=longitude_max:
                active_users_in_area += 1

        # checking validity of challan based on thresholds
        if count_reports >= absolute_threshold and (count_reports/active_users_in_area)>fractional_threshold:
            # if true add the challan and delete all challan requests
            print("valid report, challan added")
            data["reporters"] = reporters
            del data["reporter"]
            db.collection(u'challan').add(data)
            garbage_collect(data["registration_number"])
        else:
            print('Threshold not crossed')

    # required if block for first iteration since len is 0
    except IndexError:
        pass

# deploying listener
doc_watch = db.collection(u'Challan Requests').where(u'timestamp', u'>', currentTime).on_snapshot(on_snapshot)
