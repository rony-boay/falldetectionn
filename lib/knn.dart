import 'dart:math';

class KNN {
  List<List<double>> _trainingData = [];
  List<String> _labels = [];
  int k = 3; // Number of neighbors to consider
  List<List<double>> _recentFallData = [];
  List<String> _recentFallLabels = [];
  final int _maxFallsToTrain = 10; // Number of falls to collect before retraining

  void train(List<List<double>> features, List<String> labels) {
    _trainingData = features;
    _labels = labels;
  }

  String predict(List<double> features) {
    if (_trainingData.isEmpty) {
      return 'Unknown';
    }

    List<_DistanceLabel> distances = [];

    for (int i = 0; i < _trainingData.length; i++) {
      double distance = _euclideanDistance(features, _trainingData[i]);
      distances.add(_DistanceLabel(distance, _labels[i]));
    }

    if (distances.length < k) {
      k = distances.length;
    }

    distances.sort((a, b) => a.distance.compareTo(b.distance));

    Map<String, int> labelCounts = {};
    for (int i = 0; i < k; i++) {
      String label = distances[i].label;
      labelCounts[label] = (labelCounts[label] ?? 0) + 1;
    }

    String? predictedLabel;
    int maxCount = 0;
    labelCounts.forEach((label, count) {
      if (count > maxCount) {
        maxCount = count;
        predictedLabel = label;
      }
    });

    return predictedLabel ?? 'Unknown';
  }

  double _euclideanDistance(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += pow(a[i] - b[i], 2);
    }
    return sqrt(sum);
  }

  void addFallData(List<double> features, String label) {
    _recentFallData.add(features);
    _recentFallLabels.add(label);

    if (_recentFallData.length >= _maxFallsToTrain) {
      _retrainModel();
    }
  }

  void _retrainModel() {
    _trainingData.addAll(_recentFallData);
    _labels.addAll(_recentFallLabels);

    _recentFallData.clear();
    _recentFallLabels.clear();
  }
}

class _DistanceLabel {
  final double distance;
  final String label;

  _DistanceLabel(this.distance, this.label);
}

