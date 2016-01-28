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
    assert_equal words_in_category, @ad.word_banks[category]
  end

  def test_it_has_output_hash_with_category_headers
    headers = [:unsorted, :brand_terms, :item, :feature, :duty,
               :competitor, :color, :material, :collection, :size,
               :gender, :promo, :misspellings]
    assert_equal headers, @ad.output_data.keys
  end

  def test_sorting_of_words_into_categories_before_filtering_for_uniqueness
    @ad.check_dictionaries_and_assign_to_categories
    sorted_duty_words = @ad.output_data[:duty]
    sorted_product_feature_words = @ad.output_data[:feature]
    expected_duty_words = ["work", "work", "work"]
    expected_product_feature_words = ["waterproof", "insulated", "square toe", "safety"]

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
