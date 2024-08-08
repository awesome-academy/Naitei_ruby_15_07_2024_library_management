class Book < ApplicationRecord
  belongs_to :publisher
  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors
  has_many :episodes, dependent: :destroy
  has_many :book_categories, dependent: :destroy
  has_many :categories, through: :book_categories

  accepts_nested_attributes_for :authors, :episodes, :categories,
                                allow_destroy: true
end
