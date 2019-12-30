# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

AdminUser.create({
  first_name: 'Tamer',
  last_name: "Ibrahim",
  phone_number: "1234567890",
  email: "tamer@truckker.com",
  password: 'password',
  password_confirmation: 'password',
})

10.times do |x|
  Driver.create({
    first_name: 'Truck',
    last_name: "Driver #{x}",
    phone_number: "1234567891#{x}",
    email: "driver#{x}@truckker.com",
    password: 'password',
    password_confirmation: 'password',
  })
end