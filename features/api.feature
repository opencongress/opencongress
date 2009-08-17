Feature: Api
All API queries should function properly

Scenario: People by First Name
Given a newly created user is logged in as "dirt"
When I go to the people api
Then I should see "C001070"
When I go to the bills api
Then I should see "412246" 
