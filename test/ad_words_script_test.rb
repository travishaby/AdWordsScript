require 'minitest/autorun'
require 'minitest/emoji'
require './ad_words_script.rb'

class AdWordsScriptTest < Minitest::Test
  def setup
    @ad = AdWordScript.new(CSV.read("InputFile.csv"),
                           CSV.read("./dictionaries/Columns.csv", { headers: true,
                                             header_converters: :symbol }))
  end

  def test_it_has_word_banks_stored
    category = :promo
    words_in_category = ["on sale", "discount", "cheap", "coupon"]
    assert_equal @ad.word_banks[category], words_in_category
  end

  def test_it_has_output_hash_with_category_headers
    headers = [:unsorted, :brand_terms, :item, :feature, :duty,
               :competitor, :color, :material, :collection, :size,
               :gender, :promo, :misspellings]
    assert_equal @ad.output_data.keys, headers
  end

  def test_entire_script_creates_desired_output
    @ad.write_to_csv("./test/test_output_file.csv")
    actual_output = CSV.read("./test/test_output_file.csv")
    desired_output = CSV.read("./test/exemplar_output_file.csv")
    assert_equal actual_output, desired_output
  end
end
