import 'dart:ui';

/// Suaviza traços do pincel para reduzir tremores naturais da mão.
class PathSmoother {
  /// [strength] de 0 (sem filtro) a 10 (máxima suavização).
  static List<Offset> smooth(List<Offset> path, double strength) {
    if (strength <= 0 || path.length < 3) return path;

    var result = _movingAverage(
      path,
      (strength * 1.2).round().clamp(2, 12),
    );

    final iterations = (strength / 3).floor().clamp(0, 3);
    for (var i = 0; i < iterations; i++) {
      result = _chaikin(result);
    }

    return result;
  }

  static List<Offset> _movingAverage(List<Offset> path, int window) {
    if (path.length <= window) return path;

    final half = window ~/ 2;
    return List.generate(path.length, (i) {
      var sumX = 0.0;
      var sumY = 0.0;
      var count = 0;

      for (var j = i - half; j <= i + half; j++) {
        if (j >= 0 && j < path.length) {
          sumX += path[j].dx;
          sumY += path[j].dy;
          count++;
        }
      }

      return Offset(sumX / count, sumY / count);
    });
  }

  static List<Offset> _chaikin(List<Offset> path) {
    if (path.length < 3) return path;

    final result = <Offset>[path.first];
    for (var i = 0; i < path.length - 1; i++) {
      final p0 = path[i];
      final p1 = path[i + 1];
      result.add(
        Offset(p0.dx * 0.75 + p1.dx * 0.25, p0.dy * 0.75 + p1.dy * 0.25),
      );
      result.add(
        Offset(p0.dx * 0.25 + p1.dx * 0.75, p0.dy * 0.25 + p1.dy * 0.75),
      );
    }
    result.add(path.last);
    return result;
  }
}
