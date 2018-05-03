require './test/test_helper'

class InvestmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @test_org = Organisation.create(name:'test',charity_number:rand(1..10000).to_s)
    @test_focus = FocusArea.create!(name:'test')
    @test_geo = Geo.create(name:'test land')
    @test_project = Project.create!(name:'test',description:'testing',focus_area: @test_focus,main_contact:'www@www.com',organisation: @test_org, geos:[@test_geo])
  end

  test "doesn't save without organisation" do
    assert_not Investment.new(project: @test_project).save
  end

  test "doesn't save without project" do
    assert_not Investment.new(organisation: @test_org).save
  end

  test "saves with good attributes" do
    assert investment = Investment.new(organisation: @test_org, project: @test_project).save

  end
  test "can destroy an investments" do
    investment = Investment.create(organisation: @test_org, project: @test_project)

    assert investment.destroy
  end

  test "can destroy an investment with installments" do
    investment = Investment.create(organisation: @test_org, project: @test_project)
    Installment.create!(investment:investment,amount:100,task:'testing',deadline:Date.today)
    assert investment.destroy
  end

end

