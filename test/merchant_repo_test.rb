require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/merchant_repo'
require './lib/merchant'
require 'pry'
#is it require relative everywhere or just in the sales engine?
# change all the requires to require relative

class MerchantRepoTest < Minitest::Test

  def test_it_exists
    mr = MerchantRepo.new("./test/fixtures/merchants.csv")
    assert_instance_of MerchantRepo, mr
  end

  def test_a_merchant_repo_has_merchants
    mr = MerchantRepo.new("./test/fixtures/merchants.csv")

    assert_equal 7, mr.all.count
    assert_instance_of Array, mr.all
    assert mr.all.all? { |merchant| merchant.is_a?(Merchant)}
    assert_equal "Shopin1901", mr.all.first.name
  end

  def test_it_can_find_a_merchant_by_id
    mr = MerchantRepo.new("./test/fixtures/merchants.csv")
    actual = mr.find_by_id(1)
    assert_instance_of Merchant, actual
    assert_equal "Shopin1901", actual.name
    assert_equal 1, actual.id
  end

  def test_returns_nil_if_no_match_found
    mr = MerchantRepo.new("./test/fixtures/merchants.csv")

    result = mr.find_by_id(289312)

    assert_nil result
  end

  def test_it_can_find_a_merchant_by_name
    mr = MerchantRepo.new("./test/fixtures/merchants.csv")
    actual = mr.find_by_name("Shopin1901")
    assert_instance_of Merchant, actual
    assert_equal 1, actual.id
    assert_equal "Shopin1901", actual.name
  end

  def test_it_returns_nil_if_no_name_match_found
    mr = MerchantRepo.new("./test/fixtures/merchants.csv")
    actual = mr.find_by_name("OMFG")
    assert_nil actual
  end

  def test_it_can_find_all_instances_that_contain_name_fragments
    mr = MerchantRepo.new("./test/fixtures/merchants.csv")
    actual = mr.find_all_by_name("Shopin")
    expected = ["1,Shopin1901,2010-12-10,2011-12-04", "7,Shopin1802,2010-12-10,2011-12-04"]
    assert_equal expected, actual

  end


end