Feature: Members of Congress
  We should be able to view the members of Congress.

  Scenario: Lookup an invalid zip
    Given I am on the home page
    When I fill in "Find Your Representatives" with "00000"
      And I press "Find My Reps"
    Then I should see "Your search did not return any members of Congress."
      
  Scenario: Lookup a member with a 5 digit zip
    Given I am on the home page
    When I fill in "Find Your Representatives" with "90039"
      And I press "Find My Reps"
    Then I should see "Rep. Diane Watson [D, CA-33]"
      And I should see "Rep. Xavier Becerra [D, CA-31]"
      And I should see "Rep. Adam Schiff [D, CA-29]"
      
  Scenario: Lookup a member with a 5+4 digit zip 
    Given I am on the zipcode lookup page
    When I fill in "zip5" with "90039"
      And I fill in "zip4" with "2632"
      And I press "Find My Reps"
    Then I should see "Rep. Diane Watson [D, CA-33]"
      And I should not see "Rep. Xavier Becerra [D, CA-31]"
      And I should not see "Rep. Adam Schiff [D, CA-29]"
      
      
  Scenario: Lookup a member with a street address and 5 digit zip 
    Given I am on the zipcode lookup page
    When I fill in "address" with "2901 Angus St."
      And I fill in "zip5" with "90039"
      And I press "Find My Reps"
    Then I should see "Rep. Diane Watson [D, CA-33]"
      And I should not see "Rep. Xavier Becerra [D, CA-31]"
      And I should not see "Rep. Adam Schiff [D, CA-29]"

    