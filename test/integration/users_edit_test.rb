require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup 
    @user = users(:olga) 
  end

  test "unsuccessful edit" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name: "",
                                    email: "user@invalid",
                                    password:              "foo",
                                    password_confirmation: "bar" }
    assert_template 'users/edit'
  end

  test "successful edit" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name = "Name"
    email = "valid@valid.com"
    patch user_path(@user), user: { name: name, 
                                    email: email,
                                    password: "",
                                    password_confirmation: "" }
    assert_not flash.empty? 
    assert_redirected_to @user 
    @user.reload 
    assert_equal name, @user.name 
    assert_equal email, @user.email 
  end 
end
