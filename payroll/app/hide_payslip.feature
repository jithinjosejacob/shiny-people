
Feature: Hide Payslip
  As an HR User
  I should be able to hide payslip data which was opened
  So that I can navigate back to dashboard page again

  Scenario: Hide Payslip
    When I generate a payslip for a new employee
    And I press Hide
    Then I should not see the payslip table
