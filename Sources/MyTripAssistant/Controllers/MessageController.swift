import Fluent
import Vapor
import Foundation

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

struct CreateMessageRequest: Content {
    let content: String
}

struct MessageController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
    routes.post("conversation", "messages", use: createMessage)
    routes.get("conversation", "messages", use: listMessages)
}

    func createMessage(req: Request) async throws -> MessageResponse {
        let userID = try req.auth.require(AuthenticatedUser.self).id

        let payload = try req.content.decode(CreateMessageRequest.self)

        let content = payload.content.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !content.isEmpty else {
            throw Abort(.badRequest, reason: "Content cannot be empty")
        }

        let message = try await req.db.transaction { database in
            guard let conversation = try await Conversation.find(userID, on: database) else {
                throw Abort(.notFound, reason: "Conversation not found")
            }

            try await Conversation.query(on: database)
                .filter(\.$id == userID)
                .set(\.$updatedAt, to: Date())
                .update()

            let lastSequence = try await Message.query(on: database)
                .filter(\.$conversation.$id == userID)
                .sort(\.$sequenceNumber, .descending)
                .first()?.sequenceNumber ?? 0

            let message = Message(
                conversationID: try conversation.requireID(),
                sender: .user,
                content: content,
                sequenceNumber: lastSequence + 1
            )
            try await message.save(on: database)
            return message
        }

        return try MessageResponse(message: message)
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