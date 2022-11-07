// ignore_for_file: unused_field, prefer_final_fields, avoid_print

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shop_app/models/http_exception.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  var _showFavoritesOnly = false;

  final String? authToken;
  final String? userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    if (_showFavoritesOnly) {
      return _items.where((prodItem) => prodItem.isFavorite).toList();
    }
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

//without async and await
/*
  Future <void> addProduct(Product product) {
    final url = Uri.https(
        'shopapp-flutter-f0bc2-default-rtdb.firebaseio.com', '/products.json');
    return http
        .post(
      url,
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'isFavorite': product.isFavorite,
      }),
    )
        .then((response) {
      print(json.decode(response.body)['name']);
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'], //comming fro firebase //DateTime.now();
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    }).catchError((error) {
      print(error);
      throw error;
    });
  }
  */

  //with async await
  Future<void> addProduct(Product product) async {
    final url = Uri.https('shopapp-flutter-f0bc2-default-rtdb.firebaseio.com',
        '/products.json', {'auth': '$authToken'});
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': userId,
          //removed becuase now fav is added to particular user
          // 'isFavorite': product.isFavorite,
        }),
      );
      // print(json.decode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
        //comming fro/ firebase //DateTime.now();
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https('shopapp-flutter-f0bc2-default-rtdb.firebaseio.com',
          '/products/$id.json', {'auth': '$authToken'});
      try {
        await http.patch(
          url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            'isFavorite': newProduct.isFavorite,
          }),
        );
        _items[prodIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    } else {
      print('item not updated');
    }
  }

/*
  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
*/

  //optimistic updating
  /*
  In an optimistic update the UI behaves as though a change was successfully 
  completed before receiving confirmation from the server that it actually was - 
  it is being optimistic that it will eventually get the confirmation rather 
  than an error. This allows for a more responsive user experience.
  */
  /*
  void deleteProduct(String id) {
    final url = Uri.https(
        'shopapp-flutter-f0bc2-default-rtdb.firebaseio.com', '/products/$id.');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    http.delete(url).then((response) {
      debugPrint(response.statusCode.toString());
      if(response.statusCode >= 400) {
        throw HttpException('Couldn\'t delete the product');
      }
    }).catchError((_) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
    });
    _items.removeAt(existingProductIndex);

    notifyListeners();
  }
  */

  Future<void> deleteProduct(String id) async {
    final url = Uri.https('shopapp-flutter-f0bc2-default-rtdb.firebaseio.com',
        '/products/$id.json', {'auth': '$authToken'});
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    //removing the frontend
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Couldn\'t delete the product');
    }
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    // var params = {
    //   'auth': '$authToken',
    //   'orderBy': '"creatorId"',
    //   'equalTo': '"$userId"',
    // };

    dynamic params;
    if (filterByUser == true) {
      params = <String, String?>{
        'auth': '$authToken',
        'orderBy': '"creatorId"',
        'equalTo': '"$userId"',
      };
    }
    if (filterByUser == false) {
      params = <String, String?>{
        'auth': '$authToken',
      };
    }
    var url = Uri.https('shopapp-flutter-f0bc2-default-rtdb.firebaseio.com',
        '/products.json', params);
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;

      url = Uri.https('shopapp-flutter-f0bc2-default-rtdb.firebaseio.com',
          '/userFavorites/$userId.json', {'auth': authToken});
      final favoriteResponse = await http.get(url);
      final favoriteData =
          json.decode(favoriteResponse.body) as Map<String, dynamic>?;
      final List<Product> loadedProducts = [];
      extractedData?.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: double.tryParse(prodData['price'].toString())!,
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      // if (error.toString().contains('null')) {
      //   throw HttpException('No products added');
      // }
      // throw HttpException(error.toString());
      rethrow;
    }
  }
}


/*
{
  "sample":[
    {
      "description":"Lady with a red umbrella",
      "image-url":"https://i.imgur.com/pwpWaWu.jpg"
    },
    {
      "description":"Flowers and some fruits",
      "image-url":"https://i.imgur.com/KIPtISY.jpg"
    },
    {
      "description":"Beautiful scenery",
      "image-url":"https://i.imgur.com/2jMCqQ2.jpg"
    },
    {
      "description":"Some kind of bird",
      "image-url":"https://i.imgur.com/QFDRuAh.jpg"
    },
    {
      "description":"The attack of dragons",
      "image-url":"https://i.imgur.com/8yIIokW.jpg"
    }
    
  ]

}
*/


// sidd@gmail.com




