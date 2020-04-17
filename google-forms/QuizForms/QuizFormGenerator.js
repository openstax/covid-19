// This is a Google AppScript file
// It requires that the user have a folder named QuizForms
// with the JSON files in it.

function makeTrigger() {
    ScriptApp.newTrigger('quizFormGenerator')
        .timeBased()
        .everyHours(1)
        .create();
    return;
}

function quizFormGenerator() {
    var batchCount = 100;
  
    // Generate Google Forms Quizzes from json
    // -----------------------------------------------------------------------------------------------
    var folders = DriveApp.getFoldersByName('QuizForms');
    var quizForms = (folders.hasNext() ? folders.next() : null);
    
    // Get exercise renaming file
    var renameFile = quizForms.getFilesByName('new-names.json');
    renameFile = (renameFile.hasNext() ? renameFile.next() : null);
    var content = renameFile.getBlob().getDataAsString();
    var nameMap = JSON.parse(content);
  
    // Get exercise json files
    folders = quizForms.getFoldersByName('exercises');
    var jsonFolder = (folders.hasNext() ? folders.next() : null);

    if (!jsonFolder) return;

    var jsonFiles = jsonFolder.getFiles();

    // Get existing forms
    folders = quizForms.getFoldersByName('forms');
    var formFolder = (folders.hasNext() ? folders.next() : null);

    if (!formFolder) {
      formFolder = quizForms.createFolder('forms');
    }

    var formFiles = formFolder.getFiles();
    var formNames = new Set()
    while (formFiles.hasNext()) {
        var file = formFiles.next();
        var fileName = file.getName();
        //Logger.log(`found ${fileName}`);
        formNames.add(fileName);
    }
    
    // Generate forms if they don't exist
    while (jsonFiles.hasNext()) {
        var file = jsonFiles.next();
        var fileName = file.getName().split('.')[0];
        //if (formNames.has(fileName)) {
        if (formNames.has(constructLongFormName_(fileName, nameMap))) {
            Logger.log(`found ${fileName}`);
        } else {
            Logger.log(`processing ${fileName}`);
            var quiz = chapterGen_(file, nameMap);
            moveFile_(quiz, formFolder);
            if (--batchCount === 0) break;
        }
    }

    if (batchCount === 100) {
        deleteTriggers_();
    }
  
    Logger.log(\"task complete\")
    return;
}

function deleteTriggers_() {
  var triggers = ScriptApp.getProjectTriggers();
  for (var indx = 0; indx < triggers.length; indx++) {
    ScriptApp.deleteTrigger(triggers[indx]);
  }
}

function constructLongFormName_(title, nameMap) {
  // Example title: \"apbiology - Chapter 1 - The Study of Life\"
  // Example nameMap: {\"apbiology\": \"Biology for AP® Courses\"}
  
  var splitTitle = title.split(' - ');
  splitTitle[0] = nameMap[splitTitle[0]];
  return splitTitle.join(' - ');
}

function chapterGen_(file, nameMap) {
    if (!file) return;

    var title = file.getName().split('.')[0];
    //Logger.log(title);
    title = constructLongFormName_(title, nameMap)

    var content = file.getBlob().getDataAsString();

    var data = JSON.parse(content);

    // Create form
    // -----------------------------------------------------------------------------------------------
    var quiz = FormApp.create(title);
    quiz.setIsQuiz(true);

    var opening_text = \"Don't forget to wash your hands!\";

    quiz.addSectionHeaderItem()
        .setTitle(opening_text);

    for (var category of data.categories) {

        quiz.addPageBreakItem()
            .setTitle(category.title);

        for (var exercise of category.exercises) {

            if (typeof exercise.stem === 'undefined') continue;
            if (exercise.stem === \"\") continue;
            var item;
            var stem = exercise.stem;

            // Add image urls to stem
            // -------------------------------------------------------------------------------------------
            if (typeof exercise.stem_images !== 'undefined') {
                stem = `${stem}\\n====================[ REPLACE IMAGES BELOW ]====================\\n${exercise.stem_images.join(\"\\n\")}`;
            }


            // Create exercise
            // -------------------------------------------------------------------------------------------
            if (typeof exercise.options !== 'undefined') { // Multi-part or multiple choice
                //Logger.log(exercise.type);

                switch (exercise.type) {

                    case \"m\":
                    case \"x\":
                        // Multiple choice / Checkbox
                        // ---------------------------------------------------------------------------------------
                        item = quiz.addMultipleChoiceItem()
                            .setTitle(stem)
                            .setRequired(false)
                            .setPoints(1);

                        var options = exercise.options.map((option, i) => item.createChoice(
                            `${charIndex_(i)}. ${option.option}`,
                            answerKey_(exercise.answer, i)
                        ));

                        item.setChoices(options);

                        break;

                    case \"b\":
                        // True / False
                        // ---------------------------------------------------------------------------------------    
                        quiz.addSectionHeaderItem()
                            .setTitle(stem);

                        exercise.options.map(option => {
                            item = quiz.addMultipleChoiceItem()
                                .setTitle(option.option)
                                .setRequired(false)
                                .setPoints(1);

                            var options = [\"True\", \"False\"].map((option) => item.createChoice(
                                option,
                                false
                            ));

                            item.setChoices(options);

                        });

                        break;

                    case \"p\":
                    default:
                        // Multi-part written response
                        // ---------------------------------------------------------------------------------------
                        quiz.addSectionHeaderItem()
                            .setTitle(stem);

                        exercise.options.map(option => {
                            quiz.addParagraphTextItem()
                                .setTitle(option.option)
                                .setRequired(false)
                                .setPoints(1);
                        });

                        break;
                }
            } else {
                // Written response
                // -------------------------------------------------------------------------------------------
                quiz.addParagraphTextItem()
                    .setTitle(stem)
                    .setRequired(false)
                    .setPoints(1);
            }

            // Add image items
            // -------------------------------------------------------------------------------------------
            // if (typeof exercise.stem_images !== 'undefined') {
            //     var img = UrlFetchApp.fetch(exercise.stem_images[0]);

            //     quiz.addImageItem()
            //         .setImage(img);
            // }
        }
    }
    return quiz;
}

function charIndex_(i) {
    return String.fromCharCode('A'.charCodeAt(0) + i);
}

function answerKey_(key, i) {
    if (typeof key === 'undefined') return false;
    key = key.split(\" and \")
    //Logger.log(`${key} ${key.includes[charIndex_(i)]}`);
    return key.includes(charIndex_(i));
}

function moveFile_(item, folder) {
  var id = item.getId();
  var file = DriveApp.getFileById(id);
  file.getParents().next().removeFile(file);
  folder.addFile(file);
  return;
}