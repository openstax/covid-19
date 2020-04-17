This code takes the exercises in our texbooks and generates Google Forms. There are several limitations, listed below.

# Overview

We take the Single BakedHTML file for each book, find the exercises (using XSLT), guess if they are multiple choice, write them out to JSON, upload to Google Drive, and run a Google Script to convert them into Forms.

# Outputs

- Google Drive with all the Forms
- [Spreadsheet with conversion problems](https://docs.google.com/spreadsheets/d/1HZ1ZEiTbSzOXeY11QR-tu46kzimy1WihT9J0B2LG4cM/edit#gid=546143196) (manually updated)

# Details

[./docs.md](./docs.md) contains more in-depth information on how we solved the problem.

# Instructions

1. Install [saxon-HE](https://saxonica.com/download/java.xml) (`brew install saxon`)
1. baked books using [cnx-recipes](https://github.com/openstax/cnx-recipes#create-a-baked-pdf-for-a-new-book)
1. run `./extract-exercises.bash` which generates JSON from those books using XSLT
  - this also generates a CSV file with exercises that were not converted, or need images attached, or other problems
1. upload the QuizForms directory to Google Drive
1. upload the JSON files to a directory called exercises in QuizForms
1. run the startGenerate function to generate Google Forms for each JSON file


# Limitations

- questions do not allow any formatting (not even subscripts). So we translate math as best we can to plain text and log int oa CSV file 
- images are allowed but there does not seem to be a way to add them with the Google Forms API
- ...