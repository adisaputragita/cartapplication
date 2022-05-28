import 'package:cartapplication/cart_screen.dart';
import 'package:cartapplication/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {

  @override
  void initState() {
    getCartAmount();
    super.initState();
  }

  void getCartAmount() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("Users")
          .doc(User.name)
          .collection("Cart")
          .get();

      int a = 0;
      for(int i = 0; i < snapshot.docs.length; i++) {
        int b = snapshot.docs[i]['amount'];
        a += b;
      }

      setState(() {
        User.cartItems = a;
      });
    } catch(e) {
      setState(() {
        User.cartItems = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            SizedBox(height: screenHeight / 16,),
            Stack(
              children: [
                Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Welcome, ${User.name}",
                        style: GoogleFonts.montserrat(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Tap on an item to add it to cart",
                        style: GoogleFonts.montserrat(
                          color: Colors.black26,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const CartScreen()),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            color: Colors.redAccent,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              User.cartItems.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("Items").snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  final snap = snapshot.data!.docs;
                  return ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: snap.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: Text("Do you want to add ${snap[index]['name']} to the cart?"),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        User.cartItems += 1;
                                      });
                                      try {
                                        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("Users")
                                            .doc(User.name)
                                            .collection("Cart")
                                            .doc(snap[index]['name'])
                                            .get();

                                        await FirebaseFirestore.instance.collection("Users")
                                            .doc(User.name)
                                            .collection("Cart")
                                            .doc(snap[index]['name']).update({
                                          'amount': snapshot['amount'] + 1,
                                        });
                                      } catch(e) {
                                        await FirebaseFirestore.instance.collection("Users")
                                            .doc(User.name)
                                            .collection("Cart")
                                            .doc(snap[index]['name']).set({
                                          'name': snap[index]['name'],
                                          'amount': 1,
                                          'image': snap[index]['image'],
                                        });
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Yes"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("No"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          height: screenHeight / 3,
                          width: screenWidth,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Image.network(
                                  snap[index]['image'],
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    snap[index]['name'],
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
