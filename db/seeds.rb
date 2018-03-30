# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'
FOCUS_AREAS = ['Child Care', 'Environmental', 'Human Rights', 'Community']
INSTALLMENT_AMOUNT = [400,60,250]
INSTALLMENT_TASK = ['Provide full report with the detailed impact of investments.', 'Provide a detailed plan of project advancement following our agreed upon template', 'Provide a list of three potential \"theory of change\" for the project', 'Contingent upon federal approval and local regulations', 'Deliver the estimated social impact study in partnership with UDM']
#installments
#Installment
#installment
puts "generating focus_areas"
["Ageing",
 "Agriculture & Food",
 "Animal Health & Rights",
 "Business & Economic Policy",
 "Children & Youth",
 "Communications & Media",
 "Conflict Resolution",
 "Development",
 "Education",
 "Environment",
 "Family",
 "Health & Nutrition",
 "Human Rights",
 "Indigenous People",
 "International Organization",
 "Labor",
 "Law & Legal Affairs",
 "Narcotics, Drugs & Crime",
 "Peace & Security",
 "Population/ Human Settlements",
 "Refugees",
 "Relief Services",
 "Religion, Belief & Ethics",
 "Science & Technology",
 "Social & Cultural Development",
 "Sports & Recreation",
 "Trade & International Finance",
 "Transportation",
 "Women`s Status & Issues"].each do |fa|
  FocusArea.create!(name:fa)
end

puts 'generating geos...'
neighbourhood_montreal = ['Ahuntsic-Cartierville', 'Anjou', 'Côte-des-Neiges–Notre-Dame-de-Grâce', 'Lachine', 'LaSalle', 'Le Plateau-Mont-Royal', 'Le Sud-Ouest', 'Île-Bizard–Sainte-Geneviève', 'Mercier–Hochelaga-Maisonneuve', 'Montréal-Nord', 'Outremont', 'Pierrefonds-Roxboro', 'Rivière-des-Prairies–Pointe-aux-Trembles', 'Rosemont–La Petite-Patrie', 'Saint-Laurent', 'Saint-Léonard', 'Verdun', 'Ville-Marie', 'Other neighbourhoods', 'Villeray', 'West Island']

neighbourhood_montreal.each do |neighbourhood|
  Geo.create(name:neighbourhood)
end
humanrights_ngo = ['Amnesty International', 'UNICEF', 'Human Rights Watch']
humanrights_project_name = ['Welcome Refugees to Montreal', 'Open a New Shelter', 'Fund Awareness Campaign']
childcare_ngo = ['Save The Children Canada', 'Montreal Children\'s Hospital']
childcare_project_name = ['Give Coding lessons in School', 'Cancer Research']
community_ngo = ['Santropole Roulant', 'YMCA', 'Women Aware Femme Averties', 'Kids Code Jeunesse']
community_project_name = ['Open New Farms', 'Renovate basketball court', 'Legal Defense', 'Create Afterschool Programs']
environmental_ngo = ['Equiterre', 'Canadian Wind Energy Association', 'Greenpeace Canada']
environmental_project_name = ['Energy-Efficient Lighting', 'R&D for Electric Turbines', 'Global Climate March']

puts 'generating projects...'

p 'humanrights_ngo'
humanrights_ngo.each_with_index do |ngo, index|
  ngo = Organisation.create!(name:ngo)
  puts ngo.name

  geos = [Geo.all.sample, Geo.all.sample]

  new_project = Project.new(name:humanrights_project_name[index],
                  description:Faker::Commerce.product_name,
                  focus_area:FocusArea.all.sample,
                  main_contact:Faker::Internet.email,
                  organisation:ngo,
                  geos: geos)
  new_project.save!
end

p 'childcare_ngo'
childcare_ngo.each_with_index do |ngo, index|
  ngo = Organisation.create!(name:ngo)

  geos = [Geo.all.sample, Geo.all.sample]

  new_project = Project.new(name:childcare_project_name[index],
                  description:Faker::Commerce.product_name,
                  focus_area:FocusArea.all.sample,
                  main_contact:Faker::Internet.email,
                  organisation:ngo,
                  geos: geos)
  new_project.save!
end

p 'community_ngo'
community_ngo.each_with_index do |ngo, index|
  ngo = Organisation.create!(name:ngo)

  geos = [Geo.all.sample, Geo.all.sample]
  
  new_project = Project.new(name:community_project_name[index],
                  description:Faker::Commerce.product_name,
                  focus_area:FocusArea.all.sample,
                  main_contact:Faker::Internet.email,
                  organisation:ngo,
                  geos: geos)
  new_project.save!
end

p 'environmental_ngo'
environmental_ngo.each_with_index do |ngo, index|
  ngo = Organisation.create!(name:ngo)

  geos = [Geo.all.sample, Geo.all.sample]
  
  new_project = Project.new(name:environmental_project_name[index],
                  description:Faker::Commerce.product_name,
                  focus_area:FocusArea.all.sample,
                  main_contact:Faker::Internet.email,
                  organisation:ngo,
                  geos: geos)
  new_project.save!
end

puts 'generating organisations...'
organisation_name = ['Mont Royale Organisation', 'Red Wagon Organisation']
organisation_name.each do |organisation|
  Organisation.create(name:organisation, logo:Faker::Cat.breed)
end

puts 'Adding users to organisations...'
i = 0
Organisation.all.each do |f|
  2.times do
    f.users.push(User.create(email: 'user'+i.to_s+'@user.com',password:'123456'))
    i += 1
  end
end

puts 'generating investments and their installments...'
Project.all.each do |p|
  Organisation.all.each do |f|
    i = Investment.create(project:p,organisation:f)
    rand(1..4).times do
      Installment.create!(task:INSTALLMENT_TASK.sample,investment:i,amount:(INSTALLMENT_AMOUNT.sample*[100,1000].sample),deadline:Faker::Date.forward(180))
    end
  end
end

Project.all.each do |project|
  rand(1..2).times do
    project.geos.push(Geo.all.sample)
  end
  puts "added geos to project #{project.name}"
end


