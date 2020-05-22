#!/usr/bin/env python3
#-*- coding: utf-8 -*-

# import libraries to help read and create PDF
import PyPDF2
from fpdf import FPDF
import base64
import json

# import the Elasticsearch low-level client library
from elasticsearch import Elasticsearch

# create a new client instance of Elasticsearch
elastic_client = Elasticsearch(hosts=["localhost"])

# get the PDF path and read the file
file = "pcm_ieee_micro10.pdf"
read_pdf = PyPDF2.PdfFileReader(file, strict=False)
print (read_pdf)

# get the read object's meta info
pdf_meta = read_pdf.getDocumentInfo()

# get the page numbers
num = read_pdf.getNumPages()
print ("PDF pages:", num)

# create a dictionary object for page data
all_pages = {}

# put meta data into a dict key
all_pages["meta"] = {}

# Use 'iteritems()` instead of 'items()' for Python 2
for meta, value in pdf_meta.items():
    print (meta, value)
    all_pages["meta"][meta] = value

# iterate the page numbers
for page in range(num):
    data = read_pdf.getPage(page)
    #page_mode = read_pdf.getPageMode()

    # extract the page's text
    page_text = data.extractText()

    # put the text data into the dict
    all_pages[page] = page_text

# create a JSON string from the dictionary
json_data = json.dumps(all_pages)
print ("\nJSON:", json_data)

# convert JSON string to bytes-like obj
bytes_string = bytes(json_data, 'latin-1')
print ("\nbytes_string:", bytes_string)

# convert bytes to base64 encoded string
encoded_pdf = base64.b64encode(bytes_string)
encoded_pdf = str(encoded_pdf)
print ("\nbase64:", encoded_pdf)

# put the PDF data into a dictionary body to pass to the API request
body_doc = {"data": encoded_pdf}

# call the index() method to index the data
elastic_client.delete(index="pdf", doc_type="_doc", id="42")
result = elastic_client.index(index="pdf", doc_type="_doc", id="42", body=body_doc)

# print the returned sresults
print ("\nindex result:", result['result'])
