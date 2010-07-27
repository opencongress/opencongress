module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
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
      '/people/senators'
    when /the representatives page/
      '/people/representatives'
    when /the advanced search page/
      '/search' 
    when /the page for blog articles tagged with "([^"]*)"/
      "/blog/#{CGI.escape($1)}"
    when /a blog post titled "([^"]*)"/
      a = Article.find_by_title($1)
      "/articles/view/#{a.to_param}"
    when /the zipcode lookup page/
      "/people/zipcodelookup"
    when /the forgot password page/
      "/account/forgot_password"

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
