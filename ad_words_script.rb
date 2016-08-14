require 'RubyXL'
require 'csv'
require 'pry'

class AdWordScript
  attr_reader :ad_words_input,
              :dictionaries
  attr_accessor :word_banks,
                :output_data

  def initialize(ad_words_input, dictionaries)
    @ad_words_input = ad_words_input
    @dictionaries = dictionaries
    @word_banks = {}
    @output_data = {WIP: []}
    setup_word_banks_and_output_data_storages
  end

  def setup_word_banks_and_output_data_storages
    setup_word_banks
    setup_output_data_stores
  end

  def setup_word_banks
    dictionaries.worksheets.each do |sheet|
      sheet.each do |row|
        if !@word_banks[sheet.sheet_name]
          @word_banks[sheet.sheet_name] = {}
        else
          @word_banks[sheet.sheet_name][row.cells[0].value] = row.cells[1].value
        end
      end
    end
  end

  def setup_output_data_stores
    dictionaries.worksheets.each do |sheet|
      output_category = sheet.sheet_name.gsub(' Dictionary', '')
      output_data[output_category] = []
    end
  end

  def check_dictionaries_and_assign_to_categories
    @ad_words_input.each.with_index do |ad_words, index|
      current_words = ad_words.first
      categorize_words(current_words, index)
      fill_in_blanks(index)
    end
  end

  def categorize_words(current_words, index)
    remaining = current_words.clone
    last_word_attempted = ""
    until remaining == ""
      last_word_attempted = current_words.clone
      @word_banks.each do |type, ad_phrases|
        match = find_ad_phrase_matches(ad_phrases.keys, current_words)
        if match
          output_type = type.gsub(' Dictionary', '')
          @output_data[output_type] << ad_phrases[match]
          remaining = " #{current_words} ".sub(" #{match} ", " ").split.join(" ")
          current_words = remaining.clone # re-run with words not yet sorted
        end
      end
      if current_words == last_word_attempted
        if @output_data[:WIP][index]
          @output_data[:WIP][index] << " " + current_words
        else
          @output_data[:WIP][index] = current_words
        end
        remaining = remaining.sub(current_words, "")
        current_words = remaining.clone
      end
    end
  end

  def find_ad_phrase_matches(phrases, current_words)
    phrases.detect do |phrase|
      !" #{current_words} ".scan(" #{phrase} ").empty?
    end
  end

  def fill_in_blanks(index)
    @output_data.each do |output_type, output_words|
      output_words[index] = nil unless output_words[index]
    end
  end

  def write_to_csv(file_name)
    check_dictionaries_and_assign_to_categories
    CSV.open(file_name, 'w', headers: true) do |csv_object|
      csv_object << ["Original AdWords"] + @output_data.keys #headers
      longest_column = @output_data.values.max_by(&:length) #table height
      longest_column.each.with_index do |col_one_cell, index|
        row = ad_words_input[index] || []
        row += @output_data.values.map do |column|
          column[index]
        end
        csv_object << row #data rows
      end
    end
  end
end

if __FILE__ == $0
  ad_words_input = CSV.read(ARGV[0])
  dictionaries = RubyXL::Parser.parse(ARGV[1])

  new_script = AdWordScript.new(ad_words_input, dictionaries)

  new_script.write_to_csv('output_file.csv')
end
