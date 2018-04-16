require './test/test_helper'

class OrganisationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @test_org = Organisation.create(name:'testing')
    @test_focus = FocusArea.create!(name:'test')
    @test_geo = Geo.create(name:'test land')
    @test_project = Project.create!(name:'test',description:'testing',focus_area: @test_focus,main_contact:'www@www.com',organisation: @test_org, geos:[@test_geo])
    @test_investment = Investment.create!(organisation:@test_org,project:@test_project)

  end

  test "doesnt save without a name" do
    assert_not Organisation.new.save
  end

  test "saves with name" do
    assert Organisation.new(name:'testt').save
  end

  test "doesnt save without uniq name" do
    Organisation.create(name:'test')
    assert_not Organisation.new(name:'test').save
  end

  test "can delete an org with investments" do
    test_org = Organisation.create!(name:'test')
    focus = FocusArea.create!(name:'test')
    geo = Geo.create(name:'test land')
    project = Project.create!(name:'test',description:'testing',focus_area: focus,main_contact:'www@www.com',organisation: test_org, geos:[@test_geo])

    Investment.create!(organisation: test_org, project: project)

    assert test_org.destroy
  end

  test "returns correct total locked amount" do
    10.times do
      Installment.create(amount:100, task:'meme',deadline:Date.today,investment:@test_investment)
    end

    assert @test_org.locked_amount == 100*10
  end

end
