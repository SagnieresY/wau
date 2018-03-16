# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'
FOCUS_AREAS = ['Child Care', 'Environmental', 'Human Rights', 'Community']
MILESTONES_AMOUNT = [400,60,250]
MILESTONES_TASK = ['Provide full report with the detailed impact of investments.', 'Provide a detailed plan of project advancement following our agreed upon template', 'Provide a list of three potential \"theory of change\" for the project', 'Contingent upon federal approval and local regulations', 'Deliver the estimated social impact study in partnership with UDM']

puts 'generating geos...'
neighbourhood_montreal = ['Ahuntsic-Cartierville', 'Anjou', 'Côte-des-Neiges–Notre-Dame-de-Grâce', 'Lachine', 'LaSalle', 'Le Plateau-Mont-Royal', 'Le Sud-Ouest', 'Île-Bizard–Sainte-Geneviève', 'Mercier–Hochelaga-Maisonneuve', 'Montréal-Nord', 'Outremont', 'Pierrefonds-Roxboro', 'Rivière-des-Prairies–Pointe-aux-Trembles', 'Rosemont–La Petite-Patrie', 'Saint-Laurent', 'Saint-Léonard', 'Verdun', 'Ville-Marie', 'Other neighbourhoods', 'Villeray', 'West Island']

neighbourhood_montreal.each do |neighbourhood|
  Geo.create(name:neighbourhood)
end
humanrights_ngo = ['Amnesty International', 'UNICEF', 'Human Rights Watch']
humanrights_project_name = ['Welcome Refugees to Montreal', 'Open a New Shelter', 'Fund Awareness Campaign']
childcare_ngo = ['Save The Children Canada', 'Children\'s Wish', 'Montreal Children\'s Hospital']
childcare_project_name = ['Give Coding lessons in School', 'Cancer Research']
community_ngo = ['Santropole Roulant', 'YMCA', 'Women Aware Femme Averties', 'Kids Code Jeunesse']
community_project_name = ['Open New Farms', 'Renovate basketball court', 'Legal Defense', 'Create Afterschool Programs']
environmental_ngo = ['Equiterre', 'Avaaz.org', 'Canadian Wind Energy Association', 'Greenpeace Canada']
environmental_project_name = ['Energy-Efficient Lighting', 'Save the bees', 'R&D for Electric Turbines', 'Global Climate March']

puts 'generating projects...'

humanrights_ngo.each_with_index do |ngo, index|
  p = Project.new(name:humanrights_project_name[index],
                  description:Faker::Commerce.product_name,
                  focus_area:FOCUS_AREAS.third,
                  main_contact:Faker::Internet.email,
                  ngo:ngo)
    puts '        adding geos to project...'
    rand(1..3) do
      p.geos.push(Geo.all.sample)
    end
    p.save!
end

childcare_ngo.each_with_index do |ngo, index|
  new_project = Project.new(name:childcare_project_name[index],
                  description:Faker::Commerce.product_name,
                  focus_area:FOCUS_AREAS.first,
                  main_contact:Faker::Internet.email,
                  ngo:ngo)
    puts '        adding geos to project...'
    rand(1..3) do
      new_project.geos.push(Geo.all.sample)
      p new_project.geos
    end
    new_project.save!
end

community_ngo.each_with_index do |ngo, index|
  p = Project.new(name:community_project_name[index],
                  description:Faker::Commerce.product_name,
                  focus_area:FOCUS_AREAS.fourth,
                  main_contact:Faker::Internet.email,
                  ngo:ngo)
    puts '        adding geos to project...'
    rand(1..3) do
      p.geos.push(Geo.all.sample)
    end
    p.save!
end

environmental_ngo.each_with_index do |ngo, index|
  p = Project.new(name:environmental_project_name[index],
                  description:Faker::Commerce.product_name,
                  focus_area:FOCUS_AREAS.second,
                  main_contact:Faker::Internet.email,
                  ngo:ngo)
    puts '        adding geos to project...'
    rand(1..3) do
      p.geos.push(Geo.all.sample)
    end
    p.save!
end

puts 'generating foundations...'
foundation_name = ['Mont Royale Foundation', 'Red Wagon Foundation']
foundation_name.each do |foundation|
  Foundation.create(name:foundation, logo:Faker::Cat.breed)
end

puts 'Adding users to foundations...'
i = 0
Foundation.all.each do |f|
  2.times do
    f.users.push(User.create(email: 'user'+i.to_s+'@user.com',password:'123456'))
    i += 1
  end
end

puts 'generating investments and their milestones...'
4.times do
  Project.all.each do |p|
    i = Investment.create(project:p,foundation:Foundation.all.sample)
    rand(1..4).times do
      Milestone.create!(task:MILESTONES_TASK.sample,investment:i,amount:(MILESTONES_AMOUNT.sample*[10,100,1000,10000].sample),deadline:Faker::Date.forward(180))
    end
  end
end

Project.all.each do |project|
  rand(1..2).times do
    project.geos.push(Geo.all.sample)
  end
  puts "added geos to project #{project.name}"
end


puts "generating demo infos"
  richard = User.create!(email:"richardtherich@richard.com",password:'123456')
  richard.foundation = Foundation.create!(name:"The best foundation there is",logo:"a stack of 100s")
  richard.save!

  environmental_project_name.each do |project_name|
    new_focus = FOCUS_AREAS.sample
    FOCUS_AREAS.delete_at(FOCUS_AREAS.index(new_focus))
    new_project = Project.create!(description:"helping the world anyway we can",name:project_name,focus_area:new_focus,main_contact:"thomas@gmail.com",ngo:environmental_ngo.sample)

    rand(1..3).times do
      new_project.geos.push(Geo.all.sample)
    end

    new_investment = Investment.create!(foundation:richard.foundation,project:new_project)
    new_investment.milestones.destroy_all
    rand(2..4).times do
      new_milestone = Milestone.create!(investment: new_investment,amount:MILESTONES_AMOUNT.sample*[100,1000,400].sample,task:MILESTONES_TASK.sample,deadline:Faker::Date.forward(60))
    end

  end
def create_richard
  richard = User.create!(email:"richardtherich@richard.com",password:'123456')
  richard.foundation = Foundation.create!(name:"The best foundation there is",logo:"a stack of 100s")
  richard.save!

  equiterre = Project.create!(ngo:'Equiterre',name:'Energy-Efficient Lighting')
end
