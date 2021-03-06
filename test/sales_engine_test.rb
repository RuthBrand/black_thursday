require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require 'CSV'
require 'time'
require_relative '../lib/sales_engine'
require_relative '../lib/merchant_repo'

class SalesEngineTest < Minitest::Test

  def setup
    @se = SalesEngine.from_csv(
                               {:items => "./test/fixtures/items.csv",
                                :merchants => "./test/fixtures/merchants.csv",
                                :invoices => "./test/fixtures/invoices.csv",
                                :customers => "./data/customers.csv",
                                :transactions => "./data/transactions.csv",
                              :invoice_items => "./data/invoice_items.csv"}
                            )
  end

  def test_it_exists
    assert_instance_of SalesEngine, @se
  end

  def test_it_can_populate_repos
    refute_empty @se.merchants.all
    refute_empty @se.items.all
    refute_empty @se.invoices.all
    refute_empty @se.customers.all
    refute_empty @se.transactions.all
    refute_empty @se.invoice_items.all
  end

  def test_it_can_instanciate_an_analyst
    assert_instance_of SalesAnalyst, @se.analyst
  end
end
