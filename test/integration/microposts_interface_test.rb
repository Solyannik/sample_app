require 'test_helper' 

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest 
  def setup 
    @user = users(:olga) 
  end 

  test "micropost interface" do 
    get root_path 
    log_in_as(@user) 
    assert_select 'div.pagination' 
    # Invalid submission 
    assert_no_difference 'Micropost.count' do 
      post microposts_path, micropost: { content: "" } 
    end 
    assert_select 'div#error_explanation' 
    # Valid submission 
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png') 
    assert_difference 'Micropost.count', 1 do 
      post microposts_path, micropost: { content: content } 
    end 
    assert_redirected_to root_url 
    follow_redirect! 
    assert_match content, response.body 
    # Delete a post. 
    assert_select 'a', text: 'delete' 
    first_micropost = @user.microposts.paginate(page: 1).first 
    assert_difference 'Micropost.count', -1 do 
      delete micropost_path(first_micropost) 
    end 
    # Visit a different user. 
    get user_path(users(:archer)) 
    assert_select 'a', text: 'delete', count: 0 
  end 

  test "micropost sidebar count" do 
    get root_path
    log_in_as(@user)  
    # User with zero microposts 
    other_user = users(:malory) 
    log_in_as(other_user) 
    get root_path 
    assert_match "0 microposts", response.body 
    other_user.microposts.create!(content: "A micropost") 
    get root_path 
    assert_match content, response.body 
  end
end
