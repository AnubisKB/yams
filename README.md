YAMS - Yet Another Messaging Service

Goals:
 - Meet the expectations of the exercise using Go
 - Demonstrate the High-Confidence/Low-Risk value using proper ATDD/TDD techniques 
    - Demonstrate the use of executable Acceptance Tests to drive system behavioral test driving/coverage (Business Motivated)
    - Demonstrate the use of Unit Tests to drive development of quality and testable design (Engineering Motivated)


Points of Note:
 - This solution is intended to demonstrate a 'Minimally Viable Product'
    - This is the kind of base that an Agile iteratative development cycle supports: Drive everything by demonstarble Business Value every sprint
    - Initial address data expected; no methods to manage user addresses
    - No database mocking (as normally should be) for speed of development; initial test data resides in the database for unit/acceptance tests
    - Data tables do not contain the usual audit trail fields (not defined as part of the MVP)
    - Any address used that doesn't exist in the database will be ignored (this will cause an error if an address used doesn't exist)
    - Simple Business Logic (App) feature implementation
        - No authentication
        - No operation authorization
        - Designed to show separation of responsibilty (even though here it is mostly a simple pass-thru of data)
    - Use of the Go 'gin' micro-service framework; don't recreate the wheel - stay focused on the business value
    - Not as much test coverage as I normally like, but it should be enough for demonstration purposes


Dependencies:
 - PostgreSql (9.6 was used)
 - Ruby (2.3.3 was used)
 - ruby gem 'Bundler'
 - the ability to compile the ruby gem 'PG' natively
 - go (1.10 was used)
 

Install: 
 - clone the YAMS repo locally
 - go get -u github.com/gin-gonic/gin
 - go get -u github.com/lib/pq
 - cukes/bundle
 - run the sql scripts in the db directory in the postgres.public schema
    - create_db_objects.sql
    - test_setup.sql

Run:
 - Unit tests (from /src):                              
    - go test -v ./...
 - Main (from /src): 
    - go run main.go
 - Acceptance tests (with main running, from /cukes):
    - rake

Usage:
 - Create a message: POST <host:port>/yams/ (with payload: 
        {
            "from":"<address:required>", 
            "to":["<address:required>","<address>..."], 
            "subject":"<subject>",
            "body":"<body>"
        }
   )
 - Retrieve all messages: GET <host:port>/yams
 - Retrieve a specific message: GET <host:port>/yams/:message_id
 - Delete a specific message: DELETE <host:port>/yams/:message_id


Responses:
 - Valid GET requests will return HTTP status code 200 (OK)
 - Valid POST requests will return HTTP status code 201 (Created)
 - Valid DELETE requests will return HTTP status code 204 (No Content)
 - Anything else is simply handled as a 500 this MVP