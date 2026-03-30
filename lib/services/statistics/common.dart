class DataPoints {
  DataPoints({required this.labels, required this.data});

  final List<String> labels;
  final List<({int x, double y})> data;

  factory DataPoints.empty() {
    return DataPoints(labels: [], data: []);
  }

  factory DataPoints.fromData(Map<String, int> data) {
    List<String> labels = [];
    List<({int x, double y})> dataPoints = [];
    int index = 0;
    data.forEach((key, value) {
      labels.add(key);
      dataPoints.add((x: index, y: value.toDouble()));
      index++;
    });
    return DataPoints(labels: labels, data: dataPoints);
  }

  List<({int x, double y})> getMaxCount(int maxCount) {
    if (data.length > maxCount) {
      return data.sublist(0, maxCount);
    } else {
      return data;
    }
  }
}

class StatLabelServices {
  StatLabelServices({required this.value});

  final String value;

  String getLabel() {
    if (value.contains('-')) {
      return _getStandardLabel();
    } else if (value.contains(' ')) {
      return _getTaxonFirstThreeLetters();
    } else {
      return value.length > 5 ? value.substring(0, 5) : value;
    }
  }

  String _getStandardLabel() {
    List<String> splitAtDash = value.split('-');
    if (splitAtDash.length > 1 &&
        !splitAtDash[1].toLowerCase().contains('none')) {
      return _cleanSplitString(splitAtDash);
    } else {
      String sub = value.length > 5 ? value.substring(0, 5) : value;
      return sub.replaceAll('-', '');
    }
  }

  String _cleanSplitString(List<String> splitString) {
    String first = splitString[0];
    String second = splitString[1];
    if (second.isEmpty) {
      return first.length > 5 ? first.substring(0, 5) : first;
    }
    if (first.length > 2) {
      first = first.substring(0, 2);
    }
    if (second.length > 2) {
      String sub = second.substring(0, 2);
      second = '-$sub';
    }
    return '$first$second';
  }

  String _getTaxonFirstThreeLetters() {
    try {
      List<String> splitAtSpace = value.split(' ');
      if (splitAtSpace.length > 1 && splitAtSpace[1].isNotEmpty) {
        String genus = splitAtSpace[0].substring(0, 1);
         String species = splitAtSpace[1].length > 3
            ? splitAtSpace[1].substring(0, 3)
            : splitAtSpace[1];
        return '$genus. $species';
      } else {
        return value.length > 5 ? value.substring(0, 5) : value;
      }
    } catch (e) {
      return value.length > 5 ? value.substring(0, 5) : value;
    }
  }
}
