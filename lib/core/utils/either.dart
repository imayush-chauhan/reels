class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool _isRight;

  const Either._left(this._left)
      : _right = null,
        _isRight = false;

  const Either._right(this._right)
      : _left = null,
        _isRight = true;

  bool get isRight => _isRight;
  bool get isLeft => !_isRight;

  L get left {
    if (_isRight) throw StateError('Either is Right, cannot get Left.');
    return _left as L;
  }

  R get right {
    if (!_isRight) throw StateError('Either is Left, cannot get Right.');
    return _right as R;
  }

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return _isRight ? onRight(_right as R) : onLeft(_left as L);
  }

  static Either<L, R> leftValue<L, R>(L value) => Either._left(value);
  static Either<L, R> rightValue<L, R>(R value) => Either._right(value);
}

Either<L, R> left<L, R>(L value) => Either.leftValue(value);
Either<L, R> right<L, R>(R value) => Either.rightValue(value);
