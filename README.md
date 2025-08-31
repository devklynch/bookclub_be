# README

## Table of Contents

- [API Documentation](#api-documentation)
  - [Events](#events)
    - [Get an event](#get-an-event)
      This README would normally document whatever steps are necessary to get the
      application up and running.

Things you may want to cover:

- Ruby version stuff

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- ...

## API Documentation

### Users

#### Create a user

Request:

```
POST /api/v1/users

Body:
{
  "user": {
    "email": "newuser123@example.com",
    "display_name": "New User",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```

Successful Response:

```
Status: 201 Created
{
    "data": {
        "id": "28",
        "type": "user",
        "attributes": {
            "email": "newuser123@example.com",
            "display_name": "New User"
        }
    }
}
```

#### Create a session (Login)

Request:

```
POST /api/v1/users/sign_in

Body:
{
  "email": "user@bookclub.com,
  "password": "passwordTest123"
}

```

Successful Response:

```

Status: 200 OK

Body: {
    "token": <token>,
    "user": {
        "data": {
            "id": "1",
            "type": "user",
            "attributes": {
                "email": "user@bookclub.com",
                "display_name": "John Smith"
            }
        }
    }
}

```

Error Response:

```

Status: 401 Unauthorized

Body: {
  "error": "Invalid credentials"
}

```

```

Status: 400 Bad Request

Body: {
  "error": "Email and password are required"
}

```

### Home Page

#### Shows a users clubs, events, and polls

Request:

```
GET /api/v1/users/:user_id/all_club_data

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}
```

Successful Response:

```
Status: 200 OK
{
    "data": {
        "id": "11",
        "type": "all_club_data",
        "attributes": {
            "id": 11,
            "display_name": "User 1",
            "book_clubs": [
                {
                    "id": 4,
                    "name": "Book Club 1",
                    "description": "This is the description for Book Club 1"
                },
                {
                    "id": 5,
                    "name": "Book Club 2",
                    "description": "This is the description for Book Club 2"
                }
            ],
            "upcoming_events": [
                {
                    "id": 8,
                    "event_name": "Upcoming Event 1 - Club 1",
                    "event_date": "2025-09-19T00:00:00.000Z",
                    "location": "City 1",
                    "book": "Book 2 for Club 1",
                    "book_club": {
                        "id": 4,
                        "name": "Book Club 1"
                    }
                },
                {
                    "id": 11,
                    "event_name": "Upcoming Event 1 - Club 2",
                    "event_date": "2025-09-19T00:00:00.000Z",
                    "location": "City 2",
                    "book": "Book 2 for Club 2",
                    "book_club": {
                        "id": 5,
                        "name": "Book Club 2"
                    }
                },
                {
                    "id": 9,
                    "event_name": "Upcoming Event 2 - Club 1",
                    "event_date": "2025-10-09T00:00:00.000Z",
                    "location": "City 1",
                    "book": "Book 3 for Club 1",
                    "book_club": {
                        "id": 4,
                        "name": "Book Club 1"
                    }
                },
                {
                    "id": 12,
                    "event_name": "Upcoming Event 2 - Club 2",
                    "event_date": "2025-10-09T00:00:00.000Z",
                    "location": "City 2",
                    "book": "Book 3 for Club 2",
                    "book_club": {
                        "id": 5,
                        "name": "Book Club 2"
                    }
                }
            ],
            "active_polls": [
                {
                    "id": 8,
                    "question": "Current Poll 1 - Club 1",
                    "expiration_date": "2025-09-19T00:00:00.000Z",
                    "book_club": {
                        "id": 4,
                        "name": "Book Club 1"
                    }
                },
                {
                    "id": 11,
                    "question": "Current Poll 1 - Club 2",
                    "expiration_date": "2025-09-19T00:00:00.000Z",
                    "book_club": {
                        "id": 5,
                        "name": "Book Club 2"
                    }
                },
                {
                    "id": 9,
                    "question": "Current Poll 2 - Club 1",
                    "expiration_date": "2025-10-09T00:00:00.000Z",
                    "book_club": {
                        "id": 4,
                        "name": "Book Club 1"
                    }
                },
                {
                    "id": 12,
                    "question": "Current Poll 2 - Club 2",
                    "expiration_date": "2025-10-09T00:00:00.000Z",
                    "book_club": {
                        "id": 5,
                        "name": "Book Club 2"
                    }
                }
            ]
        }
    }
}
```

Error Response (user does not have access to event):

```
Status: 403 Forbidden
{
    "error": "You are not authorized to perform this action"
}
```

### Book Clubs

#### Get a bookclub

Request:

```
GET /api/v1/users/:user_id/book_clubs/book_club_id

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}
```

Successful Response:

```
Status: 200 OK
{
    "data": {
        "id": "2",
        "type": "book_club",
        "attributes": {
            "name": "Essay Enthusiasts",
            "description": "Et et est natus.",
            "members": [
                {
                    "id": 6,
                    "user_id": 5,
                    "email": "alvin@rath-mayer.test",
                    "display_name": "Msgr. Alfred Lesch"
                },
                {
                    "id": 7,
                    "user_id": 7,
                    "email": "noah@durgan.test",
                    "display_name": "Nickolas Osinski"
                },
                {
                    "id": 8,
                    "user_id": 3,
                    "email": "roman_funk@fadel.example",
                    "display_name": "May Armstrong"
                },
                {
                    "id": 9,
                    "user_id": 2,
                    "email": "nigel.breitenberg@lebsack.test",
                    "display_name": "Eddie Hahn"
                },
                {
                    "id": 10,
                    "user_id": 1,
                    "email": "kamilah.schamberger@lueilwitz.test",
                    "display_name": "Trent Roberts"
                }
            ],
            "events": [
                {
                    "id": 3,
                    "event_name": "Discussion on The Mirror Crack'd from Side to Side",
                    "event_date": "2025-04-15T00:00:00.000Z",
                    "location": "Schroederside",
                    "book": "If I Forget Thee Jerusalem",
                    "event_notes": "Voluptatem et et molestiae."
                },
                {
                    "id": 4,
                    "event_name": "Discussion on Ah, Wilderness!",
                    "event_date": "2025-04-25T00:00:00.000Z",
                    "location": "Port Reyes",
                    "book": "Beneath the Bleeding",
                    "event_notes": "Dolore recusandae quia nobis."
                }
            ],
            "polls": [
                {
                    "id": 3,
                    "poll_question": "What book should we read next?",
                    "expiration_date": "2025-04-24T00:00:00.000Z",
                    "book_club_id": 2
                },
                {
                    "id": 4,
                    "poll_question": "What book should we read next?",
                    "expiration_date": "2025-04-19T00:00:00.000Z",
                    "book_club_id": 2
                }
            ]
        }
    }
}
```

Error Response (user does not have access to event):

```
Status: 403 Forbidden
{
    "errors": [
        {
            "message": "You are not authorized to view this book club"
        }
    ]
}
```

### Events

#### Get an event

Request:

```
GET /api/v1/users/:user_id/events/event_id

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}
```

Successful Response:

```
Status: 200 OK
{
    "data": {
        "id": "11",
        "type": "event",
        "attributes": {
            "event_name": "Discussion on The Glory and the Dream",
            "event_date": "2025-03-31T00:00:00.000Z",
            "location": "New Doylebury",
            "book": "A Passage to India",
            "event_notes": "Maiores quis ut ex.",
            "book_club_id": 6
        }
    }
}
```

Error Response (user does not have access to event):

```
Status: 403 Forbidden
{
    "errors": [
        {
            "message": "You are not authorized to view this event"
        }
    ]
}
```

### Polls

#### Get a poll

Request:

```
GET /api/v1/users/:user_id/polls/poll_id

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}
```

Successful Response:

```
Status: 200 OK
{
    "data": {
        "id": "3",
        "type": "poll",
        "attributes": {
            "poll_question": "What book should we read next?",
            "expiration_date": "2025-04-24T00:00:00.000Z",
            "book_club_id": 2,
            "book_club_name": "Essay Enthusiasts",
            "options": [
                {
                    "id": 7,
                    "option_text": "For a Breath I Tarry",
                    "additional_info": null,
                    "votes_count": 3
                },
                {
                    "id": 8,
                    "option_text": "The Cricket on the Hearth",
                    "additional_info": null,
                    "votes_count": 3
                },
                {
                    "id": 9,
                    "option_text": "Time To Murder And Create",
                    "additional_info": null,
                    "votes_count": 3
                }
            ]
        }
    }
}
```

Error Response (user does not have access to event):

```
Status: 403 Forbidden
{
    "errors": [
        {
            "message": "You are not authorized to view this poll"
        }
    ]
}
```
