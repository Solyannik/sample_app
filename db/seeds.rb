User.create!(name: "Example User",  
	         email: "olga@example.com", 
	         password: "foobar", 
	         password_confirmation: "foobar",
           admin: true,
           activated: true,
           activated_at: Time.zone.now)  

20.times do |n| 
  name = Faker::Name.name 
  email = "example-#{n+1}@example.com" 
  password = "password" 
  User.create!(name: name, 
  	           email: email, 
  	           password: password, 
  	           password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now) 
end

users = User.order(:created_at).take(6) 
20.times do 
  content = Faker::Lorem.sentence(word_count: 5, supplemental: true, random_words_to_add: 4) 
  users.each { |user| user.microposts.create!(content: content) }
end

users = User.all 
user = users.first 
following = users[2..50] 
followers = users[3..40] 
following.each { |followed| user.follow(followed) } 
followers.each { |follower| follower.follow(user) }
