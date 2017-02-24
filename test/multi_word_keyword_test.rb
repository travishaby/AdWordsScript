require 'minitest/autorun'
require 'minitest/emoji'
require './ad_words_script.rb'

class AdWordsScriptTest < Minitest::Test
  def setup
    @ad = AdWordScript.new(CSV.read("MultiWordInputFile.csv"),
                           RubyXL::Parser.parse("./dictionaries/MultiWordNewDictionary.xlsx"))
  end

  def test_it_has_word_banks_stored
    category = "Promo Dictionary"
    words_in_category = ["on sale", "discount", "cheap", "coupon", "win free", "warranty", "sale", "closeout", "clearance"]
    assert_equal words_in_category, @ad.word_banks[category].keys
  end

  def test_it_has_output_hash_with_category_headers
    headers = [:WIP, "Gender", "Brand", "Collection", "Item", "Feature", "Duty", "Competitor", "Color", "Material", "Promo", "Size", "URL", "Location"]
    assert_equal headers, @ad.output_data.keys
  end

  def test_sorting_with_multiple_word_key_phrases
    @ad.check_dictionaries_and_assign_to_categories

    sorted_brand_words = @ad.output_data["Brand"]
    sorted_item_words = @ad.output_data["Item"]
    expected_brand_words = [nil, "Durango - Rocky", "Rocky", "Rocky", "Rocky",
                            "Rocky", "Rocky", "Rocky", "Rocky", "Rocky", "Rocky",
                            "Georgia", "Georgia", "Georgia", "Georgia", "Georgia",
                            "Georgia", "Georgia", "Georgia", "Durango", "Durango",
                            "Durango", nil, "Lehigh", "Lehigh", "Lehigh", "Lehigh",
                            "Lehigh", "Creative Recreation"]
    expected_item_words = ["Boots", "Boots - Shoes", "Boots", "Boots", "Boots",
                           "Boots", nil, "Boots", "Boots", "Boots", "Boots", "Boots",
                           "Boots", nil, "Boots", "Boots", "Boots", "Boots", "Boots",
                           "Boots", "Boots", nil, nil, "Boots", "Boots", "Shoes",
                           nil, "Boots", nil]

    assert_equal expected_item_words, sorted_item_words
    assert_equal expected_brand_words, sorted_brand_words
  end

  def test_entire_script_creates_desired_output
    @ad.write_to_csv("./test/multi_word_test_output_file.csv")
    actual_output = CSV.read("./test/multi_word_test_output_file.csv")
    expected_output = CSV.read("./test/multi_word_exemplar_output_file.csv")
    assert_equal expected_output, actual_output
  end
end
