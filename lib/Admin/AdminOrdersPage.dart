import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wspcommerce/Admin/AdminOrderDetailPage.dart';
import '../FirebaseController.dart'; // FirebaseController'ınızın yolu

class AdminOrdersPage extends StatefulWidget {
  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  void loadOrders() async {
    var orders = await FirebaseController().getOrders();
    setState(() {
      _orders = orders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Siparişler'),
        backgroundColor: Color(0xFF8CB9BD),
      ),
      body: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> order = _orders[index];
          DateTime date = (order['date'] as Timestamp).toDate();
          String status = "";
          Color statusColor = Colors.white;
          double totalPrice = order['totalPrice'];

          if(order["status"] == 0)
          {
            status = "Sipariş Alındı";
            statusColor = Colors.white;
          }
          else if(order["status"] == 1)
          {
            status = "Sipariş Hazırlanıyor";
            statusColor = Colors.indigo;
          }
          else if(order["status"] == 2)
          {
            status = "Kargoya Verildi";
            statusColor = Colors.green;
          }
          else if(order["status"] == 3)
          {
            status = "Teslim Edildi";
            statusColor = Colors.blue;
          }

          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFECB159), // Buton Rengi
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Tarih:  ${date.day.toString()}/${date.month
                        .toString()}/${date.year.toString()} - ${date.hour
                        .toString()}:${date.minute.toString()}',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Durum: $status', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),),
                    Text('Toplam Fiyat: $totalPrice TL',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  ],
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminOrderDetailsPage(uid: order["UID"]),
                ),
              );            },
          );
        },
      ),
    );
  }
}
