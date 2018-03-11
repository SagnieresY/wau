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
MILESTONES_TASK = ["Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. "]
puts 'generating geos...'
15.times do
  Geo.create(name:Faker::Address.city)
end

puts 'generating projects...'
15.times do
   p = Project.new(name:Faker::Hipster.sentence(3),
                  description:Faker::Commerce.product_name,
                  focus_area:FOCUS_AREAS.sample,
                  main_contact:Faker::Internet.email,
                  ngo:Faker::Company.name)
    puts '        adding geos to project...'
    rand(1..3) do
      p.geos.push(Geo.all.sample)
    end
    p.save!
end

puts 'generating foundations...'
2.times do
  Foundation.create(name:Faker::Cat.registry, logo:Faker::Cat.breed)
end

puts 'Adding users to foundations...'
i = 0
Foundation.all.each do |f|
  3.times do
    f.users.push(User.create(email: 'user'+i.to_s+'@user.com',password:'123456'))
    i += 1
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
