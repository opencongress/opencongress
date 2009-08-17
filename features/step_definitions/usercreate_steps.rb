Given /^that I have created a user "([^\"]*)"$/ do |arg1|
  User.create!({:login => "joe", 
                :password => "password", 
                :password_confirmation => "password", 
                :email => "dshettler+joe@gmail.com"})
end

