require 'jwt'
require 'securerandom'

JWT_SECRET = Rails.application.credentials.jwt_secret

puts "Started seeding data"

puts "Seeding admin users"
password = '12345678@Aa'
time_now = Time.now
User.create(email: 'dnv@gmail.com', password: password, password_confirmation: password, is_admin: true)
30.times.each do |_i|
  User.create(email: Faker::Internet.email, password: password, password_confirmation: password, is_admin: true)
end

puts "Seeding api users"
dnv_api_user = User.create(email: 'dnv_api_user@gmail.com', password: password, password_confirmation: password, is_admin: false)
ApiUser.create(user: dnv_api_user, api_quota: rand(1000))
25.times.each do |_i|
  user = User.create(email: Faker::Internet.email, password: password, password_confirmation: password, is_admin: false)
  ApiUser.create(user: user,api_quota: rand(1000))
end

puts "Seeding items"
100.times.each do |_i|
  item = Item.create(user: User.order("RANDOM()").first, sku: Faker::Alphanumeric.alphanumeric(number: 10).upcase, active: [true, false].sample)
  random_number = rand(1..3)
  ItemPrice.create(item: item, price: Faker::Commerce.price, primary: true, effective_date: Time.now, end_date: Time.now + 5.year)
  ItemUpc.create(item: item, upc_code: Faker::Barcode.upc_a, primary: true)
  random_number.times.each do |number|
    ItemPrice.create(item: item, price: Faker::Commerce.price, primary: false, effective_date: Time.now, end_date: Time.now + (number + 1).year)
    ItemUpc.create(item: item, upc_code: Faker::Barcode.ean(13), primary: false)
  end
end

puts "Finished seeding data"