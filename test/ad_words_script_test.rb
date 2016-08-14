require 'minitest/autorun'
require 'minitest/emoji'
require './ad_words_script.rb'

class AdWordsScriptTest < Minitest::Test
  def setup
    @ad = AdWordScript.new(CSV.read("InputFile.csv"),
                           RubyXL::Parser.parse("./dictionaries/NewDictionary.xlsx"))
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

  def test_sorting_of_words_into_categories
    @ad.check_dictionaries_and_assign_to_categories

    sorted_duty_words = @ad.output_data["Duty"]
    sorted_product_feature_words = @ad.output_data["Feature"]
    expected_duty_words = [nil, nil, nil, "Work", "Work", nil, "Work", "Work",
                           nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                           nil, nil, nil, nil, nil, "Work", nil, nil, nil, nil]
    expected_product_feature_words = [nil, nil, nil, "Waterproof", "Insulated", nil,
                                      "Slip On", "Square Toe", nil, nil, nil, nil,
                                      nil, nil, nil, nil, nil, "Rain", nil, nil,
                                      "Waterproof", nil, nil, "Composite Toe",
                                      "Safety", nil, nil, nil]
    assert_equal expected_duty_words, sorted_duty_words
    assert_equal expected_product_feature_words, sorted_product_feature_words
  end

  def test_entire_script_creates_desired_output
    @ad.write_to_csv("./test/test_output_file.csv")
    actual_output = CSV.read("./test/test_output_file.csv")
    expected_output = CSV.read("./test/exemplar_output_file.csv")
    assert_equal expected_output, actual_output
  end
end
