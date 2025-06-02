import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class CompressionUtils {
  /// Loads and decompresses a JSON file from assets
  static Future<dynamic> loadCompressedJson(String assetPath) async {
    try {
      // Check if the path ends with .gz extension
      final bool isCompressed = assetPath.endsWith('.gz');
      
      if (isCompressed) {
        // Load the compressed bytes
        final ByteData data = await rootBundle.load(assetPath);
        final List<int> bytes = data.buffer.asUint8List();
        
        // Decompress the bytes
        final List<int> decompressedBytes = GZipCodec().decode(bytes);
        
        // Convert to string and parse JSON
        final String jsonString = utf8.decode(decompressedBytes);
        return json.decode(jsonString);
      } else {
        // Load regular JSON file
        final String jsonString = await rootBundle.loadString(assetPath);
        return json.decode(jsonString);
      }
    } catch (e) {
      throw Exception('Failed to load and decompress JSON: $e');
    }
  }
  
  /// Compresses JSON data to a file (for development use)
  static Future<void> compressJsonToFile(String inputPath, String outputPath) async {
    try {
      // Read the input file
      final File inputFile = File(inputPath);
      final String jsonString = await inputFile.readAsString();
      
      // Encode to bytes
      final List<int> jsonBytes = utf8.encode(jsonString);
      
      // Compress the bytes
      final List<int> compressedBytes = GZipCodec().encode(jsonBytes);
      
      // Write the compressed bytes to the output file
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(compressedBytes);
      
      print('Compressed JSON file from ${inputFile.lengthSync() ~/ 1024} KB to ${outputFile.lengthSync() ~/ 1024} KB');
    } catch (e) {
      throw Exception('Failed to compress JSON to file: $e');
    }
  }
} 