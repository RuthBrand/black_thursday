require 'bigdecimal'
require 'time'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/items_repo'
require './lib/item'
require 'pry'


class ItemsRepoTest < Minitest::Test

  def test_it_exist
    ir = ItemsRepo.new("./test/fixtures/items.csv")
    assert_instance_of ItemsRepo, ir
  end

  def test_it_returns_all_items_in_an_array
    ir = ItemsRepo.new("./test/fixtures/items.csv")
    assert_equal "Cheer bow", ir.all.first.name
    assert_instance_of Array, ir.all
    assert_equal 6, ir.all.count
    assert_equal "Cheer bow", ir.all.first.name
  end

  def test_it_can_find_an_item_by_id
    ir = ItemsRepo.new("./test/fixtures/items.csv")
    actual = ir.find_by_id(1)
    assert_instance_of Item, actual
    assert_equal "Cheer bow", actual.name
    assert_equal 1, actual.id
  end

  def test_it_returns_nil_if_no_id_match_found
    ir = ItemsRepo.new("./test/fixtures/items.csv")
    actual = ir.find_by_id(28349289034)
    assert_nil actual
  end

  def test_it_can_find_an_item_by_name
    ir = ItemsRepo.new("./test/fixtures/items.csv")
    actual = ir.find_by_name("Sal")
    assert_instance_of Item, actual
    assert_equal 4, actual.id
    assert_equal "sal", actual.name
  end

  def test_it_returns_nil_if_no_name_match_found
    ir = ItemsRepo.new("./test/fixtures/items.csv")
    actual = ir.find_by_name("hiiiiiiiii")
    assert_nil actual
  end

  def test_it_can_find_all_with_a_description
    ir = ItemsRepo.new("./test/fixtures/items.csv")
    chicken = ir.find_by_id(3)
    expected = [chicken]
    actual = ir.find_all_with_description("eat it")
    assert_equal expected, actual
  end



end