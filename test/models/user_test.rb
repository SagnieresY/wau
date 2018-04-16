require './test/test_helper'
class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'does not save a blank user' do
    user = User.new
    assert_not user.save
  end

  test 'does not save an user without email' do
    user = User.new(password:'123456')
    assert_not user.save
  end

  test 'does not save an user without password' do
    user = User.new(email:'thomas@email.com')
    assert_not user.save
  end

  test 'returns array of attributes' do
    user = User.create!(email:'test@test.com',password:123456)
    user_id = user.id
    assert user.to_a == [user_id,user.email,user.created_at]
  end

  test 'can delete user' do
    user = User.create(email:'test1@test.com',password:'123456')
    user_id = user.id
    assert user.destroy
  end

end
