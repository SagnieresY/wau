require './test/test_helper'

class ProjectTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @test_org = Organisation.create(name:'test', charity_number:"1234aa")
    @test_focus = FocusArea.create!(name:'test')
    @test_geo = Geo.create(name:'test land')
    @test_project = Project.create!(name:'test',description:'testing',focus_area: @test_focus,main_contact:'www@www.com',organisation: @test_org, geos:[@test_geo])

  end
  test 'save project with good params' do
    assert  Project.new(name:'test',description:'testing',focus_area: @test_focus,main_contact:'www@www.com',organisation: @test_org, geos:[@test_geo]).save
  end

  test 'doesnt save project without name' do
    assert_not  Project.new(description:'testing',focus_area: @test_focus,main_contact:'www@www.com',organisation: @test_org, geos:[@test_geo]).save
  end

  test 'doesnt save project without focus_area' do
    assert_not  Project.new(name:'test',description:'testing',main_contact:'www@www.com',organisation: @test_org, geos:[@test_geo]).save
  end

  test 'doesnt save project without main_contact' do
    assert_not  Project.new(name:'test',description:'testing',focus_area: @test_focus,organisation: @test_org, geos:[@test_geo]).save
  end

  test 'doesnt save project without organisation' do
    assert_not  Project.new(name:'test',description:'testing',focus_area: @test_focus,main_contact:'www@www.com', geos:[@test_geo]).save
  end

  test 'doesnt save project without geos' do
    assert_not  Project.new(name:'test',description:'testing',focus_area: @test_focus,main_contact:'www@www.com',organisation: @test_org).save

  end

  test 'destroy project with investments' do
    Investment.create!(organisation:@test_org,project:@test_project)
    assert @test_project.destroy
  end



end


