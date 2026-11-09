import Fluent
import Vapor

func routes(_ app: Application) throws {

    let protected = app
        .grouped(DevelopmentAuthenticator())
        .grouped(AuthenticatedUser.guardMiddleware())

    try protected.register(collection: ConversationController())
    try protected.register(collection: MessageController())
    try protected.register(collection: FlightStatusController())
        app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // ================================ MockAssistantService — temporary route ================================
    protected.post("assistant", "test") { req async throws -> AssistantResponse in
    let input = try req.content.decode(CreateMessageRequest.self)

    let content = input.content.trimmingCharacters(
        in: .whitespacesAndNewlines
    )

    guard !content.isEmpty else {
        throw Abort(.badRequest, reason: "Content cannot be empty")
    }

    let request = AssistantRequest(
        requestID: UUID(),
        messages: [
            AssistantMessage(role: .user, content: content)
        ]
    )

    return try await req.application.assistantService.reply(to: request)
}


}
