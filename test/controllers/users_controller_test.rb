require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup 
    @user = users(:olga) 
    @other_user = users(:archer) 
  end 

  test "index as admin including pagination and delete links" do  
    get users_path 
    log_in_as(@admin)
    assert_template 'users/index' 
    assert_select 'div.pagination' 
    first_page_of_users = User.paginate(page: 1) 
    first_page_of_users.each do |user| 
      assert_select 'a[href=?]', 
      user_path(user), text: user.name 
      unless user == @admin 
        assert_select 'a[href=?]', user_path(user), text: 'delete' 
      end 
    end 
    assert_difference 'User.count', -1 do 
      delete user_path(@non_admin) 
    end 
  end

  test "index as non-admin" do  
    get users_path 
    log_in_as(@non_admin)
    assert_select 'a', text: 'delete', count: 0 
  end 

  test "should redirect following when not logged in" do 
    get :following, id: @user 
    assert_redirected_to login_url 
  end 

  test "should redirect followers when not logged in" do 
    get :followers, id: @user 
    assert_redirected_to login_url 
  end
end
