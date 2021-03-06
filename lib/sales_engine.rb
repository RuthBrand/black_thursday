require 'time'
require 'CSV'
require_relative "../lib/items_repo"
require_relative "../lib/merchant_repo"
require_relative "../lib/sales_analyst"
require_relative "../lib/invoice_repository"
require_relative "../lib/customer_repo"
require_relative "../lib/transaction_repo"
require_relative "../lib/invoice_item_repo"

class SalesEngine
  attr_reader :merchants,
              :items,
              :customers,
              :transactions,
              :invoice_items,
              :invoices

  def initialize(merchants, items, customers, transactions, invoice_items, invoices)
    @merchants = MerchantRepo.new(merchants)
    @items = ItemsRepo.new(items)
    @customers = CustomerRepo.new(customers)
    @transactions = TransactionRepo.new(transactions)
    @invoice_items = InvoiceItemRepo.new(invoice_items)
    @invoices = InvoiceRepository.new(invoices)
  end

  def self.from_csv(params)
    merchants = params[:merchants]
    items =   params[:items]
    customers = params[:customers]
    transactions = params[:transactions]
    invoice_items = params[:invoice_items]
    invoices = params[:invoices]
    SalesEngine.new(merchants, items, customers, transactions, invoice_items, invoices)
  end

  def analyst
    SalesAnalyst.new(self)
  end
end
