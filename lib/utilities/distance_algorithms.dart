import 'dart:math' as math;

class Similarity {
  static double nGramCosineSimilarity(String str1, String str2,
      [int nGramSize = 2]) {
    final str1Bigrams = _getNGrams(str1, nGramSize);
    final str2Bigrams = _getNGrams(str2, nGramSize);

    final commonBigrams = str1Bigrams.intersection(str2Bigrams).length;
    final str1BigramsCount = str1Bigrams.length;
    final str2BigramsCount = str2Bigrams.length;

    final denominator = math.sqrt(str1BigramsCount * str2BigramsCount);
    final numerator = commonBigrams.toDouble();

    return numerator / denominator;
  }

  static Set<String> _getNGrams(String str, int n) {
    final nGrams = <String>{};
    for (var i = 0; i < str.length - n + 1; i++) {
      nGrams.add(str.substring(i, i + n));
    }
    return nGrams;
  }

  static int levenshteinDistance(String s1, String s2) {
    var m = s1.length, n = s2.length;
    var d = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (var i = 1; i <= m; i++) {
      d[i][0] = i;
    }
    for (var j = 1; j <= n; j++) {
      d[0][j] = j;
    }
    for (var j = 1; j <= n; j++) {
      for (var i = 1; i <= m; i++) {
        if (s1[i - 1] == s2[j - 1]) {
          d[i][j] = d[i - 1][j - 1];
        } else {
          d[i][j] =
              1 + [d[i - 1][j], d[i][j - 1], d[i - 1][j - 1]].reduce(math.min);
        }
      }
    }
    return d[m][n];
  }

  static double jaroWinklerDistance(String str1, String str2) {
    final jDistance = _jaroDistance(str1, str2);
    final prefixLength = _getCommonPrefixLength(str1, str2);
    const scalingFactor = 0.1;

    return jDistance + (prefixLength * scalingFactor * (1 - jDistance));
  }

  static double _jaroDistance(String str1, String str2) {
    if (str1 == str2) {
      return 1.0;
    }

    final maxDistance = (str1.length + str2.length) ~/ 2 - 1;
    final matches1 = _getMatches(str1, str2, maxDistance);
    final matches2 = _getMatches(str2, str1, maxDistance);

    if (matches1.isEmpty || matches2.isEmpty) {
      return 0.0;
    }

    var transpositions = 0;
    var j = 0;

    for (var i = 0; i < matches1.length; i++) {
      final match1 = matches1[i];

      while (j < matches2.length) {
        final match2 = matches2[j];
        j++;

        if (match2 + maxDistance < match1) {
          continue;
        }

        if (match2 > match1 + maxDistance) {
          break;
        }

        transpositions++;
        break;
      }
    }

    final jaroDistance = (matches1.length + matches2.length + transpositions) /
        (3 * str1.length);

    return jaroDistance;
  }

  static List<int> _getMatches(String str1, String str2, int maxDistance) {
    final matches = List.filled(str1.length, -1);
    final visited = List.filled(str2.length, false);
    var matchCount = 0;

    for (var i = 0; i < str1.length; i++) {
      final ch1 = str1[i];

      for (var j = 0; j < str2.length; j++) {
        if (visited[j]) {
          continue;
        }

        if (ch1 != str2[j]) {
          continue;
        }

        if (i > 0 &&
            j > 0 &&
            i - j > -maxDistance &&
            matches[i - 1] != -1 &&
            matches[i - 1] >= j) {
          continue;
        }

        visited[j] = true;
        matches[i] = j;
        matchCount++;
        break;
      }
    }

    return matches.sublist(0, matchCount);
  }

  static int _getCommonPrefixLength(String str1, String str2) {
    final maxLength = str1.length < str2.length ? str1.length : str2.length;

    for (var i = 0; i < maxLength; i++) {
      if (str1[i] != str2[i]) {
        return i;
      }
    }

    return maxLength;
  }
}
