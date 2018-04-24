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


puts "generating focus_areas"

[["Ageing", "Vieillissement de personnes"],
 ["Agriculture & Food", "Agriculture et Alimentation"],
 ["Animal Health & Rights", "Droits des animaux"],
 ["Business & Economic Policy", "Politique commerciale et conomique"],
 ["Children & Youth", "Enfants et jeunesse"],
 ["Communications & Media", "Communications et mdias"],
 ["Conflict Resolution", "Résolution de conflit"],
 ["Development", "Développement"],
 ["Education", "Éducation"],
 ["Environment", "Environnement"],
 ["Family", "Famille"],
 ["Health & Nutrition", "Sant et nutrition"],
 ["Human Rights", "Droits de l'homme"],
 ["Indigenous People", "Indigènes"],
 ["International Organization", "Organisation internationale"],
 ["Labor", "Droit du travail"],
 ["Law & Legal Affairs", "Droit et affaires juridiques"],
 ["Narcotics, Drugs & Crime", "Narcotiques, Drogues et Crime"],
 ["Peace & Security", "Paix et sécurité"],
 ["Population/ Human Settlements", "Population / Implantations humaines"],
 ["Refugees", "Réfugiés"],
 ["Relief Services", "Services de secours"],
 ["Religion, Belief & Ethics", "Religion, Croyance et Ethique"],
 ["Science & Technology", "Technologie & Science"],
 ["Social & Cultural Development", "Développement social et culturel"],
 ["Sports & Recreation", "Sports et loisirs"],
 ["Trade & International Finance", "Commerce et finance internationale"],
 ["Transportation", "Transport"],
 ["Women`s Status & Issues", "Droits de la femme"]].each do |fa|
  f = FocusArea.new
  f.attributes = { name: fa[0], locale: :en }
  f.attributes = { name: fa[1], locale: :fr }
  f.save!
end

puts 'generating geos...'
neighbourhood_montreal = ['Ahuntsic-Cartierville', 'Anjou', 'Côte-des-Neiges–Notre-Dame-de-Grâce', 'Lachine', 'LaSalle', 'Le Plateau-Mont-Royal', 'Le Sud-Ouest', 'Île-Bizard–Sainte-Geneviève', 'Mercier–Hochelaga-Maisonneuve', 'Montréal-Nord', 'Outremont', 'Pierrefonds-Roxboro', 'Rivière-des-Prairies–Pointe-aux-Trembles', 'Rosemont–La Petite-Patrie', 'Saint-Laurent', 'Saint-Léonard', 'Verdun', 'Ville-Marie', 'Other neighbourhoods', 'Villeray', 'West Island']

neighbourhood_montreal.each do |neighbourhood|
  Geo.create(name:neighbourhood)
end


humanrights_ngo = ['Amnesty International', 'UNICEF', 'Human Rights Watch'].map{|ngo| Organisation.create!(name:ngo,charity_number:rand(10000.99999))}
humanrights_project_name = ['Welcome Refugees to Montreal', 'Open a New Shelter', 'Fund Awareness Campaign']
childcare_ngo = ['Save The Children Canada', 'Montreal Children\'s Hospital'].map{|ngo| Organisation.create!(name:ngo,charity_number:rand(10000.99999))}
childcare_project_name = ['Give Coding lessons in School', 'Cancer Research']
community_ngo = ['Santropole Roulant', 'YMCA', 'Women Aware Femme Averties', 'Kids Code Jeunesse'].map{|ngo| Organisation.create!(name:ngo,charity_number:rand(10000.99999))}
community_project_name = ['Open New Farms', 'Renovate basketball court', 'Legal Defense', 'Create Afterschool Programs']
environmental_ngo = ['Equiterre', 'Canadian Wind Energy Association', 'Greenpeace Canada'].map{|ngo| Organisation.create!(name:ngo,charity_number:rand(10000.99999))}
environmental_project_name = ['Energy-Efficient Lighting', 'R&D for Electric Turbines', 'Global Climate March']

