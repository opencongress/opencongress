Feature: Users
Users should be able to signup
and login properly

Scenario: Track Bill
Given a newly created user is logged in as "dirt"
When I track a bill
Then I should see "I'm tracking this Bill"
