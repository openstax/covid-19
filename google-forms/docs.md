## Description

We were tasked with putting exercises for each chapter up into Google Forms so that High School teachers can create a quick homework assignment and have students answer at home.

To accomplish that, we did the following, with details below:

1. extract the exercises from the BakedHTML file as JSON files (1 per chapter)
1. upload the JSON files
1. run a Google Script with a timer to import the exercises


## Extract the Exercises

Here are a few limitations we ran into while trying to extract the exercises:

- Books include exercises from 2 different places: CNXML and exercises.openstax.org so the BakedHTML file is a spot that has both of them in a similar format (XHTML).
- Exercise markup is ambiguous... there is no good way to detect if an exercise is a multiple choice question.
- Google Forms does **not allow any** markup. No bold, no subscripts, no images, no Math.

To accomplish this step we did the following conversion:

1. read the BakedHTML from the `cnx-recipes/data/` directory (using the fetch/assemble/bake commands)
1. For each chapter:
    - Guess at the type of exercise (multiple choice or free answer) using a little pattern matching
    - Use an explicit list of end-of-chapter categories (e.g. `chapter-review` or `homework-problems`) to guess the type of exercise
    - Convert Simple math and markup into text (replacing things like fractions/subscripts/emphasis/links with plain text like `/` or `^` or `_..._` or the link URL)
    - Convert image references to either legacy.cnx.org/... URLs or retain the absolute URLs
    - group the exercises by category (e.g. `chapter-review` or `homework-problems`)
    - write the exercises out to a JSON file... the filename contains a sanitized version of the Chapter title
1. Output a CSV file with the following columns:
    - book name, category, chapter number, exercise number, reason, details
    - reason says if the conversion was successful, requires a little manual tweak (like attaching an image), or if it was not converted (e.g. due to Math being too complicated, or a table was in the question...)

### JSON file format

```js
// File: "{book_name} - Chapter {chapter_number} - {chapter_title}.json"
{ chapter: 8,
  categories: [
    { "data_uuid_key": ".review",
      title: "Review Questions",
      exercises: [
        { number: 1,
          type: "m", // Manually updated. Can be one of: "m", "p"
          stem: "What is the capitol of France?",
          stem_images: [ "one.png" ],
          options: [
             { option: "Dallas" }, 
             { option: "Paris",  option_images: ["eiffel.jpg"] }
           ]
       }
    ]
}
```

## Upload the JSON files
The `QuizFormGenerator` script looks for input JSON files in the Google Drive for it to process. Currently the location is hard coded and it parses all files in `QuizForms/exercises`. In addition, it expects a `new-names.json` file in the `QuizForms` folder which maps the name prefix of a JSON input to a user friendly title for the generated forms. For example, the following mapping file causes the script to map the input file `apbiology - Chapter 1 - The Study of Life.json` to the output form with name `Biology for AP® Courses - Chapter 1 - The Study of Life`:

```json
{
    "apbiology": "Biology for AP® Courses"
}
```

All JSON files should be uploaded to the Drive folder prior to executing the Google Script in the next step.

## run a Google Script on a timer
The current script implementation exposes two functions that can be invoked by the user:
* `quizFormGenerator` - This function processes JSON files found in the Drive up to a (hard coded) `batchCount`. Since Google limits the maximum execution time (depending on the account type and is [up to 30 minutes](https://developers.google.com/apps-script/guides/services/quotas)), the batchCount can be used to limit the maximum number of JSON files that get processed in a single invocation to try and avoid "orphan", partially generated forms.
* `makeTrigger` - This function simply creates a periodic timer that invokes the `quizFormGenerator`. Currently it is set to run every hour to avoid overlapping invocations (assuming a 30 minute maximum and with no available option between 30 minutes and an hour)

### Script execution overview
The general logic in the script is to build a form which corresponds to a JSON input file in the root of the Drive. Once complete, it moves the form to `QuizForms/forms`. Since `quizFormGenerator` is triggered multiple times, it uses the existing of a form in the folder to determine whether it should be skipped. So the general flow is:
* For each JSON file in `QuizForms/exercises`:
    * Check for the corresponding form name in `QuizForms/forms` using the mapping in `new-names.json`. If not found, generate the form, otherwise skip to the next JSON file.

To build all forms, a user can invoke `makeTrigger()` from the Google script UI and, over a few hours, all forms will get generated. The trigger is self-cleaning in that the script will delete the trigger on a run where no forms are generated. The status / logs from invocations can be found in the [Apps Script console](https://script.google.com/home/executions).

At the end of the run, depending on the value of `batchCount` there may be orphan forms in the root of the Drive which can be safely deleted.

### Running one-off builds
If additional JSON files are added after an initial build, users can either invoke `quizFormGenerator()` directly (if there are a small number of new forms) or use the timer function again. Some notes based on experiences with the current script implementation:
* If JSON files are added to `QuizForms/exercises` and forms are reorganized / moved from `QuizForms/forms`: The script will process the new JSON files by happenstance since the APIs used return files in chronological order, but then proceed to rebuild the older JSON files since the existence check fails. So you'll either want to monitor and kill the job once it starts generating old forms or move the old JSON files so they aren't picked up by the script.