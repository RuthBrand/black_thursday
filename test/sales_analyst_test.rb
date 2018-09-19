require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/sales_analyst'
require_relative '../lib/sales_engine'
require 'pry'

class SalesAnalystTest<Minitest::Test

  def setup
    @se = SalesEngine.from_csv(
                               {:items => "./test/fixtures/items.csv",
                                :merchants => "./test/fixtures/merchants.csv",
                                :invoices => "./test/fixtures/invoices.csv",
                                :customers => "./test/fixtures/customers.csv",
                                :transactions => "./test/fixtures/transactions.csv",
                              :invoice_items => "./test/fixtures/invoice_items.csv"}
                            )
    @sa = @se.analyst
  end

  def test_it_exists
    assert_instance_of SalesAnalyst, @sa
  end

  def test_it_gives_average_items_per_merchant
    assert_equal 1.14, @sa.average_items_per_merchant
  end

  def test_it_can_give_average_items_per_merchant_standard_deviation
    assert_equal 0.38, @sa.average_items_per_merchant_standard_deviation
  end

  def test_it_calculates_merchants_with_high_item_count
    expected = [@se.merchants.find_by_id(1)]
    assert_equal expected, @sa.merchants_with_high_item_count
  end

  def test_it_can_do_average_average_price_per_merchant
    skip
    assert_equal 148005.43, @sa.average_average_price_per_merchant
  end

  def test_average_invoices_per_merchant
    assert_equal 1.14, @sa.average_invoices_per_merchant
  end

  def test_average_invoices_per_merchant_standard_deviation
    assert_equal 1.23, @sa.average_invoices_per_merchant_standard_deviation
  end

  def test_top_merchants_by_invoice_count
    skip
    assert_equal @se.invoices.find_all_by_merchant_id(12334269), @sa.top_merchants_by_invoice_count
  end

  def test_bottom_merchants_by_invoice_count
    skip
    assert_equal @se.invoices.find_all_by_merchant_id(34444), @sa.bottom_merchants_by_invoice_count
  end

  def test_top_days_by_invoice_count
    assert_equal ["Monday"], @sa.top_days_by_invoice_count
  end

  def test_the_invoice_status
    assert_equal 25.0, @sa.invoice_status(:pending)
    assert_equal 62.5, @sa.invoice_status(:shipped)
    assert_equal 12.5, @sa.invoice_status(:returned)
  end

  def test_it_can_check_if_invoice_is_paid_in_full
    assert_equal true, @sa.invoice_paid_in_full?(3374)
  end

  def test_it_can_return_dollar_amount_of_invoices_based_on_id
    skip
    assert_equal 0.21067, @sa.invoice_total(1)
  end

  def test_it_can_give_us_golden_items
    expected = @se.items.find_by_id(2)
    assert_equal [expected], @sa.golden_items
  end

  def test_it_ca_give_total_revenue_by_date
    date = Time.parse('2009-12-09')
    assert_equal 0.563432e4, @sa.total_revenue_by_date(date)
  end

  def test_it_can_return_top_revenue_earners
    expected = [@se.merchants.find_by_id(2)]
    assert_equal expected, @sa.top_revenue_earners(1)
  end

  def test_it_returns_20_revenue_earners_by_defualt
    actual = @sa.top_revenue_earners
    assert_equal 7, actual.count
  end

  #silvestre, is there a transaction valid thing?
  #Note: an invoice is considered pending if none of its transactions are successful.

  def test_it_can_return_merchants_with_pending_invoices
    expected = [@se.merchants.find_by_id(34444), @se.merchants.find_by_id(12334269)]
    assert_equal expected, @sa.merchants_with_pending_invoices
  end

  def test_i_can_pull_out_the_merchant_ids_from_the_pending_invoices
    assert_equal [34444, 12334269], @sa.pull_out_the_merchant_ids_from_pending_invoices
  end

  def test_which_merchants_offer_only_one_item
    assert_equal 6, @sa.merchants_with_only_one_item.count
  end

   def test_merchants_who_only_sold_one_item_in_the_month_they_registered_xx
     assert_equal 1, @sa.merchants_with_only_one_item_registered_in_month("August").count
   end

   def test_i_can_find_total_revenue_by_merchant_xx
     assert_equal $500, @sa.revenue_by_merchant(1)
   end

end
