/// A utility for validating replies.
abstract class VReplyValidator {
  /// Validates the reply text.
  ///
  /// Returns `true` if the reply is valid, otherwise `false`.
  static bool validate(String reply) {
    return reply.trim().isNotEmpty;
  }
}