puts "generating tags"
tags = ["Handicaped Children", "Elderly Motility", "copper", "truck", "neat", "unite", "branch", "educated", "tenuous", "hum", "decisive", "notice"]

Organisation.all.each do |organisation|
    tags.sample(3).each do |tag|
      InvestmentTag.create(name:tag, organisation:organisation)
  end
end

puts 'generating projects...'

1.times do
  humanrights_project_name.each do |project_name|
    geos = []
    rand(0..2).times do
      geos.push(Geo.all.sample)
    end
    me = Project.create(
      name:project_name,
      description:"non-offensive project description",
      main_contact:"veryrealemail@actually.no",
      organisation: humanrights_ngo.sample,
      focus_area: FocusArea.all.sample,
      geos: [Geo.all.sample]
      )
  end

  childcare_project_name.each do |project_name|
    geos = []
    rand(0..2).times do
      geos.push(Geo.all.sample)
    end
    me = Project.create(
      name:project_name,
      description:"non-offensive project description",
      main_contact:"veryrealemail@actually.no",
      organisation: childcare_ngo.sample,
      focus_area: FocusArea.all.sample,
      geos: [Geo.all.sample]
      )
  end

  community_project_name.each do |project_name|
    geos = []
    rand(0..2).times do
      geos.push(Geo.all.sample)
    end
    me = Project.create(
      name:project_name,
      description:"non-offensive project description",
      main_contact:"veryrealemail@actually.no",
      organisation: community_ngo.sample,
      focus_area: FocusArea.all.sample,
      geos: [Geo.all.sample]
      )
  end

  environmental_project_name.each do |project_name|
    geos = []
    rand(0..2).times do
      geos.push(Geo.all.sample)
    end
    me = Project.create(
      name:project_name,
      description:"non-offensive project description",
      main_contact:"veryrealemail@actually.no",
      organisation: environmental_ngo.sample,
      focus_area: FocusArea.all.sample,
      geos: [Geo.all.sample]
      )
  end
end

puts 'generating organisations...'
organisation_name = ['Mont Royale Organisation', 'Red Wagon Organisation']
organisation_name.each do |organisation|
  Organisation.create(name:organisation, logo:Faker::Cat.breed,charity_number:rand(10000..99999))
end

puts 'Adding users to organisations...'
i = 0
Organisation.all.each do |f|
  2.times do
    f.users.push(User.create(email: 'user'+i.to_s+'@user.com',password:'123456'))
    i += 1
  end
end

puts 'generating investments and their installments and adding tags...'
Project.all.each do |p|
  Organisation.all.each do |f|
    i = Investment.create(project:p,organisation:f)
    i.investment_tags.push(InvestmentTag.all.sample(2))
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

