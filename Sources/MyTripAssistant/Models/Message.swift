import Fluent
import Foundation

enum MessageSender: String, Codable, Sendable {
    case user
    case assistant
}

final class Message: Model, @unchecked Sendable {
    static let schema = "messages"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "conversation_id")
    var conversation: Conversation

    @Field(key: "sender")
    var sender: MessageSender

    @Field(key: "content")
    var content: String

    @Field(key: "sequence_number")
    var sequenceNumber: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        conversationID: UUID,
        sender: MessageSender,
        content: String,
        sequenceNumber: Int
    ) {
        self.$conversation.id = conversationID
        self.sender = sender
        self.content = content
        self.sequenceNumber = sequenceNumber
    }
}