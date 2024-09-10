import 'dart:math';

class KNN {
  // Stores the training data and corresponding labels
  List<List<double>> _trainingData = [];
  List<String> _labels = [];
  int k = 3; // Number of neighbors to consider

  // Holds recent fall data before retraining
  List<List<double>> _recentFallData = [];
  List<String> _recentFallLabels = [];
  final int maxFallsToTrain; // Number of falls to collect before retraining

  // Constructor to allow flexible setting of max falls to train
  KNN({this.k = 3, this.maxFallsToTrain = 10});

  /// Train the model with the provided features and labels.
  /// This method appends new data instead of replacing the existing training data.
  void train(List<List<double>> features, List<String> labels) {
    _trainingData.addAll(features);
    _labels.addAll(labels);
  }

  /// Predict the label for the given [features] using the KNN algorithm.
  /// Returns the predicted label based on the nearest neighbors.
  String predict(List<double> features) {
    if (_trainingData.isEmpty) {
      return 'Unknown'; // No training data available
    }

    // Calculate the Euclidean distance between input features and training data
    List<_DistanceLabel> distances = [];
    for (int i = 0; i < _trainingData.length; i++) {
      double distance = _euclideanDistance(features, _trainingData[i]);
      distances.add(_DistanceLabel(distance, _labels[i]));
    }

    // If fewer training points than k, adjust k to available data size
    int adjustedK = min(k, distances.length);

    // Sort by distance
    distances.sort((a, b) => a.distance.compareTo(b.distance));

    // Count the labels of the k nearest neighbors
    Map<String, int> labelCounts = {};
    for (int i = 0; i < adjustedK; i++) {
      String label = distances[i].label;
      labelCounts[label] = (labelCounts[label] ?? 0) + 1;
    }

    // Return the label with the highest count
    return _getMostFrequentLabel(labelCounts);
  }

  /// Adds new fall data to the recent fall collection.
  /// Triggers retraining if the data exceeds [_maxFallsToTrain].
  void addFallData(List<double> features, String label) {
    _recentFallData.add(features);
    _recentFallLabels.add(label);

    // Retrain the model when enough new falls are collected
    if (_recentFallData.length >= maxFallsToTrain) {
      _retrainModel();
    }
  }

  /// Retrains the KNN model by incorporating the recent fall data into the training set.
  void _retrainModel() {
    _trainingData.addAll(_recentFallData);
    _labels.addAll(_recentFallLabels);

    // Clear recent fall data after retraining
    _recentFallData.clear();
    _recentFallLabels.clear();
  }

  /// Calculates the Euclidean distance between two vectors.
  double _euclideanDistance(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += pow(a[i] - b[i], 2);
    }
    return sqrt(sum);
  }

  /// Returns the label with the highest count from the map.
  String _getMostFrequentLabel(Map<String, int> labelCounts) {
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
}

class _DistanceLabel {
  final double distance;
  final String label;

  _DistanceLabel(this.distance, this.label);
}
