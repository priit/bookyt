class Asset < ActiveRecord::Base
  # Invoices
  belongs_to :purchase_invoice, :class_name => 'Invoice'
  belongs_to :selling_invoice, :class_name => 'Invoice'

  # Validations
  validates_presence_of :title, :amount, :state

  # String
  def to_s
    title
  end
  
  # Bookings
  # ========
  include HasAccounts::Model
  
  # Guess direct_account
  #
  # We simply take the first booking and exclude accounts with codes
  # 1100 and 2000 (credit and debit invoices) as candidates.
  def direct_account
    # We don't care if no bookings
    return nil if bookings.empty?
    
    # Take any booking
    booking = bookings.first
    involved_accounts = [booking.credit_account, booking.debit_account]
    
    relevant_account = involved_accounts - [Account.find_by_code("1100"), Account.find_by_code("2000")]
    
    return relevant_account.first
  end

  # Build booking
  #
  # We use the value_date of the purchase invoice but our own amount.
  def build_booking
    booking_template = BookingTemplate.find_by_code(self.class.to_s.underscore + ':activate')

    booking = booking_template.build_booking(:value_date => purchase_invoice.value_date, :amount => amount)
    bookings << booking

    booking
  end
end