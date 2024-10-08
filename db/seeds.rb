require "json"

authors_file = File.read(Rails.root.join("db", "seeds", "authors.json"))
publishers_file = File.read(Rails.root.join("db", "seeds", "publishers.json"))
categories_file = File.read(Rails.root.join("db", "seeds", "categories.json"))
books_file = File.read(Rails.root.join("db", "seeds", "books.json"))
episodes_file = File.read(Rails.root.join("db", "seeds", "episodes.json"))

authors_data = JSON.parse(authors_file)
publishers_data = JSON.parse(publishers_file)
categories_data = JSON.parse(categories_file)
books_data = JSON.parse(books_file)
episodes_data = JSON.parse(episodes_file)

User.create!(
  name: "Admin",
  email: "admin@example.com",
  password: "password",
  role: "admin",
  dob: Faker::Date.birthday(min_age: 30, max_age: 50),
  phone: Faker::PhoneNumber.cell_phone_in_e164[2..11],
  lost_time: 0,
  blacklisted: false,
  activated: true
)

30.times do
  lost_time = rand(0..3)
  blacklisted = lost_time == 3
  activated = !blacklisted

  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    password: "password",
    role: "user",
    dob: Faker::Date.birthday(min_age: 18, max_age: 65),
    phone: Faker::PhoneNumber.cell_phone_in_e164[2..11],
    lost_time: lost_time,
    blacklisted: blacklisted,
    activated: activated
  )
end

authors_data.each do |author_data|
  next if author_data["name"].blank?

  Author.create!(
    name: author_data["name"],
    intro: author_data["intro"],
    bio: author_data["bio"],
    dob: author_data["dob"] ? Date.parse(author_data["dob"]) : nil,
    dod: author_data["dod"] ? Date.parse(author_data["dod"]) : nil,
    thumb: author_data["thumb"]
  )
end

publishers_data.each do |publisher_data|
  next if publisher_data["name"].blank?

  Publisher.create!(name: publisher_data["name"])
end

def create_categories(categories_data, parent_id = nil)
  categories_data.each do |category_data|
    next if category_data["name"].blank?

    category = Category.create!(
      name: category_data["name"],
      parent_id: parent_id
    )

    if category_data["subcategories"]
      create_categories(category_data["subcategories"], category.id)
    end
  end
end

create_categories(categories_data)

books_data.each do |book_data|
  next if book_data["name"].blank?

  book = Book.new(
    name: book_data["name"],
    publisher_id: book_data["publisher_id"]
  )

  category_ids = book_data["category_ids"].select { |id| Category.exists?(id) }
  author_ids = book_data["author_ids"].select { |id| Author.exists?(id) }

  category_ids.each do |category_id|
    category = Category.find(category_id)
    book.categories << category
  end

  author_ids.each do |author_id|
    author = Author.find(author_id)
    book.authors << author
  end

  book.save
end

episodes_data.each do |episode_data|
  next if episode_data["name"].blank?

  Episode.create!(
    book_id: episode_data["book_id"],
    name: episode_data["name"],
    qty: episode_data["qty"],
    intro: episode_data["intro"],
    content: episode_data["content"],
    compensation_fee: episode_data["compensation_fee"],
    thumb: episode_data["thumb"]
  )
end

100.times do
  name = Faker::Book.author
  next if name.blank?

  Author.create!(
    name: name,
    intro: Faker::Lorem.sentence,
    bio: Faker::Lorem.paragraph,
    dob: Faker::Date.birthday(min_age: 25, max_age: 70),
    dod: [nil, Faker::Date.between(from: 1.year.ago, to: Date.today)].sample,
    thumb: Faker::Avatar.image
  )
end

100.times do
  name = Faker::Book.publisher
  next if name.blank?

  Publisher.create!(name: name)
end

fake_book_ids = []
100.times do
  name = Faker::Book.title
  next if name.blank?

  book = Book.new(
    name: name,
    publisher_id: Publisher.pluck(:id).sample
  )

  author_ids = Author.pluck(:id).sample(rand(1..3))
  category_ids = Category.pluck(:id).sample(rand(1..5))

  category_ids.each do |category_id|
    category = Category.find(category_id)
    book.categories << category
  end

  author_ids.each do |author_id|
    author = Author.find(author_id)
    book.authors << author
  end

  book.save
  fake_book_ids << book.id
end

100.times do
  name = Faker::Book.title
  next if name.blank?

  Episode.create!(
    book_id: fake_book_ids.sample,
    name: name,
    qty: rand(1..100),
    intro: Faker::Lorem.sentence,
    content: Faker::Lorem.paragraphs(number: 3).join("\n\n"),
    compensation_fee: rand(1000..5000),
    thumb: Faker::LoremFlickr.image(size: "300x300", search_terms: ["book"])
  )
end

users = User.limit(20)
borrow_cards = users.map do |user|
  BorrowCard.create!(
    user: user,
    start_time: Faker::Date.backward(days: 365)
  )
end

borrow_cards.each do |borrow_card|
  rand(1..5).times do
    episode = Episode.all.sample
    status = BorrowBook.statuses.keys.sample

    BorrowBook.create!(
      borrow_card: borrow_card,
      episode: episode,
      status: status,
      reason: status == "cancel" ? Faker::Lorem.sentence : nil
    )
  end
end

users = User.all
authors = Author.all
episodes = Episode.all

100.times do
  Rating.create!(
    episode: episodes.sample,
    user: users.sample,
    body: Faker::Lorem.sentence(word_count: 10),
    rating: rand(1..5),
    created_at: Faker::Date.backward(days: 365),
    updated_at: Faker::Date.backward(days: 365)
  )
end

50.times do
  Favorite.create!(
    user_id: users.sample.id,
    favoritable_type: "Author",
    favoritable_id: authors.sample.id
  )
end

50.times do
  Favorite.create!(
    user_id: users.sample.id,
    favoritable_type: "Episode",
    favoritable_id: episodes.sample.id
  )
end

100.times do
  Notification.create!(
    user_id: users.sample.id,
    content: Faker::Lorem.sentence(word_count: 10),
    status: [0, 1].sample, 
    notificationable_type: "Episode",
    notificationable_id: episodes.sample.id
  )
end
