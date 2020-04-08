import json
import os
import tempfile

from google.cloud import storage

storage_client = storage.Client()

def perform_recognition(filename):
    # TODO:
    pass

def recognize_license_plate(request):
    request_json = request.get_json(silent=True)

    if not request_json:
        raise ValueError("JSON is invalid")

    if 'bucket' in request_json and 'image_path' in request_json:
        bucket_name = request_json['bucket']
        image_path = request_json['image_path']
    else:
        raise ValueError("Missing 'bucket' or 'image_path' property")

    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(image_path)
    temp = tempfile.NamedTemporaryFile()
    blob.download_to_file(temp)

    return perform_recognition(temp.name)