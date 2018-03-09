# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'
FOCUS_AREAS = ['child care', 'memes sharing', 'capybara ideology', 'Animal rights']
MILESTONES_AMOUNT = [420,69]
MILESTONES_TASK = ['Find the lost emerald', 'gibe reborts pls', 'call Ellen', 'Go to AA meeting', 'Find the meaning of life']
puts 'generating geos...'
15.times do
  Geo.create(name:Faker::Address.city)
end

puts 'generating projects...'
15.times do
   p = Project.new(name:Faker::Color.color_name,
                  description:Faker::Commerce.product_name,
                  focus_area:FOCUS_AREAS.sample,
                  main_contact:Faker::Internet.email,
                  ngo:Faker::Bank.name)
    puts '        adding geos to project...'
    rand(1..3) do
      p.geos.push(Geo.all.sample)
    end
    p.save!
end

puts 'generating foundations...'
1.times do
  Foundation.create(name:Faker::Cat.registry, logo:Faker::Cat.breed)
end


puts 'Adding users to foundations...'
Foundation.all.each do |f|
  rand(1..3).times do
    f.users.push(User.create(email:Faker::Internet.email,password:'123456'))
  end
end

puts 'generating investments and their milestones...'
Project.all.each do |p|
  rand(1..3).times do
    i = Investment.create(project:p,foundation:Foundation.all.sample)
    rand(1..4).times do
      Milestone.create!(task:MILESTONES_TASK.sample,investment:i,amount:(MILESTONES_AMOUNT.sample*[10,100,1000].sample),deadline:Faker::Date.forward(69))
    end
  end
end
