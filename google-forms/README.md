This code takes the exercises in our texbooks and generates Google Forms. There are several limitations, listed below.

# Overview

We take the Single BakedHTML file for each book, find the exercises (using xslt), guess if they are multiple choice, write them out to JSON, upload to Google Drive, and run a Google Script to convert them into Forms.

# Instructions

1. baked books using cnx-recipes
1. generate JSON from those books using saxon
  - this also generates a CSV file with exercises that were not converted, or need images attached, or other problems
1. upload the JSON files into Google Drive
1. run a Google Script to convert the JSON files into Forms
1. repeat the last step because Google Scripts time out after ~~5~~ _30_ minutes


# Limitations

- questions do not allow any formatting (not even subscripts). So we translate math as best we can to plain text and log int oa CSV file 
- ...