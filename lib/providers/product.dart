import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.https('shopapp-flutter-f0bc2-default-rtdb.firebaseio.com',
        '/userFavorites/$userId/$id.json', {'auth': token});
    try {
      final response = await http.put(url,
          body: json.encode(
            isFavorite,
          ));
      // print(response.statusCode);
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
        throw HttpException('Error occured!!');
      }
    } catch (error) {
      _setFavValue(oldStatus);
      throw HttpException('Error occured!!');
    }
  }
}
