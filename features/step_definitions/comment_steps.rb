When /^I enter a comment with content "([^"]*)"$/ do |content|
  fill_in("comment[comment]", :with => content)
  click_button("Add Comment")
end
