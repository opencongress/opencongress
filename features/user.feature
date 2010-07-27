Feature: Users
  Users should be able to signup
  and login properly

  Scenario: Track Bill
    Given a newly created user is logged in as "dirt"
    When I track a bill
    Then I should see "Tracking Now"

  Scenario: Forgot password invalid email
    Given I am on the forgot password page
    When I fill in "user[email]" with "awioehkjahwelguhawjeghkjlh"
      And I press "Request Password"
    Then I should see "Could not find a user with that email address."

  Scenario: Forgot password valid email
    Given I am on the forgot password page
    When I fill in "user[email]" with "donnydonnyzxcasdqwe@gmail.com"
      And I press "Request Password"
    Then I should see "A reset password link has been sent to your email address."

  Scenario: Forgot password valid email, case-insensitive
    Given I am on the forgot password page
    When I fill in "user[email]" with "doNnydOnnyZxcasdQwe@gMaIl.com"
      And I press "Request Password"
    Then I should see "A reset password link has been sent to your email address."
