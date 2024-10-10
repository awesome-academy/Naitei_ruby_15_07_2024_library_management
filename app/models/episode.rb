class Episode < ApplicationRecord
  include Searchable

  SEARCH_PARAMS = %i(book_id publisher_id author_id category_id).freeze
  EPISODE_PARAMS = %i(
    name
    book_id
    qty
    intro
    content
    compensation_fee
  ).freeze

  belongs_to :book
  has_one :publisher, through: :book
  has_many :book_categories, through: :book
  has_many :categories, through: :book_categories
  has_many :book_authors, through: :book
  has_many :authors, through: :book_authors
  has_many :carts, dependent: :destroy
  has_many :borrow_books, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :users, through: :carts
  has_many :notifications, as: :notificationable, dependent: :destroy

  validates :name, presence: true,
                  length: {maximum: Settings.models.episode.name_max}
  validates :qty, presence: true,
                  numericality: {only_integer: true,
                                 greater_than_or_equal_to:
                                   Settings.models.episode.min}
  validates :intro, length: {maximum: Settings.models.episode.name_max}
  validates :content, presence: true
  validates :compensation_fee, numericality: {only_integer: true,
                                              greater_than_or_equal_to:
                                                Settings.models.episode.min}

  scope :sorted_by_name, ->{order(name: :asc)}
  scope :sorted_by_created, ->{order(created_at: :desc)}

  scope(:search_by_name, lambda do |keyword|
    where("name LIKE ?", "%#{keyword}%") if keyword.present?
  end)

  scope(:trend_episodes, lambda do |limit = Settings.models.episode.trend_count|
    joins(:favorites)
      .where(favorites: {favoritable_type: "Episode"})
      .group("episodes.id")
      .order("COUNT(favorites.id) DESC")
      .limit(limit)
  end)

  scope(:most_reads, lambda do |limit = Settings.models.episode.most_count|
    joins(:ratings)
      .group("episodes.id")
      .select("episodes.*, COALESCE(AVG(ratings.rating), 0) as average_rating")
      .order("average_rating DESC")
      .limit(limit)
  end)

  scope(:for_category, lambda do |category_id|
    joins(book: :book_categories)
      .where(book_categories: {category_id:})
      .order(:id)
  end)

  scope(:by_book, lambda do |book_id|
    return if book_id.blank?

    where(book_id:)
  end)

  scope(:by_publisher, lambda do |publisher_id|
    return if publisher_id.blank?

    joins(book: :publisher)
      .where(books: {publisher_id:})
  end)

  scope(:by_author, lambda do |author_id|
    return if author_id.blank?

    joins(book: :authors)
      .where(authors: {id: author_id})
  end)

  scope(:by_category, lambda do |category_id|
    return if category_id.blank?

    joins(book: :categories)
      .where(categories: {id: category_id})
  end)

  def self.ransackable_attributes _auth_object = nil
    %w(name book_id qty compensation_fee created_at updated_at)
  end

  def self.ransackable_associations _auth_object = nil
    %w(book publisher categories authors)
  end

  def self.search_episodes \
    name:,
    book_id:,
    publisher_id:,
    author_id:,
    category_id:

    must_conditions = []
    must_conditions << {term: {book_id:}} if book_id.present?
    must_conditions << {term: {publisher_id:}} if publisher_id.present?
    must_conditions << {term: {author_id:}} if author_id.present?
    must_conditions << {term: {category_id:}} if category_id.present?

    query = {
      size: Settings.es.max_hits,
      query: {
        bool: {
          must: must_conditions
        }
      }
    }

    if name.present?
      query[:query][:bool][:should] = [
        match: {
          name: {
            query: name,
            fuzziness: "AUTO"
          }
        }
      ]
    end

    if must_conditions.empty? && name.blank?
      return __elasticsearch__.search(
        {
          size: Settings.es.max_hits,
          query: {match_all: {}}
        }
      ).records.to_a
    end

    __elasticsearch__.search(query).records.to_a
  end

  def average_rating
    total_ratings = ratings.sum(:rating)
    total_count = ratings.count
    if total_count.positive?
      total_ratings.to_f / total_count
    else
      0
    end
  end
end
