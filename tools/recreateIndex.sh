#!/usr/bin/env bash

curl -X DELETE "localhost:9200/blargh2?pretty"

curl -X PUT "localhost:9200/blargh2/?pretty" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "dynamic_templates": [
      {
        "float": {
          "match_mapping_type": "long",
          "mapping": {
            "type": "float"
          }
        }
      }
    ]
  }
}'
