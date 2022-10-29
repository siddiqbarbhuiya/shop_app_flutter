// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widget/app_drawer.dart';
import 'package:shop_app/widget/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  const UserProductScreen({super.key});
  static const routeName = '/user-products';

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          }, icon: const Icon(Icons.add)),
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
            itemCount: productsData.items.length,
            itemBuilder: ((_, i) => Column(
                  children: [
                    UserProductItem(
                      id: productsData.items[i].id,
                      title: productsData.items[i].title,
                      imageUrl: productsData.items[i].imageUrl,
                    ),
                    Divider(height: 1),
                  ],
                ))),
      ),
    );
  }
}