puts 'Generating BIG BOI. Take seat for awhile, smoke one for Jared maybe?...'
bigboi = Organisation.create!(name:'bigboi',charity_number:818801)
bigboi.users.push(User.create!(email:"bigboi@big.boi",password:'123456'))
30.times do
  orgs = Organisation.all.reject{|o| o.name == "bigboi"}
  humanrights_project_name.each do |project_name|
    geos = []
    rand(0..2).times do
      geos.push(Geo.all.sample)
    end
    me = Project.create(
      name:project_name,
      description:"non-offensive project description",
      main_contact:"veryrealemail@actually.no",
      organisation: orgs.sample,
      focus_area: FocusArea.all.sample,
      geos: [Geo.all.sample]
      )
    4.times do |years|
      this_year = Date.today.year + years
      firstday = Date.new(this_year, 1 ,1)
      lastday = firstday + 365

      invest = Investment.create!(project:me,organisation:bigboi)
        rand(2..4).times do
          Installment.create!(investment:invest,amount:rand(50000..600000),task:INSTALLMENT_TASK.sample,deadline:Faker::Date.between(Date.today, lastday))
        end
      end
  end

  childcare_project_name.each do |project_name|
    geos = []
    rand(0..2).times do
      geos.push(Geo.all.sample)
    end
    me = Project.create(
      name:project_name,
      description:"non-offensive project description",
      main_contact:"veryrealemail@actually.no",
      organisation: orgs.sample,
      focus_area: FocusArea.all.sample,
      geos: [Geo.all.sample]
      )
    4.times do |years|
      this_year = Date.today.year + years
      firstday = Date.new(this_year, 1 ,1)
      lastday = firstday + 365

      invest = Investment.create!(project:me,organisation:bigboi)
        rand(2..4).times do
          Installment.create!(investment:invest,amount:rand(50000..600000),task:INSTALLMENT_TASK.sample,deadline:Faker::Date.between(Date.today, lastday))
        end
      end
  end

  community_project_name.each do |project_name|
    geos = []
    rand(0..2).times do
      geos.push(Geo.all.sample)
    end
    me = Project.create(
      name:project_name,
      description:"non-offensive project description",
      main_contact:"veryrealemail@actually.no",
      organisation: orgs.sample,
      focus_area: FocusArea.all.sample,
      geos: [Geo.all.sample]
      )
    4.times do |years|
      this_year = Date.today.year + years
      firstday = Date.new(this_year, 1 ,1)
      lastday = firstday + 365

      invest = Investment.create!(project:me,organisation:bigboi)
        rand(2..4).times do
          Installment.create!(investment:invest,amount:rand(50000..600000),task:INSTALLMENT_TASK.sample,deadline:Faker::Date.between(Date.today, lastday))
        end
      end
  end

  environmental_project_name.each do |project_name|
    geos = []
    rand(0..2).times do
      geos.push(Geo.all.sample)
    end
    me = Project.create(
      name:project_name,
      description:"non-offensive project description",
      main_contact:"veryrealemail@actually.no",
      organisation: orgs.sample,
      focus_area: FocusArea.all.sample,
      geos: [Geo.all.sample]
      )
    4.times do |years|
      this_year = Date.today.year + years
      firstday = Date.new(this_year, 1 ,1)
      lastday = firstday + 365

      invest = Investment.create!(project:me,organisation:bigboi)
        rand(2..4).times do
          Installment.create!(investment:invest,amount:rand(50000..600000),task:INSTALLMENT_TASK.sample,deadline:Faker::Date.between(Date.today, lastday))
        end
      end
  end
end

#PLEASE KEEP FOR TRANSLATION PURPOSES
# fa = ["Ageing",
#  "Agriculture & Food",
#  "Animal Health & Rights",
#  "Business & Economic Policy",
#  "Children & Youth",
#  "Communications & Media",
#  "Conflict Resolution",
#  "Development",
#  "Education",
#  "Environment",
#  "Family",
#  "Health & Nutrition",
#  "Human Rights",
#  "Indigenous People",
#  "International Organization",
#  "Labor",
#  "Law & Legal Affairs",
#  "Narcotics, Drugs & Crime",
#  "Peace & Security",
#  "Population/ Human Settlements",
#  "Refugees",
#  "Relief Services",
#  "Religion, Belief & Ethics",
#  "Science & Technology",
#  "Social & Cultural Development",
#  "Sports & Recreation",
#  "Trade & International Finance",
#  "Transportation",
#  "Women`s Status & Issues"]

# fafr = ["Vieillissement",
#  "Agriculture et Alimentation",
#  "Droits des animaux",
#  "Politique commerciale et économique",
#  "Enfants et jeunesse",
#  "Communications et médias",
#  "Résolution de conflit",
#  "Développement",
#  "Éducation",
#  "Environnement",
#  "Famille",
#  "Santé et nutrition",
#  "Droits de l'homme",
#  "Indigènes",
#  "Organisation internationale",
#  "Droit du travail",
#  "Droit et affaires juridiques",
#  "Narcotiques, Drogues et Crime",
#  "Paix et sécurité",
#  "Population / établissements humains",
#  "Réfugiés",
#  "Services de secours",
#  "Religion, Croyance et Ethique",
#  "Technologie & Science",
#  "Développement social et culturel",
#  "Sports et loisirs",
#  "Commerce et finance internationale",
#  "Transport",
#  "Statut de la femme et questions"]

# fa.zip(fafr)

