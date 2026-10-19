# MyTrip AI Assistant Backend

## Overview

This project implements the backend for the MyTrip AI assistant.

The backend is responsible for:

- **Conversation and message storage:** Create and maintain the tables needed to save, order, and retrieve messages using pagination.
- **User identity and permissions:** Use test identities during development, then integrate with MyTrip’s authentication system and user records. Ensure users can access only their own conversations and bookings.
- **Chat and AI service integration:** Receive and save user messages, send them to the AI service with conversation context, then save and return its replies. Real integration begins when the AI service is ready and its interface is agreed upon.
- **Data-access tools:** Provide endpoints for booking details and flight status using fake data initially, then connect them to actual sources when available. This work may be deferred until the AI service is ready.
- **Testing and performance monitoring:** Test implemented functionality, including conversations and access permissions, and monitor response times and technical errors.
- **Documentation and delivery:** Prepare a Postman collection, API documentation, a database diagram, and migration files.

The AI team is responsible for model behavior, knowledge retrieval, and answer generation. The final integration contract and tool-execution responsibilities still need confirmation.

## Technology Stack

- Swift
- Vapor
- Fluent ORM
- PostgreSQL
- Postman for API testing
- pgAdmin for database inspection

Use the project's `Package.swift` and `Package.resolved` as the references for dependency versions.

## Conversation Storage

Each user has conversation.

### conversations

| Column       | Type              | Purpose                                   |
| ------------ | ----------------- | ----------------------------------------- |
| `user_id`    | UUID, primary key | Identifies the conversation and its owner |
| `created_at` | Timestamp         | Creation time                             |
| `updated_at` | Timestamp         | Last conversation update                  |

The Fluent model's `id` property maps to the database column `user_id`.

```swift
@ID(custom: "user_id", generatedBy: .user)
var id: UUID?
```

`generatedBy: .user` means application code supplies the ID. It does not require a local `users` table.

UUID is the current user identifier type. Compatibility with MyTrip's actual user identifiers must be confirmed during integration.

### messages

| Column            | Type              | Purpose                               |
| ----------------- | ----------------- | ------------------------------------- |
| `id`              | UUID, primary key | Identifies the message                |
| `conversation_id` | UUID, foreign key | References `conversations.user_id`    |
| `sender`          | String            | `user` or `assistant`                 |
| `content`         | Text              | Message content                       |
| `sequence_number` | Integer           | Message order within the conversation |
| `created_at`      | Timestamp         | Creation time                         |

Constraints:

- `(conversation_id, sequence_number)` is unique.
- Deleting a conversation cascades to its messages.
- `MessageSender` restricts sender values in Swift; the database column is text.

No conversation-deletion endpoint is currently documented.

### Message Ordering

Messages are retrieved by ascending `sequence_number`.

When creating a message, the current implementation:

1. Opens a database transaction.
2. Updates the conversation row, acquiring a PostgreSQL row lock.
3. Reads the latest sequence number for that conversation.
4. Saves the new message with the next number.
5. Commits the transaction.

## Authentication and Permissions

### Development Authentication

Local development uses two static Bearer tokens configured in `.env`.

Each token maps to a different user UUID.

Requests send:

```http
Authorization: Bearer <token>
```

`DevelopmentAuthenticator` checks the token and places an `AuthenticatedUser` in the request's authentication storage.

Protected routes use a guard to reject requests without a verified identity.

Controllers obtain the user ID through:

```swift
let userID = try req.auth.require(AuthenticatedUser.self).id
```

Clients do not select a user ID through the URL or request body.

### Permission Rules

- Users can retrieve only their own conversation.
- Users can list and create messages only in their own conversation.
- The backend assigns `sender = user` to incoming client messages.
- Missing or invalid credentials result in `401 Unauthorized`.

Local user-isolation tests have been reported as passing in Postman.

### Production Integration

Development tokens are not production authentication.

The development authenticator is restricted to the development environment. It must be replaced by verification of MyTrip's actual credentials before deployment.

The replacement should continue producing `AuthenticatedUser`, allowing controller permission logic to remain unchanged.

## Current API Endpoints

All endpoints below require Bearer authentication.

## AI Service Integration

### Internal Contract

The AI connection is represented by an `AssistantService` protocol:

```swift
protocol AssistantService: Sendable {
    func reply(
        to request: AssistantRequest
    ) async throws -> AssistantResponse
}
```

This contract keeps AI communication separate from controllers and database operations.

### AssistantRequest

Contains:

- `requestID`: identifies the AI request.
- `messages`: ordered conversation context.

Each context message contains:

- `role`: `user` or `assistant`, using `MessageSender`.
- `content`: message text.

The latest user message should appear exactly once.

`requestID` alone does not prevent duplicate processing. Retry protection requires additional implementation.

### AssistantResponse

Contains:

- `reply`: the generated response text.

These are provisional internal types, not a confirmed specification for the AI team's API.

### MockAssistantService

The mock implements the protocol and returns a clearly labeled, fixed test response.

It does not:

- Call a real model.
- Retrieve knowledge.
- Access booking or flight data.

It is used to test backend integration independently of AI availability.

### Application Registration

The planned application configuration selects a service implementation:

```swift
app.assistantService = MockAssistantService()
```

Controllers call the configured service:

```swift
let response = try await req.application.assistantService.reply(
    to: assistantRequest
)
```

When the real AI service is ready, a new implementation will translate between the internal types and its actual API.

### Planned Chat Flow

1. Authenticate the user.
2. Validate and save the user message.
3. Load a bounded amount of recent conversation history.
4. Arrange the history in sequence order.
5. Call the configured AI service.
6. Save the returned reply with `sender = assistant`.
7. Return the result to the client.

The AI call must happen outside database transactions.

If the AI call fails, retain the user message and return an appropriate error. Do not store an error as if it were a genuine AI answer.

Before enabling this flow, define:

- Response timeout.
- Retry and duplicate-request behavior.
- Handling of simultaneous requests in one conversation.
- Context size limits.
- Response format returned to the frontend.

## Testing

### Reported Local Verification

- Vapor builds and runs.
- PostgreSQL migrations apply successfully.
- Conversation and message operations work through Postman.
- Messages can be inspected in pgAdmin.
- Development-token authentication and user-isolation URL tests pass.
