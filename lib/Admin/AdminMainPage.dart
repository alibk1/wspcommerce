import 'package:flutter/material.dart';
import 'package:wspcommerce/Admin/AdminCategoriesPage.dart';
import 'package:wspcommerce/Admin/AdminOrdersPage.dart';
import 'package:wspcommerce/Admin/AdminProductsPage.dart';
import 'package:wspcommerce/Admin/AdminUsersPage.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Paneli"),
        backgroundColor: Color(0xFF8CB9BD),
      ),
      backgroundColor: Color(0xFFFEFBF6),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Ürünleri Düzenle Butonu
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFECB159), // Buton Rengi
                  ),
                  onPressed: () {
                    //TODO: Ürünleri Düzenle sayfasına yönlendir
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminProductsPage(),
                      ),
                    );
                  },
                  child: Text('Ürünleri Düzenle'),
                ),
              ),
              // Siparişler Butonu
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF8CB9BD), // Buton Rengi
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminOrdersPage(),
                      ),
                    );
                  },
                  child: Text('Siparişler'),
                ),
              ),
              // Kullanıcıları Düzenle Butonu
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFB67352), // Buton Rengi
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminUsersPage(),
                      ),
                    );
                  },
                  child: Text('Kullanıcıları Düzenle'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFB67352), // Buton Rengi
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminCategoriesPage(),
                      ),
                    );
                  },
                  child: Text('Kategorileri Düzenle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


