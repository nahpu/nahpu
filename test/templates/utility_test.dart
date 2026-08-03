import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/utility_services.dart';

void main() {
  test('Test list is distinct', () {
    List<String> list = ['a', 'b', 'c', 'a', 'b', 'c'];
    List<String> distinctList = getDistinctList(list);
    expect(distinctList.length, 3);
  });

  test('Continuous numbers', () {
    List<int> list = [1, 2, 3, 4, 5];
    List<int> invalid = [1, 2, 3, 5, 6];
    List<bool> result = checkListNumberContinuous(list);
    List<bool> invalidResult = checkListNumberContinuous(invalid);
    expect(result.length, 4);
    expect(result[0], isTrue);
    expect(result[1], isTrue);
    expect(result[2], isTrue);
    expect(result[3], isTrue);
    expect(invalidResult.length, 4);
    expect(invalidResult[0], isTrue);
    expect(invalidResult[1], isTrue);
    expect(invalidResult[2], isFalse);
    expect(invalidResult[3], isTrue);
  });

  test('Test list contains', () {
    List<String> list = [
      'a',
      'b',
      'c',
    ];
    expect(isListContains(list, 'A'), isTrue);
    expect(isListContains(list, 'e'), isFalse);
  });

  test('String contains', () {
    String string = 'abc';
    expect(string.isContain('a'), isTrue);
    expect(string.isContain('A'), isTrue);
    expect(string.isContain('e'), isFalse);
  });

  test('String match', () {
    String string = 'abc';
    String exactString = 'abc';
    expect(string.isMatch('ABC'), isTrue);
    expect(string.isMatchExact(exactString), isTrue);
  });
}
