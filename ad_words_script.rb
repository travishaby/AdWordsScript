require 'csv'
require 'pry'

ad_words_input = CSV.read(ARGV[0])
split_on_spaces = ad_words_input.map {|keywords| keywords.first.split(" ")}

word_bank_data = CSV.read(ARGV[1], {headers: true,
                                header_converters: :symbol})

word_banks = {}
word_bank_data.headers.each do |header|
  word_banks[header] = word_bank_data[header].compact
end

output_csv = CSV.generate do |csv|
  #csv << ["row", "of", "CSV", "data"]
  #csv << ["another", "row"]
  # ...
end
binding.pry
