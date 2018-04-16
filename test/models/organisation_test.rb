require './test/test_helper'

class OrganisationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
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
    project = Project.create!(name:'test',description:'testing',focus_area: focus,main_contact:'www@www.com',organisation: test_org, geos:[geo])
    Investment.create!(organisation: test_org, project: project)
    assert test_org.destroy
  end
end
