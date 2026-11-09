// ================================ MockAssistantService — the fake implementation ================================

import Vapor

struct MockAssistantService: AssistantService {
    func reply(
        to request: AssistantRequest
    ) async throws -> AssistantResponse {
        // مصدر الرد مؤقتًا.
        // لاحقًا نستبدله باستدعاء خدمة الـAI.
        let response = AssistantResponse(
            reply: "هذا رد تجريبي لاختبار الربط، وليس إجابة من نموذج AI."
        )

        // التحقق من الرد قبل إعادته للـController.
        let reply = response.reply.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !reply.isEmpty else {
            throw Abort(
                .badGateway,
                reason: "AI service returned an empty reply"
            )
        }

        return AssistantResponse(reply: reply)
    }
}