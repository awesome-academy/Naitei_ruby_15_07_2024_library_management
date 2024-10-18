class AuthorForm
  include ActiveModel::Model

  attr_accessor :name, :intro, :bio, :dob, :dod, :thumb_img, :author

  validates :name, presence: true,
                    length: {maximum: Settings.models.author.name.max_length}
  validates :intro, presence: true,
                     length: {maximum: Settings.models.author.intro.max_length}
  validates :bio, presence: true
  validates :dob, presence: true
  validate :date_of_death_not_before_date_of_birth

  def initialize author = Author.new, attributes = {}
    @author = author
    @name = author.name
    @intro = author.intro
    @bio = author.bio
    @dob = author.dob
    @dod = author.dod
    @thumb_img = author.thumb_img

    super(attributes)
  end

  def save
    return false unless valid?

    author.assign_attributes(attributes.except(:thumb_img))
    author.thumb_img.attach(thumb_img) if thumb_img.present?
    author.save
  end

  private

  def attributes
    {name:, intro:, bio:, dob:, dod:, thumb_img:}
  end

  def date_of_death_not_before_date_of_birth
    return if dod.blank? || dob.blank?

    return unless dod < dob

    errors.add(:dod, :after_date_of_birth)
  end
end
