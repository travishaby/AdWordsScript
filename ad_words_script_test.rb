require 'minitest/autorun'
require 'minitest/emoji'
require './ad_words_script.rb'

class AdWordsScriptTest < Minitest::Test
  def setup
    @ad = AdWordScript.new(CSV.read("InputFile.csv"),
                           CSV.read("Columns.csv", { headers: true,
                                             header_converters: :symbol }))
  end

  def test_it_has_word_banks_stored
    category = :promo
    words_in_category = ["on sale", "discount", "cheap", "coupon"]
    assert_equal @ad.word_banks[:promo], words_in_category
  end
end
