require './test/test_helper'

class InstallmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @test_org = Organisation.create(name:'test',charity_number:"adsada")
    @test_focus = FocusArea.create!(name:'test')
    @test_geo = Geo.create(name:'test land')
    @test_project = Project.create!(name:'test',description:'testing',focus_area: @test_focus,main_contact:'www@www.com',organisation: @test_org, geos:[@test_geo])
    @test_investment = Investment.create!(organisation:@test_org,project:@test_project)
  end

  def create_installments
    @locked_installment = Installment.create(amount:10000,investment:@test_investment,organisation:@test_org,task:"aaa",deadline:Date.today)
    @unlocked_installment = Installment.create(amount:10000,investment:@test_investment,organisation:@test_org,task:"aaa",deadline:Date.today,status:"unlocked")
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

  test "can unlock installment" do
    create_installments
    @locked_installment.unlock!
    assert @locked_installment.status == "unlocked"
  end

  test "can lock installment" do
    create_installments
    @unlocked_installment.lock!
    assert @unlocked_installment.status == "locked"
  end

  test "can rescind installment" do
    create_installments
    @locked_installment.rescind!
    assert @locked_installment.status == "rescinded"
  end

end
