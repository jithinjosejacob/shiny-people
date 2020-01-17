
Feature: Initiate Payment
  As an HR User
  I should be able to generate a new payslip for a new employee
  So that I can verify that payslip can be generated successfully

  Scenario: Initiate Payment
    When I generate a payslip for a new employee
    And I press Pay
    Then I should see payee data added to payment table
