require 'csv'
require 'pry'

ad_words_input = CSV.read(ARGV[0])
word_bank_data = CSV.read(ARGV[1], { headers: true,
                           header_converters: :symbol })
class AdWordScript
  attr_reader :ad_words_input,
              :word_bank_data
  attr_accessor :word_banks,
                :output_data
  def initialize(ad_words_input, word_bank_data)
    @ad_words_input = ad_words_input
    @word_bank_data = word_bank_data
    @word_banks = {}
    @output_data = {unsorted: []}
    setup
    check_dictionaries_and_assign_to_categories
  end

  def setup
    @word_bank_data.headers.each do |header|
      @word_banks[header] = @word_bank_data[header].compact.map { |phrase| phrase.downcase }
    end

    @word_bank_data.headers.each do |header|
      @output_data[header] = []
    end
  end

  def check_dictionaries_and_assign_to_categories
    @ad_words_input.each do |ad_words|
      current_words = ad_words.first.split(" ")
      remaining = current_words.clone
      until remaining == []
        @word_banks.each do |type, ad_phrases|
          if ad_phrases.include?(current_words.join(" "))
            @output_data[type] = @output_data[type] << current_words.join(" ")
            remaining = remaining - current_words
            current_words = remaining.clone
          end
        end
        if current_words.length == 1 #put unclassified single words in unsorted
          @output_data[:unsorted] = @output_data[:unsorted] + current_words
          remaining = []
        else
          current_words.pop
        end
      end
    end
  end
end

ad = AdWordScript.new(ad_words_input, word_bank_data)

ad.output_data = ad.output_data.each { |cat, group| ad.output_data[cat] = group.uniq }

longest_column = ad.output_data.values.max_by(&:length)

CSV.open('output_file.csv', 'w', headers: true) do |csv_object|
  csv_object << ad.output_data.keys #headers
  longest_column.each.with_index do |col_one_cell, index|
    row = ad.output_data.values.map do |column|
      column[index]
    end
    csv_object << row #data rows
  end
end
