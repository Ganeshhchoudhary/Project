// Conditional import: use `ai_service_io.dart` on native platforms (mobile/desktop),
// and `ai_service_stub.dart` on web. This prevents importing FFI-dependent
// packages (like `tflite_flutter`) when compiling for Flutter Web.
import 'ai_service_stub.dart'
    if (dart.library.io) 'ai_service_io.dart';

// The chosen implementation (either from `ai_service_io.dart` or
// `ai_service_stub.dart`) provides the `AIService` class.
