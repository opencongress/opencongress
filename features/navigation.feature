Feature: Navigation
All navigation should function properly

  Scenario: Navigate major sections
    When I go to the senators page
    Then I should see "all 100 members of the current U.S. Senate"
    
    When I go to the representatives page
    Then I should see "House of Representatives"
    
    When I go to the bills page
    Then I should see "All Legislation in Congress"
    
    When I go to the advanced search page
    Then the "search-field-advanced" field should contain ""
    