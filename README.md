# AdWordsScript
This script is used to sort strings from google adwords into categories based
on category classifications of ad words provided to the script as a reference.

## Running the Script
To run the script, you will need an input `.csv` file in the expected format
(see `InputFile.csv`) as well as a dictionary `.xlsx` file (see `dictionaries/NewDictionary.xlsx`)
for the script to reference.

You will need to have Ruby installed and be able to run it from the command
line. For example running

`ruby ad_words_script.rb InputFile.csv dictionaries/NewDictionary.xlsx`

will run the script and generate a sorted output called `output_file.csv`.
