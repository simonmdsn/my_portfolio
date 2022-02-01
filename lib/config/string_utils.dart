import 'dart:math';

extension StringUtils on String {
  String reverse() => String.fromCharCodes(runes.toList().reversed);

  String capitalize() =>
      isEmpty ? '' : substring(0, 1).toUpperCase() + substring(1);

  String capitalizeWords() =>
      trim().split(' ').map((e) => e.capitalize()).toList().join(' ');

  String swapCase() => trim()
      .split('')
      .map((e) => e.isLowerCase() ? e.toUpperCase() : e.toLowerCase())
      .toList()
      .join();

  bool isPalindrome() => this == reverse();

  bool equalsIgnoreCase(String str) => toLowerCase() == str.toLowerCase();

  bool isUpperCase() => this == toUpperCase();

  bool isLowerCase() => this == toLowerCase();

  // thanks to https://github.com/crwohlfeil/damerau-levenshtein/blob/master/src/main/java/com/codeweasel/DamerauLevenshtein.java
  int damerauLevenshteinDistance(String target) {
    List<List<int>> dist = List.generate(
        length + 1, (index) => List.generate(target.length + 1, (index) => 0));
    for (var i = 0; i < length + 1; i++) {
      dist[i][0] = i;
    }
    for (var j = 0; j < target.length + 1; j++) {
      dist[0][j] = j;
    }
    for (var i = 1; i < length + 1; i++) {
      for (var j = 1; j < target.length + 1; j++) {
        int cost = substring(i - 1) == target.substring(j - 1) ? 0 : 1;
        dist[i][j] = min(min(dist[i - 1][j] + 1, dist[i][j - 1] + 1),
            dist[i - 1][j - 1] + cost);
        if (i > 1 &&
            j > 1 &&
            substring(i - 1) == target.substring(j - 2) &&
            substring(i - 2) == target.substring(j - 1)) {
          dist[i][j] = min(dist[i][j], dist[i - 2][j - 2] + cost);
        }
      }
    }
    return dist[length][target.length];
  }

  static String randomString(int length) {
    if (length < 1) return '';
    var random = Random.secure();
    return String.fromCharCodes(
        List.generate(length + 2, (index) => random.nextInt(33) + 89));
  }
}

