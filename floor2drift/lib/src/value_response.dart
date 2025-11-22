import 'package:analyzer/dart/element/element.dart';

sealed class ValueResponse<T> {
  const ValueResponse();

  static ValueData<S> value<S>(S data) {
    return ValueData(data);
  }

  static ValueError<S> error<S>(String error, Element? element) {
    return ValueError(error, element);
  }

  ValueResponse<S> wrap<S>();
}

class ValueData<T> extends ValueResponse<T> {
  final T data;

  const ValueData(this.data);

  @override
  ValueResponse<S> wrap<S>() {
    throw UnimplementedError("wrap only works for errors or warnings");
  }
}

class ValueError<T> extends ValueResponse<T> {
  final String error;

  final Element? element;

  const ValueError(this.error, this.element);

  @override
  ValueResponse<S> wrap<S>() {
    return ValueError(this.error, this.element);
  }
}
