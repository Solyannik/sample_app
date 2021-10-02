require 'test_helper' 

class StaticPagesControllerTest < ActionController::TestCase 

  test "should get home" do 
    get :home 
    assert_response :success 
    assert_select "title", "Образец учебного приложения Ruby on Rails" 
  end 

  test "should get help" do 
    get :help 
    assert_response :success 
    assert_select "title", "Help | Образец учебного приложения Ruby on Rails" 
  end 
end
