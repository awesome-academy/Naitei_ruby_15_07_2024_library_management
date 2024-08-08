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
  Publisher.create!(name: publisher_data["name"])
end

def create_categories(categories_data, parent_id = nil)
  categories_data.each do |category_data|
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
  book = Book.create!(
    name: book_data["name"],
    publisher_id: book_data["publisher_id"]
  )

  book_data["author_ids"].each do |author_id|
    BookAuthor.create!(book_id: book.id, author_id: author_id)
  end

  book_data["category_ids"].each do |category_id|
    BookCategory.create!(book_id: book.id, category_id: category_id)
  end
end

episodes_data.each do |episode_data|
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

# Additional fake data
20.times do
  Author.create!(
    name: Faker::Book.author,
    intro: Faker::Lorem.sentence,
    bio: Faker::Lorem.paragraph,
    dob: Faker::Date.birthday(min_age: 25, max_age: 70),
    dod: [nil, Faker::Date.between(from: 1.year.ago, to: Date.today)].sample,
    thumb: Faker::Avatar.image
  )
end

20.times do
  Publisher.create!(name: Faker::Book.publisher)
end

fake_book_ids = []
100.times do
  book = Book.create!(
    name: Faker::Book.title,
    publisher_id: Publisher.pluck(:id).sample
  )

  author_ids = Author.pluck(:id).sample(rand(1..3))
  category_ids = Category.pluck(:id).sample(rand(1..5))

  author_ids.each do |author_id|
    BookAuthor.create!(book_id: book.id, author_id: author_id)
  end

  category_ids.each do |category_id|
    BookCategory.create!(book_id: book.id, category_id: category_id)
  end

  fake_book_ids << book.id
end

20.times do
  Episode.create!(
    book_id: fake_book_ids.sample,
    name: Faker::Book.title,
    qty: rand(1..100),
    intro: Faker::Lorem.sentence,
    content: Faker::Lorem.paragraphs(number: 3).join("\n\n"),
    compensation_fee: rand(1000..5000),
    thumb: Faker::LoremFlickr.image(size: "300x300", search_terms: ["book"])
  )
end
