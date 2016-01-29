require 'csv'
require 'pry'

class AdWordScript
  attr_reader :ad_words_input,
              :word_bank_data
  attr_accessor :word_banks,
                :output_data

  def initialize(ad_words_input, word_bank_data)
    @ad_words_input = ad_words_input
    @word_bank_data = word_bank_data
    binding.pry
    @word_banks = {}
    @output_data = {unsorted: []}
    setup_word_banks_and_output_data_storages
  end

  def setup_word_banks_and_output_data_storages
    word_bank_data.headers.each do |header|
      word_banks[header] = word_bank_data[header].compact.map(&:downcase)
    end
    word_bank_data.headers.each do |header|
      output_data[header] = []
    end
  end

  def check_dictionaries_and_assign_to_categories
    @ad_words_input.each.with_index do |ad_words, index|
      current_words = ad_words.first.split(" ")
      categorize_words(current_words, index)
      @output_data.each do |output_type, output_words|
        output_words[index] = nil unless output_words[index]
      end
    end
  end

  def categorize_words(current_words, index)
    remaining = current_words.clone
    last_word_attempted = ""
    until remaining == []
      last_word_attempted = current_words.clone
      @word_banks.each do |type, ad_phrases|
        if ad_phrases.include?(current_words.join(" "))
          @output_data[type] << current_words.join(" ")
          remaining = remaining - current_words
          current_words = remaining.clone # re-run with words not yet sorted
        end
      end
      if current_words.length > 1
        current_words.pop
      elsif current_words == last_word_attempted
        if @output_data[:unsorted][index]
          @output_data[:unsorted][index] << " " + current_words.join(" ").capitalize
        else
          @output_data[:unsorted][index] = current_words.join(" ").capitalize
        end
        remaining = remaining - current_words
        current_words = remaining.clone # re-run with words not yet sorted
      end
    end
  end

  def write_to_csv(file_name)
    check_dictionaries_and_assign_to_categories
    CSV.open(file_name, 'w', headers: true) do |csv_object|
      csv_object << @output_data.keys #headers
      longest_column = @output_data.values.max_by(&:length) #table height
      longest_column.each.with_index do |col_one_cell, index|
        row = @output_data.values.map do |column|
          column[index]
        end
        csv_object << row #data rows
      end
    end
  end
end

if __FILE__ == $0
  ad_words_input = CSV.read(ARGV[0])
  word_bank_data = CSV.read(ARGV[1], { headers: true,
                             header_converters: :symbol })

  new_script = AdWordScript.new(ad_words_input, word_bank_data)

  new_script.write_to_csv('output_file.csv')
end
