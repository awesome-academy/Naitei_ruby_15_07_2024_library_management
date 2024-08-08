class Category < ApplicationRecord
  belongs_to :parent, class_name: Category.name, optional: true
  has_many :subcategories, class_name: Category.name,
            foreign_key: :parent_id, dependent: :destroy

  has_many :book_categories, dependent: :destroy
  has_many :books, through: :book_categories
end
