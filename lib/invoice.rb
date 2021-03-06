require 'CSV'
require 'time'
require 'pry'
require_relative '../lib/black_thursday_helper'

class Invoice
  include BlackThursdayHelper

  attr_accessor :status,
                :updated_at,
                :id

  attr_reader   :customer_id,
                :merchant_id,
                :status,
                :created_at

  def initialize(params)
    @id = params[:id].to_i
    @customer_id = params[:customer_id].to_i
    @merchant_id = params[:merchant_id].to_i
    @status = params[:status].to_sym
    @created_at = Time.parse(params[:created_at].to_s)
    @updated_at = Time.parse(params[:updated_at].to_s)
  end
end
