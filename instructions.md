# Coin Ninja - Take Home Assignment

This project is intended as a practice exercise to provide us some insight into how well you can Go. Don't worry about showing off all of your abilities, and look to only spend an hour or two for the entirety of this project.

## Problem

We would like to create a simple messaging service. This service should resemble email with a single from address and one-to-many to addresses, as well as a message subject & body.

## Requirements

Implement a struct for a message. This struct should also be able be serialized into JSON using [snake case](https://en.wikipedia.org/wiki/Snake_case) keys.

Using the `database/sql` package (database of your choosing), create a set of functions to:

- Store a message
- Fetch all stored messages
- Retrieve a single message
- Delete a single message

Include tests where appropriate. When testing use the [testify](https://github.com/stretchr/testify) package.

Create a README if appropriate.