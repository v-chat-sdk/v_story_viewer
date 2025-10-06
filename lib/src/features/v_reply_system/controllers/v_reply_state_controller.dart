import 'package:flutter/foundation.dart';

/// The state of the reply UI.
enum VReplyState { idle, sending, success, error }

/// A controller for managing the state of the reply UI.
class VReplyStateController extends ValueNotifier<VReplyState> {
  /// Creates a new instance of [VReplyStateController].
  VReplyStateController() : super(VReplyState.idle);

  /// Sets the state to sending.
  void setSending() => value = VReplyState.sending;

  /// Sets the state to success.
  void setSuccess() => value = VReplyState.success;

  /// Sets the state to error.
  void setError() => value = VReplyState.error;

  /// Resets the state to idle.
  void reset() => value = VReplyState.idle;
}
