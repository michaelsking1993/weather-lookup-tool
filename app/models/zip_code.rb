class ZipCode < ApplicationRecord
  validates :zip_code, presence: true, format: { with: /\A\d{5}\z/, message: "must be exactly 5 digits" }, uniqueness: true
end