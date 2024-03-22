class ZipCode < ApplicationRecord
  validates :zip_code, uniqueness: true, presence: true, format: { with: /\A\d{5}\z/, message: 'must be exactly 5 digits' }
end