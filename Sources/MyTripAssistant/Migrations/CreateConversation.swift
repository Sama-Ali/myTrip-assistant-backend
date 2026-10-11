import Fluent

struct CreateConversation: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("conversations")
            .field("user_id", .uuid, .identifier(auto: false))
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("conversations").delete()
    }
}