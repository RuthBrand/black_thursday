require 'pry'
require 'time'
require_relative '../lib/black_thursday_helper'

class Transaction
  include BlackThursdayHelper

  attr_reader :invoice_id,
              :created_at

  attr_accessor :credit_card_number,
                :credit_card_expiration_date,
                :result,
                :updated_at,
                :id

  def initialize(params)
    @id = params[:id].to_i
    @invoice_id = params[:invoice_id].to_i
    @credit_card_number = params[:credit_card_number].to_s
    @credit_card_expiration_date = params[:credit_card_expiration_date].to_s
    @result = params[:result].to_sym
    @created_at = Time.parse(params[:created_at].to_s)
    @updated_at = Time.parse(params[:updated_at].to_s)
  end
end
