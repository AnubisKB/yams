Feature: YAMS - Yet Another Messaging Service
  In order to use YAMS as a messaging service
  As a software application that implements a YAMS API client
  It should be able to

  Scenario: Create a new message to one recipient
    When a request is issued to the YAMS service to create a new message with:
      | From Address | To Addresses | Message Subject | Message Body     |
      | kburns       | tearle       | One             | Test Body Single |
    Then the message is created in the database
    And the message identifier is returned
    And the response status code is 201

  Scenario: Create a new message to multiple recipients
    When a request is issued to the YAMS service to create a new message with:
      | From Address | To Addresses           | Message Subject | Message Body    |
      | tearle       | kburns,kstalzer,tearle | Many            | Test Body Multi |
    Then the message is created in the database
    And the message identifier is returned
    And the response status code is 201

  Scenario: Fail trying to create a new message with no from address
    When a request is issued to the YAMS service to create a new message with:
      | From Address | To Addresses    | Message Subject | Message Body         |
      |              | kstalzer,tearle | Many            | Missing From Address |
    Then there is no message in the database with Message Body "Missing From Address"
    And the response status code is 500

  Scenario: Fail trying to create a new message with no to recipients
    When a request is issued to the YAMS service to create a new message with:
      | From Address | To Addresses | Message Subject | Message Body       |
      | kburns       |              | Zero            | Missing To Address |
    Then there is no message in the database with Message Body "Missing To Address"
    And the response status code is 500

  Scenario: Fail trying to create a new message with a bad from address
    When a request is issued to the YAMS service to create a new message with:
      | From Address | To Addresses    | Message Subject | Message Body     |
      | hacker       | kstalzer,tearle | Many            | Bad From Address |
    Then there is no message in the database with Message Body "Bad From Address"
    And the response status code is 500

  Scenario: Fail trying to create a new message with only a bad to recipient
    When a request is issued to the YAMS service to create a new message with:
      | From Address | To Addresses | Message Subject | Message Body   |
      | kburns       | hacker       | Zero            | Bad To Address |
    Then there is no message in the database with Message Body "Bad To Address"
    And the response status code is 500

  Scenario: Get all messages
    When a request is issued to the YAMS service to get all messages
    Then all the messages are returned:
      | From Address | To Addresses    | Message Subject | Message Body |
      | kburns       | kstalzer,tearle | Test Subject 1  | Test Body 1  |
      | kstalzer     | kburns,tearle   | Test Subject 2  | Test Body 2  |
      | tearle       | larry           | Test Subject 3  |              |
      | kdumont      | kburns          | Test Subject 3  | Test Body 4  |
    And the response status code is 200

  Scenario Outline: Get a specific message
    When a request is issued to the YAMS service to get a specific message with Message Id "<Message Id>"
    Then the following message is returned:
      | From Address   | To Addresses   | Message Subject   | Message Body   |
      | <From Address> | <To Addresses> | <Message Subject> | <Message Body> |
    And the response status code is 200
    Examples:
      | Message Id | From Address | To Addresses    | Message Subject | Message Body |
      | 1          | kburns       | kstalzer,tearle | Test Subject 1  | Test Body 1  |
      | 2          | kstalzer     | kburns,tearle   | Test Subject 2  | Test Body 2  |
      | 3          | tearle       | larry           | Test Subject 3  |              |
      | 4          | kdumont      | kburns          | Test Subject 3  | Test Body 4  |

  Scenario Outline: Receive a resource not found status when trying to get a specific message that does not exist
    When a request is issued to the YAMS service to get a specific message with Message Id "<Message Id>"
    Then the response status code is 404
    Examples:
      | Message Id |
      | 0          |
      | 9999       |
      | 5          |
      | 42         |
      | -1         |

  Scenario: Delete a specific message
    Given a message exists that is going to be deleted
    When a request is issused to the YAMS service to delete that message
    Then the message cannot be found in the database
    And the response status code is 204

  Scenario Outline: Receive a resource not found status when trying to delete a specific message that does not exist
    When a request is issued to the YAMS service to delete a specific message with Message Id "<Message Id>"
    Then the response status code is 404
    Examples:
      | Message Id |
      | 0          |
      | 9999       |
      | 5          |
      | 42         |
      | -1         |
