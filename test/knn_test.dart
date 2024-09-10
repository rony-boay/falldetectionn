import 'package:falldetectionn1/knn.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KNN Class Tests', () {
    late KNN knn;

    setUp(() {
      // Initialize the KNN instance before each test
      knn = KNN(k: 3, maxFallsToTrain: 5);
    });

    test('KNN should correctly predict a label after training', () {
      // Training data
      List<List<double>> trainingData = [
        [1.0, 2.0], // Fall
        [2.0, 3.0], // Fall
        [4.0, 5.0], // No Fall
        [6.0, 7.0], // No Fall
      ];

      // Corresponding labels
      List<String> labels = ['Fall', 'Fall', 'No Fall', 'No Fall'];

      // Train the KNN model
      knn.train(trainingData, labels);

      // Test prediction (this point is closer to 'No Fall' data)
      String predictedLabel = knn.predict([5.0, 6.0]);
      expect(predictedLabel, 'No Fall');

      // Test prediction (this point is closer to 'Fall' data)
      predictedLabel = knn.predict([1.5, 2.5]);
      expect(predictedLabel, 'Fall');
    });

    test('KNN should return "Unknown" if no training data is available', () {
      // Predict without any training data
      String predictedLabel = knn.predict([1.0, 2.0]);
      expect(predictedLabel, 'Unknown');
    });

    test('KNN should retrain when max falls are collected', () {
      // Adding fall data
      List<List<double>> fallData = [
        [7.0, 8.0], // Fall
        [8.0, 9.0], // Fall
        [9.0, 10.0], // No Fall
        [10.0, 11.0], // No Fall
        [11.0, 12.0], // Fall
      ];

      // Corresponding labels
      List<String> fallLabels = ['Fall', 'Fall', 'No Fall', 'No Fall', 'Fall'];

      // Add fall data to the KNN model, retraining should occur after 5 falls
      for (int i = 0; i < fallData.length; i++) {
        knn.addFallData(fallData[i], fallLabels[i]);
      }

      // Check if the model has retrained with new fall data
      String predictedLabel = knn.predict([9.0, 10.0]);
      expect(predictedLabel, 'No Fall');
    });

    test('KNN should adjust k if training data is smaller than k', () {
      // Training data with only 2 points
      List<List<double>> trainingData = [
        [1.0, 2.0], // Fall
        [2.0, 3.0], // No Fall
      ];

      // Corresponding labels
      List<String> labels = ['Fall', 'No Fall'];

      // Train the KNN model
      knn.train(trainingData, labels);

      // Since k = 3 but we only have 2 points, it should adjust k to 2
      String predictedLabel = knn.predict([1.5, 2.5]);
      expect(predictedLabel, isNotNull);
    });
  });
}
