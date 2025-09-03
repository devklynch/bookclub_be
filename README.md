# README

## Table of Contents

- [API Documentation](#api-documentation)
  - [Users](#users)
    - [Create a user](#create-a-user)
    - [Create a session (Login)](#create-a-session-login)
    - [Get all user's book clubs](#get-all-users-book-clubs)
    - [Get all user's events](#get-all-users-events)
    - [Get all user's polls](#get-all-users-polls)
    - [Update user profile](#update-user-profile)
    - [Request password reset](#request-password-reset)
    - [Reset password](#reset-password)
  - [Home Page](#home-page)
    - [Shows a users clubs, events, and polls](#shows-a-users-clubs-events-and-polls)
  - [Book Clubs](#book-clubs)
    - [Get a bookclub](#get-a-bookclub)
    - [Create a book club](#create-a-book-club)
    - [Update a book club](#update-a-book-club)
  - [Events](#events)
    - [Get an event](#get-an-event)
    - [Create an event](#create-an-event)
    - [Get an event (Book Club context)](#get-an-event-book-club-context)
    - [Update an event](#update-an-event)
    - [Update event attendance (RSVP)](#update-event-attendance-rsvp)
  - [Polls](#polls)
    - [Get a poll](#get-a-poll)
    - [Create a poll](#create-a-poll)
    - [Update a poll](#update-a-poll)
  - [Votes](#votes)
    - [Create a vote](#create-a-vote)
    - [Delete a vote](#delete-a-vote)
  - [Invitations](#invitations)
    - [Create an invitation](#create-an-invitation)
    - [Get book club invitations](#get-book-club-invitations)
    - [Accept an invitation](#accept-an-invitation)
    - [Decline an invitation](#decline-an-invitation)

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
  "email": "user@bookclub.com",
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
    "errors": [
        {
            "message": "Invalid credentials"
        }
    ]
}

```

```

Status: 400 Bad Request

Body: {
    "errors": [
        {
            "message": "Email and password are required"
        }
    ]
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
    "errors": [
        {
            "message": "You are not authorized to perform this action"
        }
    ]
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

Error Response (user does not have access to poll):

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

#### Get all user's book clubs

Request:

```
GET /api/v1/users/:user_id/book_clubs

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}
```

Successful Response:

```
Status: 200 OK
{
    "data": [
        {
            "id": "1",
            "type": "book_club",
            "attributes": {
                "name": "Book Club 1",
                "description": "This is the description for Book Club 1"
            }
        },
        {
            "id": "2",
            "type": "book_club",
            "attributes": {
                "name": "Book Club 2",
                "description": "This is the description for Book Club 2"
            }
        }
    ]
}
```

#### Get all user's events

Request:

```
GET /api/v1/users/:user_id/events

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
        "upcoming_events": [
            {
                "id": "8",
                "type": "event",
                "attributes": {
                    "event_name": "Upcoming Event 1",
                    "event_date": "2025-09-19T00:00:00.000Z",
                    "location": "City 1",
                    "book": "Book 2",
                    "event_notes": "Event notes here",
                    "book_club_id": 4
                }
            }
        ],
        "past_events": [
            {
                "id": "5",
                "type": "event",
                "attributes": {
                    "event_name": "Past Event 1",
                    "event_date": "2024-01-15T00:00:00.000Z",
                    "location": "City 2",
                    "book": "Book 1",
                    "event_notes": "Past event notes",
                    "book_club_id": 4
                }
            }
        ]
    }
}
```

#### Get all user's polls

Request:

```
GET /api/v1/users/:user_id/polls

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
        "active_polls": [
            {
                "id": "3",
                "type": "poll",
                "attributes": {
                    "poll_question": "What book should we read next?",
                    "expiration_date": "2025-04-24T00:00:00.000Z",
                    "book_club_id": 2,
                    "book_club_name": "Essay Enthusiasts"
                }
            }
        ],
        "expired_polls": [
            {
                "id": "1",
                "type": "poll",
                "attributes": {
                    "poll_question": "What time should we meet?",
                    "expiration_date": "2024-12-01T00:00:00.000Z",
                    "book_club_id": 2,
                    "book_club_name": "Essay Enthusiasts"
                }
            }
        ]
    }
}
```

#### Update user profile

Request:

```
PATCH /api/v1/users/:user_id

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}

Body (Update display name and email):
{
  "user": {
    "email": "newemail@example.com",
    "display_name": "New Display Name"
  }
}

Body (Update password):
{
  "user": {
    "current_password": "currentPassword123",
    "password": "newPassword123",
    "password_confirmation": "newPassword123"
  }
}
```

Successful Response:

```
Status: 200 OK
{
    "message": "Profile updated successfully",
    "data": {
        "id": "1",
        "type": "user",
        "attributes": {
            "email": "newemail@example.com",
            "display_name": "New Display Name"
        }
    }
}
```

Error Response (Invalid current password):

```
Status: 422 Unprocessable Entity
{
    "error": "Current password is incorrect",
    "errors": {
        "current_password": ["is incorrect"]
    }
}
```

Error Response (Validation errors):

```
Status: 422 Unprocessable Entity
{
    "error": "Failed to update profile",
    "errors": {
        "email": ["has already been taken"],
        "display_name": ["can't be blank"]
    }
}
```

#### Request password reset

Request:

```
POST /api/v1/users/password

Body:
{
  "email": "user@bookclub.com"
}
```

Successful Response:

```
Status: 200 OK
{
    "message": "Password reset instructions sent to your email"
}
```

Note: For security, this endpoint returns the same message whether the email exists or not.

#### Reset password

Request:

```
PUT /api/v1/users/password

Body:
{
  "reset_password_token": "<token_from_email>",
  "password": "newPassword123",
  "password_confirmation": "newPassword123"
}
```

Successful Response:

```
Status: 200 OK
{
    "message": "Password reset successfully"
}
```

Error Response:

```
Status: 422 Unprocessable Entity
{
    "errors": [
        {
            "message": "Reset password token is invalid"
        }
    ]
}
```

### Book Clubs

#### Create a book club

Request:

```
POST /api/v1/book_clubs

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}

Body:
{
  "book_club": {
    "name": "New Book Club",
    "description": "Description of the new book club"
  }
}
```

Successful Response:

```
Status: 201 Created
{
    "data": {
        "id": "5",
        "type": "book_club",
        "attributes": {
            "name": "New Book Club",
            "description": "Description of the new book club",
            "members": [
                {
                    "id": 15,
                    "user_id": 1,
                    "email": "creator@example.com",
                    "display_name": "Creator Name"
                }
            ],
            "events": [],
            "polls": []
        }
    }
}
```

Error Response:

```
Status: 422 Unprocessable Entity
{
    "errors": [
        {
            "message": "Name can't be blank"
        }
    ]
}
```

#### Update a book club

Request:

```
PATCH /api/v1/book_clubs/:book_club_id

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}

Body:
{
  "book_club": {
    "name": "Updated Book Club Name",
    "description": "Updated description"
  }
}
```

Successful Response:

```
Status: 200 OK
{
    "data": {
        "id": "5",
        "type": "book_club",
        "attributes": {
            "name": "Updated Book Club Name",
            "description": "Updated description",
            "members": [...],
            "events": [...],
            "polls": [...]
        }
    }
}
```

Error Response (Not admin):

```
Status: 403 Forbidden
{
    "errors": [
        {
            "message": "Only admins can edit book clubs"
        }
    ]
}
```

### Events

#### Create an event

Request:

```
POST /api/v1/book_clubs/:book_club_id/events

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}

Body:
{
  "event": {
    "event_name": "Monthly Book Discussion",
    "event_date": "2025-05-15T19:00:00.000Z",
    "location": "Central Library",
    "book": "The Great Gatsby",
    "event_notes": "Don't forget to bring your copy!"
  }
}
```

Successful Response:

```
Status: 200 OK
{
    "data": {
        "id": "15",
        "type": "event",
        "attributes": {
            "event_name": "Monthly Book Discussion",
            "event_date": "2025-05-15T19:00:00.000Z",
            "location": "Central Library",
            "book": "The Great Gatsby",
            "event_notes": "Don't forget to bring your copy!",
            "book_club_id": 5
        }
    }
}
```

Error Response (Not admin):

```
Status: 403 Forbidden
{
    "errors": [
        {
            "message": "Only admins can create events for this book club"
        }
    ]
}
```

#### Get an event (Book Club context)

Request:

```
GET /api/v1/book_clubs/:book_club_id/events/:event_id

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
        "id": "15",
        "type": "event",
        "attributes": {
            "event_name": "Monthly Book Discussion",
            "event_date": "2025-05-15T19:00:00.000Z",
            "location": "Central Library",
            "book": "The Great Gatsby",
            "event_notes": "Don't forget to bring your copy!",
            "book_club_id": 5
        }
    }
}
```

Error Response (Not authorized):

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

Error Response (Wrong book club):

```
Status: 404 Not Found
{
    "errors": [
        {
            "message": "Event does not belong to the specified book club"
        }
    ]
}
```

#### Update an event

Request:

```
PATCH /api/v1/book_clubs/:book_club_id/events/:event_id

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}

Body:
{
  "event": {
    "event_name": "Updated Event Name",
    "location": "New Location",
    "event_notes": "Updated notes"
  }
}
```

Successful Response:

```
Status: 200 OK
{
    "data": {
        "id": "15",
        "type": "event",
        "attributes": {
            "event_name": "Updated Event Name",
            "event_date": "2025-05-15T19:00:00.000Z",
            "location": "New Location",
            "book": "The Great Gatsby",
            "event_notes": "Updated notes",
            "book_club_id": 5
        }
    }
}
```

Error Response (Not admin):

```
Status: 403 Forbidden
{
    "errors": [
        {
            "message": "Only admins can update events for this book club"
        }
    ]
}
```

#### Update event attendance (RSVP)

Request:

```
PATCH /api/v1/book_clubs/:book_club_id/events/:event_id/attendees/:attendee_id

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}

Body:
{
  "attendee": {
    "attending": true
  }
}
```

Successful Response:

```
Status: 200 OK
{
    "message": "RSVP updated",
    "attending": true
}
```

Error Response:

```
Status: 422 Unprocessable Entity
{
    "errors": [
        {
            "message": "Validation error message"
        }
    ]
}
```

### Polls

#### Create a poll

Request:

```
POST /api/v1/book_clubs/:book_club_id/polls

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}

Body:
{
  "poll": {
    "poll_question": "What book should we read next?",
    "expiration_date": "2025-06-01T00:00:00.000Z",
    "multiple_votes": false,
    "options_attributes": [
      {
        "option_text": "The Catcher in the Rye"
      },
      {
        "option_text": "To Kill a Mockingbird"
      },
      {
        "option_text": "1984"
      }
    ]
  }
}
```

Successful Response:

```
Status: 201 Created
{
    "data": {
        "id": "8",
        "type": "poll",
        "attributes": {
            "poll_question": "What book should we read next?",
            "expiration_date": "2025-06-01T00:00:00.000Z",
            "book_club_id": 5,
            "book_club_name": "New Book Club",
            "options": [
                {
                    "id": 15,
                    "option_text": "The Catcher in the Rye",
                    "additional_info": null,
                    "votes_count": 0
                },
                {
                    "id": 16,
                    "option_text": "To Kill a Mockingbird",
                    "additional_info": null,
                    "votes_count": 0
                },
                {
                    "id": 17,
                    "option_text": "1984",
                    "additional_info": null,
                    "votes_count": 0
                }
            ]
        }
    }
}
```

Error Response (Not admin):

```
Status: 403 Forbidden
{
    "errors": [
        {
            "message": "Only admins can create polls for this book club"
        }
    ]
}
```

#### Update a poll

Request:

```
PATCH /api/v1/book_clubs/:book_club_id/polls/:poll_id

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}

Body:
{
  "poll": {
    "poll_question": "Updated poll question?",
    "expiration_date": "2025-07-01T00:00:00.000Z",
    "options": {
      "to_add": [
        {
          "option_text": "New Option",
          "additional_info": "Extra info about this option"
        }
      ],
      "to_update": [
        {
          "id": 15,
          "option_text": "Updated Option Text"
        }
      ],
      "to_delete": [16, 17]
    }
  }
}
```

Successful Response:

```
Status: 200 OK
{
    "data": {
        "id": "8",
        "type": "poll",
        "attributes": {
            "poll_question": "Updated poll question?",
            "expiration_date": "2025-07-01T00:00:00.000Z",
            "book_club_id": 5,
            "book_club_name": "New Book Club",
            "options": [
                {
                    "id": 15,
                    "option_text": "Updated Option Text",
                    "additional_info": null,
                    "votes_count": 0
                },
                {
                    "id": 18,
                    "option_text": "New Option",
                    "additional_info": "Extra info about this option",
                    "votes_count": 0
                }
            ]
        }
    }
}
```

Error Response (Not admin):

```
Status: 403 Forbidden
{
    "errors": [
        {
            "message": "Only admins can update polls for this book club"
        }
    ]
}
```

### Votes

#### Create a vote

Request:

```
POST /api/v1/users/:user_id/polls/:poll_id/options/:option_id/votes

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}
```

Successful Response:

```
Status: 201 Created
{
    "id": 25,
    "user_id": 1,
    "option_id": 15,
    "created_at": "2025-01-15T10:30:00.000Z",
    "updated_at": "2025-01-15T10:30:00.000Z"
}
```

Error Response (Poll expired):

```
Status: 422 Unprocessable Entity
{
    "errors": [
        {
            "message": "This poll has expired and is no longer accepting votes."
        }
    ]
}
```

Error Response (Already voted on single-vote poll):

```
Status: 422 Unprocessable Entity
{
    "errors": [
        {
            "message": "You can only vote once in this poll."
        }
    ]
}
```

#### Delete a vote

Request:

```
DELETE /api/v1/users/:user_id/polls/:poll_id/options/:option_id/votes/:vote_id

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}
```

Successful Response:

```
Status: 200 OK
{
    "message": "Vote removed"
}
```

Error Response (Poll expired):

```
Status: 422 Unprocessable Entity
{
    "errors": [
        {
            "message": "Cannot remove votes from an expired poll."
        }
    ]
}
```

Error Response (Vote not found):

```
Status: 404 Not Found
{
    "errors": [
        {
            "message": "Vote not found or not authorized"
        }
    ]
}
```

### Invitations

#### Create an invitation

Request:

```
POST /api/v1/book_clubs/:book_club_id/invitations

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}

Body:
{
  "invitation": {
    "email": "newmember@example.com"
  }
}
```

Successful Response:

```
Status: 201 Created
{
    "message": "Invitation sent to newmember@example.com",
    "invitation": {
        "data": {
            "id": "10",
            "type": "invitation",
            "attributes": {
                "email": "newmember@example.com",
                "status": "pending",
                "token": "abc123def456",
                "created_at": "2025-01-15T10:30:00.000Z",
                "book_club_name": "Book Club Name",
                "invited_by_name": "Admin Name"
            }
        }
    }
}
```

Error Response (Not admin):

```
Status: 403 Forbidden
{
    "errors": [
        {
            "message": "Only book club admins can manage invitations"
        }
    ]
}
```

Error Response (Validation error):

```
Status: 422 Unprocessable Entity
{
    "errors": [
        {
            "message": "Email can't be blank"
        }
    ]
}
```

#### Get book club invitations

Request:

```
GET /api/v1/book_clubs/:book_club_id/invitations

Headers:
{
  "Authorization": "Bearer <your_token_here>"
}
```

Successful Response:

```
Status: 200 OK
{
    "data": [
        {
            "id": "10",
            "type": "invitation",
            "attributes": {
                "email": "newmember@example.com",
                "status": "pending",
                "token": "abc123def456",
                "created_at": "2025-01-15T10:30:00.000Z",
                "book_club_name": "Book Club Name",
                "invited_by_name": "Admin Name"
            }
        }
    ]
}
```

#### Accept an invitation

Request:

```
GET /api/v1/invitations/:token/accept
```

Note: This is a public endpoint that redirects to the frontend. If the user is authenticated, it processes the invitation acceptance. If not authenticated, it redirects to the frontend with the invitation token for account creation.

Response: Redirects to frontend URL with appropriate parameters.

#### Decline an invitation

Request:

```
GET /api/v1/invitations/:token/decline
```

Note: This is a public endpoint that processes the invitation decline and redirects to the frontend.

Response: Redirects to frontend URL with decline confirmation.
