import Fluent
import Vapor

func routes(_ app: Application) throws {

    let protected = app
        .grouped(DevelopmentAuthenticator())
        .grouped(AuthenticatedUser.guardMiddleware())

    try protected.register(collection: ConversationController())
    try protected.register(collection: MessageController())
        app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
}
