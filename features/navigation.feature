Feature: Navigation
All navigation should function properly

Scenario: Navigate major sections
When I go to the senators page
Then I should see "All 100 members of the U.S. Senate"
When I go to the representatives page
Then I should see "House of Representatives"
When I go to the bills page
Then I should see "Most Viewed"
