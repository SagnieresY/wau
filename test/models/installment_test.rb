require './test/test_helper'

class InstallmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @test_org = Organisation.create(name:'test')
    @test_focus = FocusArea.create!(name:'test')
    @test_geo = Geo.create(name:'test land')
    @test_project = Project.create!(name:'test',description:'testing',focus_area: @test_focus,main_contact:'www@www.com',organisation: @test_org, geos:[@test_geo])
    @test_investment = Investment.create!(organisation:@test_org,project:@test_project)
  end

  test "saves valid installment" do
    assert Installment.new(amount:100,task:'testing',deadline:Date.today,investment:@test_investment).save
  end

  test "assign 0 if amount if left blank whilne creating installment" do
    installment = Installment.create(task:'testing',deadline:Date.today,investment:@test_investment)
    assert installment.amount == 0
  end

  test "doesnt save installment without task" do
    assert_not Installment.new(amount:100,deadline:Date.today,investment:@test_investment).save
  end

  test "doesnt save installment without deadline" do
    assert_not Installment.new(amount:100,task:'testing',investment:@test_investment).save
  end

  test "doesnt save installment without investment" do
    assert_not Installment.new(amount:100,task:'testing',deadline:Date.today).save
  end

end
