import 'package:analyzer/dart/element/element.dart';
import 'package:floor2drift/src/value_response.dart';
import 'package:sqlparser/sqlparser.dart';

/// Class to convert different sql Tokens to drift code
sealed class TokenConverter {
  /// parses different Token, that can not have a [Reference]
  static ValueResponse<String> parseToken(TokenType token, String left, String right, Element element) {
    return switch (token) {
      TokenType.and => ValueResponse.value("$left & $right"),
      TokenType.or => ValueResponse.value("$left | $right"),
      _ => ValueResponse.error("TokenType $token is a reference type token", element),
    };
  }

  /// parses all Token, that can have a [Reference] and can be an [Expression]
  static ValueResponse<String> parseReferenceToken(
    TokenType token,
    String left,
    String right,
    Element element, {
    bool asExpression = true,
  }) {
    return switch (token) {
      TokenType.equal => ValueResponse.value("$left.equals${asExpression ? "Exp" : ""}($right)"),
      TokenType.less => ValueResponse.value("$left.isSmallerThan${asExpression ? "" : "Value"}($right)"),
      TokenType.lessEqual => ValueResponse.value("$left.isSmallerOrEqual${asExpression ? "" : "Value"}($right)"),
      TokenType.exclamationEqual ||
      TokenType.lessMore =>
        ValueResponse.value("$left.equals${asExpression ? "Exp" : ""}($right).not()"),
      TokenType.more => ValueResponse.value("$left.isBiggerThan${asExpression ? "" : "Value"}($right)"),
      TokenType.moreEqual => ValueResponse.value("$left.isBiggerOrEqual${asExpression ? "" : "Value"}($right)"),
      TokenType.ampersand => ValueResponse.value("$left.bitwiseAnd($right)"),
      TokenType.pipe => ValueResponse.value("$left.bitwiseOr($right)"),
      // TODO how to shift in drift?
      TokenType.shiftLeft => ValueResponse.error("TokenType $token is not supported", element),
      TokenType.shiftRight => ValueResponse.error("TokenType $token is not supported", element),
      _ => ValueResponse.error("TokenType $token is not supported", element),
    };
  }
}
