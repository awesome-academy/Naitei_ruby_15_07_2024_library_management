class Book < ApplicationRecord
  BOOK_PARAMS = %i(
    name
    publisher_id
  ).freeze + [
    {category_ids: [], author_ids: []}
  ].freeze

  belongs_to :publisher
  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors
  has_many :episodes, dependent: :destroy
  has_many :book_categories, dependent: :destroy
  has_many :categories, through: :book_categories

  accepts_nested_attributes_for :authors, :episodes, :categories,
                                allow_destroy: true

  validates :name, presence: true,
            length: {maximum: Settings.models.book.name.max_length}
  validates :publisher_id, presence: true
  validate :must_have_categories
  validate :must_have_authors

  scope :sorted_by_name, ->{order(name: :asc)}
  scope :sorted_by_created, ->{order(created_at: :desc)}

  def author_ids
    authors.pluck(:id)
  end

  def category_ids
    categories.pluck(:id)
  end

  def self.ransackable_attributes _auth_object = nil
    %w(created_at id name publisher_id updated_at)
  end

  def self.ransackable_associations _auth_object = nil
    %w(authors book_authors book_categories categories episodes publisher)
  end

  private
  def must_have_categories
    return unless categories.empty?

    errors.add(:categories, I18n.t("message.books.cat_found"))
  end

  def must_have_authors
    return unless authors.empty?

    errors.add(:authors, I18n.t("message.books.author_found"))
  end
end
