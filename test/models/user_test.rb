require './test/test_helper'
class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'does not save a blank user' do
    user = User.new
    assert_not user.save
  end

  test 'returns array of attributes' do
    user = User.create!(email:'test@test.com',password:123456)
    user_id = user.id
    assert user.to_a == [user_id,user.email,user.created_at]
  end


end
