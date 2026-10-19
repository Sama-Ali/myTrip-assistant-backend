// ================================ MockAssistantService — the fake implementation ================================

struct MockAssistantService: AssistantService {
    func reply(
        to request: AssistantRequest
    ) async throws -> AssistantResponse {
        return AssistantResponse(
            reply: "هذا رد تجريبي لاختبار الربط، وليس إجابة من نموذج AI."
        )
    }
}