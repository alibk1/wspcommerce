import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../FirebaseController.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final String uid;

  AdminOrderDetailsPage({Key? key, required this.uid}) : super(key: key);

  @override
  _AdminOrderDetailsPageState createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  Map<String, dynamic>? orderDetails;
  List<dynamic> _basket = [];
  int _currentStatus = 0;
  double _totalPrice = 0.0;
  DateTime _orderDate = DateTime.now();
  String _address = "";

  TextEditingController _cargoLinkController = TextEditingController();

  final Map<int, String> _statusTexts = {
    0: "Sipariş Alındı",
    1: "Sipariş Hazırlanıyor",
    2: "Kargoya Verildi",
    3: "Sipariş Teslim Edildi",
  };

  @override
  void initState() {
    super.initState();
    loadOrderDetails();
  }

  void loadOrderDetails() async {
    var details = await FirebaseController().getOrder(widget.uid);
    if (details != null) {
      setState(() {
        orderDetails = details;
        _currentStatus = details['status'];
        _address = details['address'];
        _orderDate = (details['date'] as Timestamp).toDate();
        _totalPrice = details['totalPrice'];
        _basket = details["basket"];
        _cargoLinkController.text = details["cargoLink"];
      });
    }
  }

  Future<void> updateOrderStatus(int? newStatus) async {
    if (newStatus != null) {
      await FirebaseController().updateOrderStatus(widget.uid, orderDetails!["userUID"],newStatus).then((_) {});
    }
  }
    Future<void> updateOrderCargoLink(String? newLink) async {
    if (newLink != null) {
      await FirebaseController().updateOrderCargoLink(widget.uid, orderDetails!["userUID"], newLink).then((_) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sipariş Detayları'),
        backgroundColor: Color(0xFF8CB9BD),
      ),
      body: orderDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20,),
              Text('Sipariş ID: ${widget.uid}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              SizedBox(height: 20,),
              Text('Toplam Fiyat: ${_totalPrice}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              SizedBox(height: 20,),
              Text('Sipariş Tarihi:  ${_orderDate.day.toString()}/${_orderDate.month
                  .toString()}/${_orderDate.year.toString()} - ${_orderDate.hour
                  .toString()}:${_orderDate.minute.toString()}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              SizedBox(height: 20,),
              Text('Adres: ${_address}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
              SizedBox(height: 20,),
              Text('Ürünler: ${_basket}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sipariş Durumu:      ", style: TextStyle(fontWeight: FontWeight.bold),),
                  DropdownButton<int>(
                    value: _currentStatus,
                    items: _statusTexts.entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (dynamic newStatus)
                    {
                      setState(() {
                        _currentStatus = newStatus;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20,),
              TextFormField(
                controller: _cargoLinkController,
                decoration: InputDecoration(
                  labelText: 'Kargo Linki:',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(150.0),
                    borderSide: BorderSide(color: Color(
                        int.parse("#04C4D9".substring(1, 7), radix: 16) +
                            0xFF000000), width: 50,),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8CB9BD), // Buton Rengi
                ),
                onPressed: () async
                {
                  await updateOrderStatus(_currentStatus);
                  await updateOrderCargoLink(_cargoLinkController.text);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kaydedildi :)")));
                },
                child: Text('Kaydet', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
