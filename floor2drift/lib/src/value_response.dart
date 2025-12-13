import 'package:analyzer/dart/element/element.dart';

/// General class to return either an value or erro from a method
sealed class ValueResponse<T> {
  const ValueResponse();

  /// Create a ValueData Object
  static ValueData<S> value<S>(S data) {
    return ValueData(data);
  }

  /// Creates a ValueError Object
  static ValueError<S> error<S>(String error, Element? element) {
    return ValueError(error, element);
  }
}

/// Successfull return Value for a method call
class ValueData<T> extends ValueResponse<T> {
  /// the actual data being retunrd
  final T data;

  /// Successfull return Value for a method call
  const ValueData(this.data);
}

/// Error state
class ValueError<T> extends ValueResponse<T> {
  /// The message of the error that occurred
  final String error;

  /// The element, on which the error occurred
  ///
  /// Will be printed to the console
  final Element? element;

  /// Error state
  const ValueError(this.error, this.element);

  /// Wraps this error to a new generic type
  ///
  /// To make it possible to return Errors not matter the actual type of the generic
  ValueResponse<S> wrap<S>() {
    return ValueError(this.error, this.element);
  }

  /// Prints this erorr to the console
  void printError() {
    print("error while parsing: $error in element $element");
  }
}
