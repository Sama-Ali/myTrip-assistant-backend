// =============================== FlightResponseValidationError: describes the validation error for the flight response ===============================
struct FlightResponseValidationError: Error {
    // =============================== message: check the from the source, is valid? ===============================
    let message: String
    // =============================== missing: the fields that are missing ===============================
    let missing: [String]

    init(
        message: String,
        missing: [String] = []
    ) {
        self.message = message
        self.missing = missing
    }

    var body: ToolErrorBody {
        ToolErrorBody(
            code: .badSourceData,
            message: message,
            retryable: true,
            missing: missing.isEmpty ? nil : missing
        )
    }
}