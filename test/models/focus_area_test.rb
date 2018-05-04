
require './test/test_helper'

class FocusAreaTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @test_org = Organisation.create(name:'test', charity_number:rand(1..10000).to_s)

    @test_focus = FocusArea.create!(name:'test')
    @test_geo = Geo.create(name:'test land')
    @test_project = Project.create!(name:'test',description:'testing',focus_area: @test_focus,main_contact:'www@www.com',organisation: @test_org, geos:[@test_geo])
    @test_investment = Investment.create!(organisation:@test_org,project:@test_project, status:"active")
  end

  def reset_org
    @test_org = Organisation.create(name:rand(1..1000).to_s,charity_number:rand(1..10000).to_s)
    @test_investment = Investment.create(organisation:@test_org,project:@test_project,status:"active")
    @test_focus.installments.destroy_all

  end

  test "saves valid focus" do
    assert FocusArea.new(name:'test').save
  end

  test "doesnt save focus without name" do
    assert_not FocusArea.new().save
  end

  test "returns unlocked installments" do
    reset_org
    array = []
    10.times do |i|
      Installment.create(task:"a",amount:1,deadline:Date.today,investment:@test_investment,organisation:@test_org)
      array.push(Installment.create(task:"a",amount:1,deadline:Date.today,investment:@test_investment,organisation:@test_org,status:"unlocked")) if i.odd?
    end
    assert array == @test_focus.unlocked_installments
  end

  test "returns locked installments" do
    reset_org
    array = []
    10.times do |i|
      Installment.create(task:"a",amount:1,deadline:Date.today,investment:@test_investment,organisation:@test_org,status:"unlocked")
      array.push(Installment.create(task:"a",amount:1,deadline:Date.today,investment:@test_investment,organisation:@test_org)) if i.odd?
    end

    assert array == @test_focus.locked_installments
  end

   test "returns rescinded installments" do
    reset_org
    array = []
    10.times do |i|
      Installment.create(task:"a",amount:1,deadline:Date.today,investment:@test_investment,organisation:@test_org,status:"unlocked")
      array.push(Installment.create(task:"a",amount:1,deadline:Date.today,investment:@test_investment,organisation:@test_org,status:"recinded"))
    end
    byebug
    assert array == @test_focus.rescinded_installments
  end

  test "returns correct unlocked amount" do
    reset_org
    sum = 0
    10.times do |i|
      u = Installment.create(task:"a",amount:1,deadline:Date.today,investment:@test_investment,organisation:@test_org,status:"unlocked")
      sum += u.amount
      Installment.create(task:"a",amount:2,deadline:Date.today,investment:@test_investment,organisation:@test_org)
    end
    assert sum == @test_focus.unlocked_amount
  end

  test "returns correct locked amount" do
    reset_org
    sum = 0
    10.times do |i|
      Installment.create(task:"a",amount:1,deadline:Date.today,investment:@test_investment,organisation:@test_org,status:"unlocked")

      u = Installment.create(task:"a",amount:2,deadline:Date.today,investment:@test_investment,organisation:@test_org)

      sum += u.amount
    end

    assert sum == @test_focus.locked_amount
  end
end
