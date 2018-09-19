require 'bigdecimal'
require_relative '../lib/sales_engine'
require_relative '../lib/black_thursday_helper'
require_relative '../lib/sales_analyst_deviation_helper'
require 'pry'

class SalesAnalyst
  include BlackThursdayHelper
  include SalesAnalystHelper

  def initialize(sales_engine)
    @sales_engine = sales_engine
  end

  def average_items_per_merchant
    total_merchants = all_merchants.size.to_f
    total_items = all_items.size.to_f
    BigDecimal((total_items.to_f/total_merchants), 3).to_f
  end

  def average_items_per_merchant_standard_deviation
    mean = mean_method
    items_per_merchant = all_merchants.map do |merchant|
      @sales_engine.items.find_all_by_merchant_id(merchant.id).size
    end
    standard_dev(items_per_merchant, mean)
  end

  def merchants_with_high_item_count
    goal = average_items_per_merchant + average_items_per_merchant_standard_deviation

    all_merchants.find_all do |merchant|
      @sales_engine.items.find_all_by_merchant_id(merchant.id).size > goal
    end
  end

  def average_item_price_for_merchant(merchant_id)
    items = @sales_engine.items.find_all_by_merchant_id(merchant_id)
    item_sum = items.inject(0) do |sum, item|
      sum + item.unit_price
    end
    average_price = item_sum/(items.count)
    BigDecimal(average_price, 4).round(2)
  end

  def average_average_price_per_merchant
    merchant_item_averages = all_merchants.map do |merchant|
      average_item_price_for_merchant(merchant.id)
    end
    averages_summed = merchant_item_averages.inject(0) do |sum, average|
      sum + average
    end
    averages_total = (averages_summed/ merchant_item_averages.size)
    BigDecimal(averages_total, 4)
  end

  def average_invoices_per_merchant
    total_merchants = @sales_engine.merchants.all.count.to_f
    total_invoices = @sales_engine.invoices.all.count.to_f
    (total_invoices/total_merchants).round(2)
  end

  def average_invoices_per_merchant_standard_deviation
    mean = mean_method_for_invoices
    invoices_per_merchant = all_merchants.map do |merchant|
      @sales_engine.invoices.find_all_by_merchant_id(merchant.id).size
    end
    standard_dev(invoices_per_merchant, mean)
  end

  def top_merchants_by_invoice_count
    mean = mean_method_for_invoices
    doubled_standard_deviation = average_invoices_per_merchant_standard_deviation * 2

    all_merchants.find_all do |merchant|
      @sales_engine.invoices.find_all_by_merchant_id(merchant.id).size > (doubled_standard_deviation + mean)
    end
  end

  def bottom_merchants_by_invoice_count
    mean = mean_method_for_invoices
    doubled_standard_deviation = average_invoices_per_merchant_standard_deviation * 2

    all_merchants.find_all do |merchant|
      @sales_engine.invoices.find_all_by_merchant_id(merchant.id).size < (mean - doubled_standard_deviation)
    end
  end

  def top_days_by_invoice_count
    mean = all_invoices.size.to_f / count_invoices_per_day.size
    goal = mean + standard_dev(count_invoices_per_day, mean)

    top_days = invoices_by_day.find_all do |day, object_array|
      object_array.size > goal
    end
    remove_keys(top_days, Invoice)
  end

  def count_invoices_per_day
    invoices_by_day.map do |day, invoice|
      invoice.count
    end
  end

  def invoices_by_day
    all_invoices.group_by do |invoice|
      invoice.created_at.strftime('%A')
    end
  end

  def remove_keys(data, type)
    data.flatten.delete_if do |element|
      element.is_a?(type)
    end
  end

  def invoice_status(status)
    invoices_by_status = all_invoices.count do |invoice|
      invoice.status == status
    end
    ((invoices_by_status.to_f / all_invoices.size) * 100).round(2)
  end


  def invoice_paid_in_full?(invoice_id)
    transactions = @sales_engine.transactions.find_all_by_invoice_id(invoice_id)
    transactions.any? do |transaction|
      transaction.result == :success
    end
  end

  def invoice_total(invoice_id)
    invoice_items = @sales_engine.invoice_items.find_all_by_invoice_id(invoice_id)
    total = invoice_items.inject(0) do |sum, in_item|
      sum + (in_item.quantity * in_item.unit_price_to_dollars)
    end
    BigDecimal(total, total.to_s.size - 1)
  end

  def golden_items
    mean = all_prices_sum / all_items.size
    std = standard_dev(all_prices, mean)
    golden_goal = mean + std * 2

    all_items.find_all do |item|
      item.unit_price > golden_goal
    end
  end

  def total_revenue_by_date(date)
    correct_invoices = all_invoices.keep_if do |invoice|
      invoice.created_at == date
    end
    correct_invoices.inject(0) do |sum, invoice|
      sum + invoice_total(invoice.id)
    end
  end

  def top_revenue_earners(show_count = 20)
    all_merchants.max_by(show_count) do |merchant|
      revenue_by_merchant_float(merchant.id)
    end
  end

  def revenue_by_merchant_float(merchant_id)
    merchant_invoices = valid_merchant_invoices(merchant_id)
    merchant_invoices.inject(0) do |sum, invoice|
      sum + invoice_total_float(invoice.id)
    end
  end

  def valid_merchant_invoices(merchant_id)
    merchant_invoices = @sales_engine.invoices.find_all_by_merchant_id(merchant_id)
    merchant_invoices.keep_if do |invoice|
      invoice_paid_in_full?(invoice.id)
    end
  end

  def pull_out_pending_invoices
    @sales_engine.invoices.all.keep_if do |invoice|
        invoice.status.to_s == "pending" || invoice_paid_in_full?(invoice.id)
    end
  end

  def pull_out_the_merchant_ids_from_pending_invoices
    pull_out_pending_invoices.map do |invoice|
      invoice.merchant_id
    end
  end

  def merchants_with_pending_invoices
    pending_merchants = pull_out_the_merchant_ids_from_pending_invoices
    @sales_engine.merchants.all.keep_if do |merchant|
      pending_merchants.include?(merchant.id)
    end
  end

  def merchants_with_only_one_item
  merchant_ids =  @sales_engine.items.all.map do |item|
      item.merchant_id
    end
    times_appearing = Hash.new(0)
    merchant_ids.each do |id|
      times_appearing[id] += 1
     end
   times_appearing
   merchant_ids_with_one = times_appearing.reject do |key, value|
     value > 1
   end
   merchant_ids_to_pass_in = merchant_ids_with_one.keys
   @sales_engine.merchants.all.keep_if do |merchant|
     merchant_ids_to_pass_in.include?(merchant.id)
   end
 end

 def merchants_with_only_one_item_registered_in_month(month)
   merchant_list = dates_into_months[month].group_by do |invoice|
     invoice.merchant_id
   end
   merchant_ids = merchant_list.reject do |merchant_id, invoices|
     invoices.count > 1
   end.keys
   # merchants = []
   # @sales_engine.merchant_ids
 end

 def dates_into_months
     all_invoices.group_by do |invoice|
       invoice.created_at.strftime('%B')
     end
 end



end
