class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  USER_PARAMS = [:name, :email, :dob, :phone, :lost_time,
                :blacklisted, :activated].freeze
  CREATE_PARAMS = %i(name email password phone).freeze
  UPDATE_PARAMS = %i(name password_confirmation password phone).freeze
  VALID_EMAIL_REGEX = Regexp.new(Settings.models.user.email.regex_valid)
  has_many :carts, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :episodes, through: :favorites, source: :favoritable,
            source_type: "Episode"
  has_many :authors, through: :favorites, source: :favoritable,
            source_type: "Author"
  has_many :publishers, through: :favorites, source: :favoritable,
            source_type: "Publisher"

  has_many :borrow_cards, dependent: :destroy
  has_many :borrow_books, through: :borrow_cards
  has_many :ratings, dependent: :destroy
  has_many :notifications, dependent: :destroy

  enum role: {admin: 0, user: 1}

  validates :name, presence: true,
            length: {maximum: Settings.models.user.name.max_length}
  validates :password,
            length: {minimum: Settings.models.user.password.min_length},
            allow_nil: true
  validates :email, presence: true,
            length: {maximum: Settings.models.user.email.max_length},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :phone, presence: true
  validate :dob_after_start_year

  before_save :downcase_email
  before_update :blacklist

  scope(:favorited_for_book, lambda do |book|
    joins(:favorites)
      .where(
        favorites: {
          favoritable_type: "Episode",
          favoritable_id: book.episodes.ids
        }
      ).distinct
  end)

  def borrow_books_by_status status
    borrow_books.where status:
  end

  def self.ransackable_attributes _auth_object = nil
    %w(activated blacklisted created_at dob email
        id lost_time name phone role updated_at)
  end

  def self.generate_random_password
    SecureRandom.alphanumeric Settings.random_password_count
  end

  def currently_borrowing_episodes_count
    borrowing_episodes_count = BorrowBook.by_user(id).active.count
    cart_episodes_count = carts.count
    borrowing_episodes_count + cart_episodes_count
  end

  def can_borrow_episode? episode
    policy = BorrowPolicy.new(self, episode)
    return true if policy.can_borrow_episode?

    errors.add(:base, policy.errors.join("\n"))
    false
  end

  def can_checkout_cart?
    policy = BorrowPolicy.new self
    return true if policy.can_checkout_cart?

    errors.add(:base, policy.errors.join("\n"))
    false
  end

  private

  def downcase_email
    email.downcase!
  end

  def blacklist
    return unless lost_time >= 3

    self.activated = false
    self.blacklisted = true
  end

  def dob_after_start_year
    return if dob.blank?

    start_year = Settings.models.user.dob.start_year
    return unless dob.year < start_year

    errors.add(:dob, I18n.t("messages.users.dob_too_early", start_year:))
  end
end
