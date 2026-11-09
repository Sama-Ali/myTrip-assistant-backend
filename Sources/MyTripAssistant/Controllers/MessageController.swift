// ================================ Save user message → Load history → Call AI → Save assistant reply ================================

import Fluent
import Vapor
import Foundation

// ================================ User’s text ================================
struct CreateMessageRequest: Content {
    let content: String
}

struct MessageResponse: Content {
    let id: UUID
    let conversationID: UUID
    let sender: MessageSender
    let content: String
    let sequenceNumber: Int
    let createdAt: Date?

    init(message: Message) throws {
        self.id = try message.requireID()
        self.conversationID = message.$conversation.id
        self.sender = message.sender
        self.content = message.content
        self.sequenceNumber = message.sequenceNumber
        self.createdAt = message.createdAt
    }
}

// ================================ Backend → App ================================
struct ChatResponse: Content {
    let userMessage: MessageResponse       // Saved user's message
    let assistantMessage: MessageResponse  // Saved assistant's reply
}

struct MessageController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
    routes.post("conversation", "messages", use: createMessage)
    routes.get("conversation", "messages", use: listMessages)
}

    private func saveMessage(
        userID: UUID,
        sender: MessageSender,
        content: String,
        req: Request

        ) async throws -> Message {

        try await req.db.transaction { database in
            guard let conversation = try await Conversation.find(
                userID,
             on: database
         ) else {
                throw Abort(.notFound, reason: "Conversation not found")
            }

            // Update conversation updatedAt timestamp
            try await Conversation.query(on: database)
                .filter(\.$id == userID)
                .set(\.$updatedAt, to: Date())
                .update()

            let lastSequence = try await Message.query(on: database)
                // 1- Sort by sequence number, largest first.
                .filter(\.$conversation.$id == userID)
                // 2- Take the first message’s number.
                .sort(\.$sequenceNumber, .descending)
                // 3- If no message exists, use 0.
                .first()?.sequenceNumber ?? 0

            // Create new message with the next sequence number
            let message = Message(
                conversationID: try conversation.requireID(),
                sender: sender,
                content: content,
                sequenceNumber: lastSequence + 1
            )

            try await message.save(on: database)
            return message
        }
    }

    func createMessage(req: Request) async throws -> ChatResponse {
        let userID = try req.auth.require(AuthenticatedUser.self).id
        let payload = try req.content.decode(CreateMessageRequest.self)

        let content = payload.content.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !content.isEmpty else {
            throw Abort(.badRequest, reason: "Content cannot be empty")
        }

        // 1. Save the user's message.
        let userMessage = try await saveMessage(
          userID: userID,
          sender: .user,
          content: content,
          req: req
        )

        // 2. Fetch the latest 20 messages up to this message.
        let history = try await Message.query(on: req.db)
            .filter(\.$conversation.$id == userID)
            .filter(\.$sequenceNumber <= userMessage.sequenceNumber)
            .sort(\.$sequenceNumber, .descending)
            .limit(20)
            .all()

     // Restore chronological order.
        let context = history.reversed().map {
            AssistantMessage(
                role: $0.sender,
                content: $0.content
            )
     }

        // build the assistant request (context messages)
        let assistantRequest = AssistantRequest(
            requestID: try userMessage.requireID(),
        messages: context
        )

        // 3. Call the AI service without holding a database transaction.
        let response = try await req.application.assistantService.reply(
           to: assistantRequest
        )

        // 4. Save the assistant's reply.
        let assistantMessage = try await saveMessage(
            userID: userID,
            sender: .assistant,
            content: response.reply,
            req: req
        )

        return try ChatResponse(
           userMessage: MessageResponse(message: userMessage),
        assistantMessage: MessageResponse(message: assistantMessage)
        )
}

    func listMessages(req: Request) async throws -> Page<MessageResponse> {
       let userID = try req.auth.require(AuthenticatedUser.self).id

        guard let conversation = try await Conversation.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "Conversation not found")
        }

        let page = try await conversation.$messages.query(on: req.db)
            .sort(\.$sequenceNumber, .ascending)
            .paginate(for: req)

        return try page.map { try MessageResponse(message: $0) }
    }
}