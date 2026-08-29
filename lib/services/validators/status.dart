//! Validation status model

import 'package:material_ui/material_ui.dart';

/// Sealed class acts as a base class for all the validation status classes
/// [ValidationSuccess], [ValidationFailure], [ValidationWarning]
/// [ValidationSuccess] - Represents a successful validation
/// [ValidationFailure] - Represents a failed validation with a message
/// [ValidationWarning] - Represents a warning validation with a message
/// This allows to handle all the validation status in a single place
/// more like an enum with values in some languages, e.g., Rust
sealed class ValidationStatus {}

class ValidationSuccess extends ValidationStatus {}

class ValidationFailure extends ValidationStatus {
  /// Message to be displayed when validation fails
  final String message;

  ValidationFailure(this.message);
}

class ValidationWarning extends ValidationStatus {
  /// Message to be displayed when validation warns
  final String message;

  ValidationWarning(this.message);
}

/// Match icon for the validation status
IconData matchIcon(ValidationStatus status) {
  switch (status) {
    case ValidationSuccess():
      return Icons.check;
    case ValidationFailure():
      return Icons.close;
    case ValidationWarning():
      return Icons.warning;
  }
}
