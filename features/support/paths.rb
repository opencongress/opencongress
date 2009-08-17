module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the homepage/
      '/'
    when /the login page/
      '/account/login'
    when /the people api/
      u = User.last.feed_key
      "/api/people?key=#{u}&last_name=Casey"
    when /the bills api/
      u = User.last.feed_key
      "/api/bills?key=#{u}&number=809"
    when /the api page/
      '/api'
    when /the committees page/
      '/committees'
    when /the bills page/
      '/bill/all'
    when /the senators page/
      '/person/senators'
    when /the representatives page/
      '/person/representatives'

    
    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
