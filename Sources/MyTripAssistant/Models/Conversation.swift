import Fluent
import Foundation

final class Conversation: Model, @unchecked Sendable {
    static let schema = "conversations"

    @ID(custom: "user_id", generatedBy: .user)
    var id: UUID?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$conversation)
    var messages: [Message]

    init() {}

    init(userID: UUID) {
        self.id = userID
    }
}