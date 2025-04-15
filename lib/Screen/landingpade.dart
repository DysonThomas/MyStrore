import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myshop/Constants/constants.dart';
import 'package:http/http.dart' as http;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Future<List<Map<String,dynamic>>> _getProduct() async {
    final url = Uri.https(kBaseUrl, kProductUrl);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load products. Status: ${response.statusCode}');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        leading: Icon(Icons.menu),
        actions: [
          Icon(Icons.add_shopping_cart_outlined),
          SizedBox(width: 5,)
        ],
        centerTitle: true,
        title: Text('MY SHOP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(future: _getProduct(), builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found.'));
          } else{
            final products = snapshot.data!;
            return  GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1,mainAxisExtent: 325),
              itemCount : products.length,
                itemBuilder : (context,index){
                  final product = products[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)) ,
                    elevation: 4,
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.network(
                              product['image'],
                              width: 70,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(product['title'],style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                            Text('₹${product['price']}',
                              style: TextStyle(color: Colors.grey[700]),),
                            SizedBox(
                              height: 5,
                            ),
                            TextButton(onPressed:()=> _addToCart(product), child:  Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Add To Cart'),
                                SizedBox(width: 5,),
                                Icon(Icons.shopping_cart)
                              ],
                            ))

                          ],
                        ),
                      ),
                    ),
                  );
                }


            );
          }
        })

      ),);
        
  }
  final _myBox = Hive.box('mybox');
  _addToCart(Map<String, dynamic> product) {
  _myBox.add(product);
  }
}
