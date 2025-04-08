# README

## Table of Contents

- [API Documentation](#api-documentation)
  - [Events](#events)
    - [Get an event](#get-an-event)
      This README would normally document whatever steps are necessary to get the
      application up and running.

Things you may want to cover:

- Ruby version

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

#### Create a User

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
