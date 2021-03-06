require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup 
    @user = users(:olga) 
  end
  
  test "layout links" do 
    get root_path 
    assert_template 'static_pages/home' 
    assert_select "a[href=?]", root_path, count: 2 
    assert_select "a[href=?]", help_path 
    get signup_path
    assert_select "title", "Регистрация | Образец учебного приложения Ruby on Rails"
  end
end
