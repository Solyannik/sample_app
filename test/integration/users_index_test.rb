require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup 
    @user = users(:olga) 
  end 

  test "index including pagination" do  
    get users_path 
    log_in_as(@user)
    assert_template 'users/index' 
    assert_select 'div.pagination' 
    User.paginate(page: 1).each do |user| 
      assert_select 'a[href=?]', user_path(user), text: user.name 
    end 
  end
end
