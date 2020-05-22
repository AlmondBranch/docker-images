#!/bin/bash

curl -XPUT "localhost:9200/_ingest/pipeline/attachment?pretty" -H 'Content-Type: application/json' -d'
{
  "description" : "Field for processing file attachments",
  "processors" : [
    {
      "attachment" : {
        "field" : "data"
      }
    }
  ]
}
