require_relative "../lib/items_repo"
require_relative "../lib/merchant_repo"

class SalesEngine
  attr_reader :merchants,
              :items

  def self.from_csv(params)
    merchants = MerchantRepo.new(params[:merchants])
    self.populate_merchants(params[:merchant])
    items = ItemsRepo.new(params[:items])
    self.populate_items(params[:items])

    SalesEngine.new(merchants, items)
  end

  def initialize(merchants, items)
    @merchants = merchants
    @items = items
  end

  def self.populate_merchants(filepath)
    CSV.foreach(filepath, headers: true, header_converters: :symbol) do |data|
      @collections << Merchant.new(data)
    end
  end

  def self.populate_items(filepath)
    CSV.foreach(filepath, headers: true, header_converters: :symbol) do |data|
      @collections << Item.new(data)
    end
  end
end
