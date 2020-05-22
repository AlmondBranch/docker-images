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

# make another Elasticsearch API request to get the indexed PDF
result = elastic_client.get(index="pdf", doc_type='_doc', id=42)

# print the data to terminal
result_data = result["_source"]["data"]
print ("\nresult_data:", result_data, '-- type:', type(result_data))

# decode the base64 data (use to [:] to slice off
# the 'b and ' in the string)
decoded_pdf = base64.b64decode(result_data[2:-1]).decode("latin-1")
print ("\ndecoded_pdf:", decoded_pdf)

# take decoded string and make into JSON object
json_dict = json.loads(decoded_pdf)
print ("\njson_str:", json_dict, "\n\ntype:", type(json_dict))

# create new FPDF object
pdf = FPDF()

# build the new PDF from the Elasticsearch dictionary
# Use 'iteritems()` instead of 'items()' for Python 2
for page, value in json_dict.items():
    if page != "meta":
        # create new page
        pdf.add_page()
        pdf.set_font("Arial", size=14)

        # add content to page
        output = value + " -- Page: " + str(int(page)+1)
        pdf.cell(150, 12, txt=output, ln=1, align="C")
    else:
        # create the meta data for the new PDF
        for meta, meta_val in json_dict["meta"].items():
            if "title" in meta.lower():
                pdf.set_title(meta_val)
            elif "producer" in meta.lower() or "creator" in meta.lower():
                pdf.set_creator(meta_val)

# output the PDF object's data to a PDF file
pdf.output("/home/downloads/downloaded_from_elaticsearch.pdf").encode('latin-1')
