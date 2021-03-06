import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/models/Cart.dart';
import 'package:test_live_app/models/Product.dart';
import '../controllers/api.dart';

class ProductDetailPage extends StatefulWidget {
  final String sku;
  final String channelName;

  const ProductDetailPage({Key key, this.sku, this.channelName})
      : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product product;
  String _accessToken;
  int _quantity = 0;
  int oldQuantity = 0;

  Cart _cartData = Cart();
  int cartLen = 0;

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    setState(() {
      _accessToken = accessToken;
    });
    return _accessToken;
  }

  Future<Cart> getUserCartData() async {
    print('ENTER GETUSERCARTDATA');
    final headers = {
      "access-token": _accessToken,
    };
    print(headers);
    return CartService.getUserCart(headers);
  }

  Future<void> addProductToCart(sku, _quantity, title) async {
    print("Enter Add to Cart");
    final headers = {
      "access-token": _accessToken,
    };

    final body = {
      "sku": sku.toString(),
      "quantity": _quantity.toString(),
    };
    print('Headers: $headers');
    print('body: $body');

    CartService.addToCart(headers, body).then((res) {
      print('res: $res');
      if (res == true) {
        getUserCartData().then((cartData) {
          setState(() {
            _cartData = cartData;
            cartLen = _cartData.cartDetails.length;
          });
          print('cartLen: $cartLen');
        });
        Fluttertoast.showToast(
          msg: "Added $_quantity $title to your Cart.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue[800],
          textColor: Colors.white,
          fontSize: 13.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error! Can't get this Item to your Cart.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 13.0,
        );
      }
    });
    Navigator.of(context).pop();
  }

  Future<int> getQuantityofItem(_accessToken, sku) async {
    final headers = {
      "access-token": _accessToken.toString(),
    };
    final body = {
      "sku": sku.toString(),
    };
    await CartService.getItemQuantity(headers, body).then((quantity) {
      if (_quantity == null) {
        setState(() {
          _quantity = 0;
        });
      } else {
        setState(() {
          _quantity = quantity;
        });
      }
    });
    print('_quantity In Function: $_quantity');
    return _quantity;
  }

  @override
  void initState() {
    super.initState();
    getAccessToken().then((accessToken) {
      getUserCartData().then((cartData) {
        setState(() {
          _cartData = cartData;
          cartLen = _cartData.cartDetails.length;
        });
        print('cartLen: $cartLen');
      });
    });
    ProductService.getProductDetail(widget.sku).then((res) {
      setState(() {
        product = res;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return product == null
        ? Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    backgroundColor: Colors.blue[800],
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.blue[800],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                '${product.title}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              actions: <Widget>[
                cartButton(),
              ],
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.87,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        productImagePreview(),
                        productInfo(),
                        SizedBox(height: 8),
                        productDetail(),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
                      ],
                    ),
                  ),
                ),
                bottomBar(),
              ],
            ),
          );
  }

  Widget bottomBar() {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            buyNowButton(product.sku, _quantity, product.title),
            addToCartButton(product.sku, _quantity, product.title)
          ],
        ),
      ),
    );
  }

  Widget buyNowButton(sku, quantityInCart, title) {
    return GestureDetector(
      onTap: () {
        getQuantityofItem(_accessToken, sku).then((quantityInCart) {
          setState(() {
            oldQuantity = quantityInCart;
          });
          showBuyNowQuantitySelection(
            selectedProductSku: product.sku,
            selectedProductTitle: product.title,
            selectedProductImage: product.image,
            selectedProductPrice: product.price,
            quantityInCart: quantityInCart,
          );
        });
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.055,
        width: MediaQuery.of(context).size.width * 0.6,
        margin: EdgeInsets.only(right: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            colors: [
              Colors.blue[600],
              Colors.blue[700],
              Colors.blue[700],
              Colors.blue[800],
            ],
          ),
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Center(
          child: Text(
            'Buy Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget addToCartButton(sku, quantityInCart, title) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          print('Tap ADD To Cart');
          print(_accessToken);
          print(sku);
          getQuantityofItem(_accessToken, sku).then((quantityInCart) {
            setState(() {
              oldQuantity = quantityInCart;
            });
            showAddtoCartQuantitySelection(
              selectedProductSku: product.sku,
              selectedProductTitle: product.title,
              selectedProductImage: product.image,
              selectedProductPrice: product.price,
              quantityInCart: quantityInCart,
            );
          });
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.055,
          width: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              colors: [
                Colors.yellow[700],
                Colors.yellow[700],
                Colors.yellow[800],
              ],
            ),
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Center(
            child: Text(
              'Add to Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget confirmQuantity(quantityInCart) {
    return GestureDetector(
      onTap: () {
        if (quantityInCart != oldQuantity) {
          if (quantityInCart != 0) {
            addProductToCart(product.sku, quantityInCart, product.title);
          } else {
            Fluttertoast.showToast(
              msg: "Please add Quantity of Product.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 13.0,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "This Product is Already in your cart",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.yellow,
            textColor: Colors.white,
            fontSize: 13.0,
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.055,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.blue[800],
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: Text(
            'Confirm',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget cartButton() {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.shopping_cart,
            color: Colors.blue[800],
          ),
          tooltip: 'Cart',
          onPressed: () {
            Navigator.of(context).pushNamed('/cartPage').then((value) {
              getUserCartData().then((cartData) {
                setState(() {
                  _cartData = cartData;
                  cartLen = _cartData.cartDetails.length;
                });
                print('cartLen: $cartLen');
              });
            });
          },
        ),
        cartLen != 0
            ? Positioned(
                top: 5,
                right: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Text('$cartLen'),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget productImagePreview() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(bottom: 20),
      child: Image.network(
        product.image,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget productInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${product.title}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            height: 2,
          ),
        ),
        Text(
          'SKU: ${product.sku}',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
        Text(
          '฿${product.price}',
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 17,
            height: 2,
          ),
        ),
      ],
    );
  }

  Widget productDetail() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: product.detailProducts.length,
        itemBuilder: (context, index) {
          return Container(
            child: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(
                      Icons.arrow_right,
                      size: 15,
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(
                    text: '${product.detailProducts[index].text}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  showAddtoCartQuantitySelection({
    selectedProductSku,
    selectedProductTitle,
    selectedProductImage,
    selectedProductPrice,
    quantityInCart,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.95),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, state) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.26,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Add to Cart',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 15,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(
                            Icons.close,
                            size: 15,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            showProductImage(selectedProductImage),
                            showProductInfo(
                              selectedProductTitle: selectedProductTitle,
                              selectedProductPrice: selectedProductPrice,
                            ),
                          ],
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  state(() {
                                    quantityInCart > 0
                                        ? quantityInCart -= 1
                                        : quantityInCart = 0;
                                    print(quantityInCart);
                                  });
                                },
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 1.5, color: Colors.grey[300]),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 15,
                                    color: quantityInCart > 0
                                        ? Colors.black
                                        : Colors.grey[300],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '$quantityInCart',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  state(() {
                                    quantityInCart += 1;
                                    print(quantityInCart);
                                  });
                                },
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1.5,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  confirmQuantity(quantityInCart),
                ],
              ),
            );
          },
        );
      },
    );
  }

  showBuyNowQuantitySelection({
    selectedProductSku,
    selectedProductTitle,
    selectedProductImage,
    selectedProductPrice,
    quantityInCart,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.95),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, state) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.26,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    margin: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Buy Now',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 15,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(
                            Icons.close,
                            size: 15,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            showProductImage(selectedProductImage),
                            showProductInfo(
                              selectedProductTitle: selectedProductTitle,
                              selectedProductPrice: selectedProductPrice,
                            ),
                          ],
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  state(() {
                                    quantityInCart > 0
                                        ? quantityInCart -= 1
                                        : quantityInCart = 0;
                                    print(quantityInCart);
                                  });
                                },
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 1.5, color: Colors.grey[300]),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 15,
                                    color: quantityInCart > 0
                                        ? Colors.black
                                        : Colors.grey[300],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '$quantityInCart',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  state(() {
                                    quantityInCart += 1;
                                    print(quantityInCart);
                                  });
                                },
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1.5,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  confirmQuantityAndNavigate(quantityInCart),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget confirmQuantityAndNavigate(quantityInCart) {
    return GestureDetector(
      onTap: () {
        if (quantityInCart != oldQuantity) {
          if (quantityInCart != 0) {
            addProductToCart(product.sku, quantityInCart, product.title)
                .then((_) {
              Navigator.pushNamed(context, '/cartPage');
            });
          } else {
            Fluttertoast.showToast(
              msg: "Please add Quantity of Product.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 13.0,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "This Product is Already in your cart",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.yellow,
            textColor: Colors.white,
            fontSize: 13.0,
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.055,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.blue[800],
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: Text(
            'Confirm',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

// ---------------------------------------------------------------------------------------

  Widget showProductImage(selectedProductImage) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.1,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Image.network(
          selectedProductImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget showProductInfo({selectedProductTitle, selectedProductPrice}) {
    return Container(
      constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          showProductTitle(selectedProductTitle),
          showProductPrice(selectedProductPrice),
        ],
      ),
    );
  }

  Widget showProductTitle(selectedProductTitle) {
    return Text(
      selectedProductTitle,
      style: TextStyle(
        color: Colors.black,
        fontSize: 15.0,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget showProductPrice(selectedProductPrice) {
    return Container(
      child: Text(
        '฿$selectedProductPrice / Item',
        style: TextStyle(
          color: Colors.blue[900],
          fontSize: 13.0,
        ),
      ),
    );
  }
}
