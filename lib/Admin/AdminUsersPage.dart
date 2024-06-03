import 'package:flutter/material.dart';
import 'package:wspcommerce/Admin/AdminOrderDetailPage.dart';
import 'package:wspcommerce/FirebaseController.dart';

class AdminUsersPage extends StatefulWidget {
  @override
  _AdminUsersPageState createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() async {
    var users = await FirebaseController().getUsers();
    setState(() {
      _users = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcılar'),
        backgroundColor: Color(0xFF8CB9BD),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          var user = _users[index];
          return ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminUserDetailsPage(uid: user['UID']),
              ),
            ),
            child: Text(user['email']),
          );
        },
      ),
    );
  }
}

class AdminUserDetailsPage extends StatefulWidget {
  final String uid;

  AdminUserDetailsPage({Key? key, required this.uid}) : super(key: key);

  @override
  _AdminUserDetailsPageState createState() => _AdminUserDetailsPageState();
}

class _AdminUserDetailsPageState extends State<AdminUserDetailsPage> {
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    loadUserDetails();
  }

  void loadUserDetails() async {
    var details = await FirebaseController().getUserDetails(widget.uid);
    setState(() {
      userDetails = details;
      print(userDetails!["orders"][0]["orderID"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcı Detayları'),
        backgroundColor: Color(0xFF8CB9BD),
      ),
      body: userDetails == null
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Divider(thickness: 2,indent: 3,color: Colors.black,),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, color: Colors.black,),
                  SizedBox(width: 5,),
                  Text('Bilgileri',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black),textAlign: TextAlign.center),
                  SizedBox(width: 5,),
                  Icon(Icons.person, color: Colors.black,),
                ],
              ),
              SizedBox(height: 5,),
              Text('E-posta: ${userDetails!['userDetails']['email']}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),textAlign: TextAlign.center,),
              Text(
                'İsim Soyisim: ${userDetails!['userDetails']['name']} ${userDetails!['userDetails']['surname']}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),textAlign: TextAlign.center),
              SizedBox(height: 25,),
              Text(
                  'Adres: ${userDetails!['userDetails']['addresses'][0]} ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),textAlign: TextAlign.center),
              SizedBox(height: 25,),
              Divider(thickness: 2,indent: 3,color: Colors.black,),
              SizedBox(height: 5,),
              Divider(thickness: 2,indent: 3,color: Color(0xFF8CB9BD),),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF8CB9BD),),
                  SizedBox(width: 5,),
                  Text('Siparişleri',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Color(0xFF8CB9BD)),textAlign: TextAlign.center),
                  SizedBox(width: 5,),
                  Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF8CB9BD),),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('        Sipariş Kodu',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                  Text('Toplam Tutar        ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                ],
              ),
              ...userDetails!['orders'].map<Widget>((order) =>
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8CB9BD) ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminOrderDetailsPage(uid: order["orderID"]),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${order["orderID"].toString()}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                          Text('${order["totalPrice"].toString()}  TL   >',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),

                        ],
                      )))
                  .toList(),
              SizedBox(height: 25,),
              Divider(thickness: 2,indent: 3,color: Color(0xFF8CB9BD),),
              SizedBox(height: 5,),
              Divider(thickness: 2,indent: 3,color: Color(0xFFECB159),),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_rounded, color: Color(0xFFECB159),),
                  SizedBox(width: 5,),
                  Text('Sepeti',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Color(0xFFECB159)),textAlign: TextAlign.center),
                  SizedBox(width: 5,),
                  Icon(Icons.shopping_basket_rounded, color: Color(0xFFECB159),),
                ],
              ),
              SizedBox(height: 5,),
              ...userDetails!['basket'].map<Widget>((basketItem) =>
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFECB159) ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminOrderDetailsPage(uid: basketItem["orderID"]),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${basketItem["orderID"].toString()}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                          Text('${basketItem["totalPrice"].toString()}  TL   >',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),

                        ],
                      )))
                  .toList(),
              SizedBox(height: 25,),
              Divider(thickness: 2,indent: 3,color: Color(0xFFECB159),),
            ],
          ),
        ),
      ),
    );
  }
}
