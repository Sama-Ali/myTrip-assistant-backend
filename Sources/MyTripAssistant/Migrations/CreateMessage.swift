import Fluent

struct CreateMessage: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("messages")
            .id()
            .field(
                "conversation_id",
                .uuid,
                .required,
                .references("conversations", "user_id", onDelete: .cascade)
            )
            .field("sender", .string, .required)
            .field("content", .string, .required)
            .field("sequence_number", .int, .required)
            .field("created_at", .datetime, .required)
            .unique(on: "conversation_id", "sequence_number")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("messages").delete()
    }
}