
require './test/test_helper'

class FocusAreaTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @test_org = Organisation.create(name:'test', charity_number:"1234aa")
    @test_focus = FocusArea.create!(name:'test')
    @test_geo = Geo.create(name:'test land')
    @test_project = Project.create!(name:'test',description:'testing',focus_area: @test_focus,main_contact:'www@www.com',organisation: @test_org, geos:[@test_geo])
    @test_investment = Investment.create!(organisation:@test_org,project:@test_project)
  end

  test "saves valid focus" do
    assert FocusArea.new(name:'test').save
  end

  test "doesnt save focus without name" do
    assert_not FocusArea.new().save
  end

  test "can destroy focus" do
    assert @test_focus.destroy
  end


end
