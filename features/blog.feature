Feature: Blog
  Blog should act like a blog.

  Scenario: Blog should return articles with proper tags
    When I go to the page for blog articles tagged with "Financial Reform"
    Then I should see "Will the Agriculture Committee Hand Wall Street a Big Win on Derivatives?"
    
  Scenario: Blog should return articles with proper tags regardless of case
    When I go to the page for blog articles tagged with "financial reform"
    Then I should see "Will the Agriculture Committee Hand Wall Street a Big Win on Derivatives?"
    And I should see "House Dems take on Wall Street Bonuses"