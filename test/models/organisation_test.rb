require './test/test_helper'

class OrganisationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @test_org = Organisation.create(name:'testing',charity_number:rand(1..10000).to_s)
    @test_focus = FocusArea.create!(name:'test')
    @test_geo = Geo.create(name:'test land')
    @test_project = Project.create!(name:'test',description:'testing',focus_area: @test_focus,main_contact:'www@www.com',organisation: @test_org, geos:[@test_geo])
    @test_investment = Investment.create!(organisation:@test_org,project:@test_project)

  end
  def reset_org
    @test_org = Organisation.create(name:rand(1..1000).to_s,charity_number:rand(1..10000).to_s)
    @test_investment = Investment.create(organisation:@test_org,project:@test_project)
  end

  test "doesnt save without a charity_number" do
    assert_not Organisation.new(charity_number:'aaaaa').save
  end

  test "doesnt save without a name" do
    assert_not Organisation.new(charity_number:'aaaaa').save
  end

  test "saves with name and charity_number" do
    assert Organisation.new(name:'testt',charity_number:rand(1..10000).to_s).save
  end

  test "doesnt save without uniq name" do
    Organisation.create(name:'test')
    assert_not Organisation.new(name:'test').save
  end

  test "returns correct total locked amount" do
    10.times do
      Installment.create(amount:100, task:'meme',deadline:Date.today,investment:@test_investment)
    end

    assert @test_org.locked_amount == 100*10
  end

  test "returns correct unlocked amount" do
    10.times do |i|
      Installment.create(amount:100, task:'meme',deadline:Date.today,investment:@test_investment,status:'unlocked') if i.odd?
      Installment.create(amount:100, task:'meme',deadline:Date.today,investment:@test_investment) unless i.odd?
    end
    assert @test_org.unlocked_amount == 100*5
  end

  test "returns correct forecasted amount for year" do
    10.times do
      Installment.create(amount:100, task:'meme',deadline:Date.today,investment:@test_investment,status:'unlocked')
      Installment.create(amount:100, task:'meme',deadline:(Date.today + 500),investment:@test_investment)
    end
    assert @test_org.amount_for_year == 100*10
  end

  test "returns correct completed investments" do
    array = []
    10.times do |i|
      array.push(Investment.create(organisation:@test_org,project:@test_project,completed:true)) if i.odd?
      Investment.create(organisation:@test_org,project:@test_project)
    end
    assert @test_org.completed_investments == array
  end

  test "returns correct uncompleted investments" do
    array = []
    reset_org
    @test_investment.destroy!
    10.times do |i|
      array.push(Investment.create(organisation:@test_org,project:@test_project)) if i.odd?
      Investment.create(organisation:@test_org,project:@test_project,completed:true)
    end

    assert @test_org.uncompleted_investments == array
  end

  test "returns the corrects next installments" do
    array = []
    @test_org.investments.first.destroy!
    10.times do |i|
      invest = Investment.create!(organisation:@test_org,project:@test_project)
      2.times do |num|
        inst = Installment.create!(amount:100, task:num.to_s,deadline:(Date.new(num+1+i,1,1)),investment:invest)
        array.push(inst) if num == 0
      end
    end

    assert @test_org.next_installments == array
  end

  test "returns the corrects upcoming installments" do
    array = []
    reset_org
    10.times do |i|
      Installment.create(amount:100, task:'meme',deadline:(Date.today + 400),investment:@test_investment)
      array.push(Installment.create(amount:100, task:'meme',deadline:(Date.today),investment:@test_investment))
    end

    assert @test_org.upcoming_installments == array
  end

  test "returns the correct unlocked installments" do
    array =  []
    10.times do |i|
      inst = Installment.create(investment:@test_investment,amount:100,task:"test",deadline:Date.today,status: i.odd? ? "unlocked" : nil)
      array.push(inst) if inst.unlocked?
    end
    assert @test_org.unlocked_installments == array
  end

  test "returns the correct locked installments" do
    array =  []
    10.times do |i|
      inst = Installment.create(investment:@test_investment,amount:100,task:"test",deadline:Date.today,status: i.odd? ? "locked" : nil)
      array.push(inst) if inst.locked?
    end
    assert @test_org.locked_installments == array
  end
end
