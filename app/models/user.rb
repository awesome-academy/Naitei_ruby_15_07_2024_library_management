class User < ApplicationRecord
  has_many :carts, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :episodes, through: :favorites, source: :favoritable,
            source_type: "Episode"
  has_many :authors, through: :favorites, source: :favoritable,
            source_type: "Author"
  has_many :publishers, through: :favorites, source: :favoritable,
            source_type: "Publisher"

  has_many :borrow_cards, dependent: :destroy
  has_many :ratings, dependent: :destroy

  enum role: {admin: 0, user: 1}

  has_secure_password

  validates :email, presence: true,
            length: {maximum: Settings.models.user.email.max_length},
            format: {with: Settings.models.user.email.valid_email_regex}
  validates :password, presence: true,
            length: {maximum: Settings.models.user.password.max_length}
end
