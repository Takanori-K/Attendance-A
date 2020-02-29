class Base < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :base_number, presence: true, uniqueness: true, numericality: {greater_than: 0}
  validates :base_name, presence: true, length: { maximum: 50 }
  validates :base_type, presence: true, length: { maximum: 50 }
end
