rm answers.txt

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

for filename in $(ls ./exercises/*.json); do
    jq '.[].categories[].exercises[].answer' ${filename} >> answers.txt
done

IFS=${SAVEIFS}

echo "Answers: $(egrep --ignore-case '"a"|"b"|"c"|"d"|"e"' answers.txt | wc -l)"
echo "Total questions: $(cat answers.txt | wc -l)"