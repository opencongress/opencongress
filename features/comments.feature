Feature: Comments
  We should be able to add comments to pages and visit those comments.

  Scenario: Add a comment to a blog post
    Given an active user is logged in as "xyzxyz123123"
    When I go to a blog post titled "House Dems take on Wall Street Bonuses"
      And I enter a comment with content "blah blah blah"
      And I go to a blog post titled "House Dems take on Wall Street Bonuses"
    Then I should see "blah blah blah"