import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wspcommerce/Admin/AdminMainPage.dart';
import '../FirebaseController.dart'; // Önceden oluşturduğunuz FirebaseController'ı import edin

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseController _firebaseController = FirebaseController();

  void _login() async {
    bool isAdmin = await _firebaseController.checkAdminCredentials(
      /*_usernameController.text,
      _passwordController.text,*/
      "abkbaba", "alibk123."
    );
    if (isAdmin) {
      // AdminPage sayfasına yönlendir
      _firebaseController.signInWithEmailAndPassword("admin@wspcommerce.com", "alibk123.");
      //_firebaseController.createOrder(basket: [{"Ürün1" : "19846194619"}], userUID: _firebaseController.UserUID(), totalPrice: 200.0, address: "ABK MAHALLESİ, ABK SOKAK, NO ABK DAİRE ABK");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminPage(),
        ),
      );    } else {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı adı veya şifre hatalı!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Girişi'),
        backgroundColor: Color(0xFF8CB9BD),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
