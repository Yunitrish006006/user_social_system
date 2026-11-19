import 'package:flutter_test/flutter_test.dart';
import 'package:user_social_system/user_social_system.dart';

void main() {
  test('exports chat model, service and widget', () {
    expect(ChatMessage, isA<Type>());
    expect(DmService, isA<Type>());
    expect(DmPage, isA<Type>());
  });
}
