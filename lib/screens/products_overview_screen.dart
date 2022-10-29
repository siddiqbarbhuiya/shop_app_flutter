// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_key_in_widget_constructors, avoid_print, constant_identifier_names, unused_local_variable

import 'package:flutter/material.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widget/app_drawer.dart';
import 'package:provider/provider.dart';
import '../widget/products_grid.dart';
import '../widget/badge.dart';
import '../providers/cart.dart';

enum FIlterOptions {
  Favorites,
  All,
}

class ProductsOverviewSCreen extends StatefulWidget {
  @override
  State<ProductsOverviewSCreen> createState() => _ProductsOverviewSCreenState();
}

class _ProductsOverviewSCreenState extends State<ProductsOverviewSCreen> {
  var _showFavoritesOnly = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    // we cant use async await here
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      try {
        Provider.of<Products>(context).fetchAndSetProducts().then((_) {
          //to turn off the spinner
          setState(() {
            _isLoading = false;
          });
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MyShop',
        ),
        actions: [
          PopupMenuButton(
            onSelected: ((FIlterOptions selectedValue) {
              print(selectedValue);
              setState(() {
                if (selectedValue == FIlterOptions.Favorites) {
                  // productContainer.showFavoritesOnly();
                  _showFavoritesOnly = true;
                } else {
                  // productContainer.showAll();
                  _showFavoritesOnly = false;
                }
              });
            }),
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FIlterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FIlterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                print('pressed');
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(showFavs: _showFavoritesOnly),
          
    );
  }
}
