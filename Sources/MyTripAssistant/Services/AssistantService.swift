// ================================ AssistantService —— the contract: ================================
// ================================ A protocol defines the operation the service must provide "each service must implement this protocol, reply() method" ================================

import Foundation
import Vapor

struct AssistantMessage: Codable, Sendable {
    let role: MessageSender
    let content: String
}

struct AssistantRequest: Codable, Sendable {
    let requestID: UUID
    let messages: [AssistantMessage]
}

struct AssistantResponse: Content, Sendable {
    let reply: String
}

protocol AssistantService: Sendable {
    func reply(
        to request: AssistantRequest
    ) async throws -> AssistantResponse
}