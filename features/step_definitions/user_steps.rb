When /^I track a bill$/ do
  @current_user = User.last
  bill = Bill.first
  visit url_for({:controller => "bill", :action => "show", :id => bill.ident})
  visit "/profile/track/#{bill.id}?type=Bill"
end

Given /^an active non-tos user is logged in as "(.*)"$/ do |login|
  @current_user = User.create!(
    :login => login,
    :password => 'generic',
    :password_confirmation => 'generic',
    :email => "dshettler-#{login}@gmail.com",
    :enabled => true,
    :is_banned => false,
    :accept_tos => false,
    :accept_terms => true
  )

  # :create syntax for restful_authentication w/ aasm. Tweak as needed.
  @current_user.activate

  visit "/login"
  fill_in("user[login]", :with => login)
  fill_in("user[password]", :with => 'generic')
  click_button("Login")
  response.body.should =~ /Logged/m
end

Given /^a newly created user is logged in as "(.*)"$/ do |login|
  visit "/register"
  fill_in("Login", :with => login)
  fill_in("Password", :with => 'generic')
  fill_in("user[password_confirmation]", :with => 'generic')
  fill_in("user[email]", :with => "dshettler-#{login}@gmail.com")
  fill_in("user[zipcode]", :with => "01585")
  check("user[accept_tos]")
  click_button("Signup")
  response.body.should =~ /Thank you for Signing Up/m
  user = User.find_by_login(login)
  code = user.activation_code
  visit "/account/activate/#{code}"
  response.body.should =~ /Thanks for registering/m
  visit "/logout"
  visit "/"
  fill_in("user[login]", :with => login)
  fill_in("user[password]", :with => 'generic')
  click_button("Login")
  response.body.should =~ /Logged/m

end

Given /^an active user is logged in as "(.*)"$/ do |login|
  @current_user = User.create!(
    :login => login,
    :password => 'generic',
    :password_confirmation => 'generic',
    :email => "dshettler-#{login}@gmail.com",
    :enabled => true,
    :is_banned => false,
    :accept_tos => true,
    :accept_terms => true
  )

  # :create syntax for restful_authentication w/ aasm. Tweak as needed.
  @current_user.activate

  visit "/login"
  fill_in("user[login]", :with => login)
  fill_in("user[password]", :with => 'generic')
  click_button("Login")
  response.body.should =~ /Logged/m
end

Given /^an existing user is logged in as "(.*)"$/ do |login|
  visit "/login"
  fill_in("user[login]", :with => login)
  fill_in("user[password]", :with => 'generic')
  click_button("Login")
  response.body.should =~ /Logged/m
end

