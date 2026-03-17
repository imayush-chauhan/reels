import 'package:flutter_test/flutter_test.dart';
import 'package:reels/core/utils/either.dart';
import 'package:reels/core/errors/failures.dart';

void main() {
  group('Either', () {
    test('right() creates a Right value', () {
      final result = right<Failure, String>('success');
      expect(result.isRight, true);
      expect(result.isLeft, false);
      expect(result.right, 'success');
    });

    test('left() creates a Left value', () {
      final result = left<Failure, String>(const NetworkFailure('err'));
      expect(result.isLeft, true);
      expect(result.isRight, false);
      expect(result.left.message, 'err');
    });

    test('fold returns left callback for Left', () {
      final result = left<Failure, String>(const NetworkFailure());
      final out = result.fold((f) => 'fail: ${f.message}', (v) => 'ok: $v');
      expect(out, 'fail: Network error occurred.');
    });

    test('fold returns right callback for Right', () {
      final result = right<Failure, String>('hello');
      final out = result.fold((f) => 'fail', (v) => 'ok: $v');
      expect(out, 'ok: hello');
    });

    test('accessing right on Left throws StateError', () {
      final result = left<Failure, String>(const UnknownFailure());
      expect(() => result.right, throwsStateError);
    });

    test('accessing left on Right throws StateError', () {
      final result = right<Failure, String>('data');
      expect(() => result.left, throwsStateError);
    });
  });
}
