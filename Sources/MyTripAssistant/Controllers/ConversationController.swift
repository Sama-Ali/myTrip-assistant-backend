import Fluent
import Vapor
import Foundation

struct CreateConversationRequest: Content {
    let userID: UUID
}

struct ConversationResponse: Content {
    let userID: UUID
    let createdAt: Date?
    let updatedAt: Date?
}

struct ConversationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.post("conversation", use: getOrCreate)
        routes.get("conversation", ":userID", use: getConversation)
    }

    func getOrCreate(req: Request) async throws -> ConversationResponse {
        let payload = try req.content.decode(CreateConversationRequest.self)
        let userID = payload.userID

        let conversation: Conversation

        if let existing = try await Conversation.find(userID, on: req.db) {
            conversation = existing
        } else {
            let newConversation = Conversation(userID: userID)
            try await newConversation.save(on: req.db)
            conversation = newConversation
        }

        return try Self.response(from: conversation)
    }

    func getConversation(req: Request) async throws -> ConversationResponse {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }

        guard let conversation = try await Conversation.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "Conversation not found")
        }

        return try Self.response(from: conversation)
    }

    private static func response(from conversation: Conversation) throws -> ConversationResponse {
        ConversationResponse(
            userID: try conversation.requireID(),
            createdAt: conversation.createdAt,
            updatedAt: conversation.updatedAt
        )
    }
}
