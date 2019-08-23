import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import datetime

cred = credentials.Certificate('auth.json')
firebase_admin.initialize_app(cred)

db = firestore.client()
#'google.cloud.firestore_v1.document.DocumentSnapshot'
data = {
    u'location':firebase_admin.firestore.GeoPoint(28,77),
    u'registration_number':"DL4C1234",
    u'challan_code':"197 A",
    u'timestamp': datetime.datetime.now(),
    u'reporter': "987654321"
    u'proof_resource_reference' : "abcd"
}
db.collection("Challan Requests").add(data)
