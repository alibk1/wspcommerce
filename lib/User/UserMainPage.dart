import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemChrome için gerekli
import 'package:wspcommerce/FirebaseController.dart'; // FirebaseController sınıfınızı buraya dahil edin

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseController _firebaseController = FirebaseController();
  TextEditingController _minPriceController = TextEditingController();
  TextEditingController _maxPriceController = TextEditingController();
  String category = '';
  String subcategory = '';
  List<dynamic> products = [];
  List<dynamic> categories = [];
  List<dynamic> currentSubCategories = [];
  Map<String, int> basketCounts = {
  }; // Ürün UID'sine göre sepet sayılarını tutar

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadCategories();
    loadBasket();
  }

  Future<void> loadProducts() async {
    products = await _firebaseController.getProducts();
    setState(() {});
  }

  Future<void> loadCategories() async {
    categories = await _firebaseController.getCategories();
    setState(() {});
  }

  Future<void> loadBasket() async {
    var basket = await _firebaseController.getBasket();
    for (var product in basket) {
      basketCounts.addAll({product["productUID"]: product["count"]});
    }
    setState(() {});
  }

  Future<void> addToBasket(String productUid) async {
    await _firebaseController.addToBasket(productUid, 1);
    basketCounts[productUid] = (basketCounts[productUid] ?? 0) + 1;
    setState(() {});
  }

  Future<void> changeCountOnBasket(String productUid, int change) async {
    await _firebaseController.changeCountOnBasket(productUid, change);
    basketCounts[productUid] = (basketCounts[productUid] ?? 0) + change;
    setState(() {});
  }

  Future<void> removeFromBasket(String productUid) async {
    await _firebaseController.removeFromBasket(productUid);
    basketCounts[productUid] = (basketCounts[productUid] ?? 0) - 1;
    setState(() {});
  }
  // Mevcut loadProducts fonksiyonunu değiştirin veya yeni bir fonksiyon ekleyin
  Future<void> filterProducts({String? category, String? subCategory, double? minPrice, double? maxPrice}) async {
    // Ürünlerin filtreleneceği fonksiyonu çağırın
    products = await _firebaseController.getFilteredProducts(
      category: category,
      subCategory: subCategory,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    setState(() {});
  }

// Filtreleri onayla butonunun onPressed metodu
  void onConfirmFilters() {
    filterProducts(
      category: category.isNotEmpty ? category : null,
      subCategory: subcategory.isNotEmpty ? subcategory : null,
      minPrice: double.tryParse(_minPriceController.text),
      maxPrice: double.tryParse(_maxPriceController.text),
    );
  }

// Filtreleri sıfırla butonunun onPressed metodu
  void onResetFilters() {
    _minPriceController.clear();
    _maxPriceController.clear();
    category = '';
    subcategory = '';
    loadProducts();
  }


  Widget buildProductCard(dynamic product) {
    bool isInBasket = basketCounts[product['UID']] != null &&
        basketCounts[product['UID']]! > 0;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25), // Yuvarlak köşe
          topRight: Radius.circular(25), // Yuvarlak köşe
          bottomLeft: Radius.circular(25), // Sivri köşe
          bottomRight: Radius.circular(25),
        ),
        side: BorderSide(
          width: 3,
          color: Color(
              int.parse("#D5FFE4".substring(1, 7), radix: 16) + 0xFF000000),
        ),
      ),
      color: isInBasket ? Color(
          int.parse("#6F61C0".substring(1, 7), radix: 16) + 0xFF000000) : Color(
          int.parse("#8BE8E5".substring(1, 7), radix: 16) + 0xFF000000),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), // Yuvarlak köşe
                topRight: Radius.circular(25), // Yuvarlak köşe
                bottomLeft: Radius.circular(15), // Yuvarlak köşe
                bottomRight: Radius.circular(15), // Yuvarlak köşe
              ),
              child: PageView(
                children: product['photos'].map<Widget>((photoUrl) {
                  return Image.network(photoUrl, fit: BoxFit.cover);
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 4,),
          Text(product['name'], style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isInBasket
                  ? Color(
                  int.parse("#8BE8E5".substring(1, 7), radix: 16) + 0xFF000000)
                  : Color(int.parse("#6F61C0".substring(1, 7), radix: 16) +
                  0xFF000000)),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("   ${product['price']} TL", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isInBasket ? Color(
                      int.parse("#D5FFE4".substring(1, 7), radix: 16) +
                          0xFF000000) : Color(
                      int.parse("#6F61C0".substring(1, 7), radix: 16) +
                          0xFF000000)),),
              IconButton(
                icon: isInBasket
                    ? Icon(Icons.add_shopping_cart_sharp, color: Color(
                    int.parse("#D5FFE4".substring(1, 7), radix: 16) +
                        0xFF000000),)
                    : Icon(Icons.shopping_cart, color: Color(
                    int.parse("#D5FFE4".substring(1, 7), radix: 16) +
                        0xFF000000),),
                onPressed: () =>
                isInBasket
                    ? changeCountOnBasket(product["UID"], 1)
                    : addToBasket(product['UID']),
              ),
            ],
          ),
          if (isInBasket) buildBasketControl(product['UID']),
        ],
      ),
    );
  }

  Widget buildBasketControl(String productUid) {
    int count = basketCounts[productUid]!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.remove, color: Colors.white,),
          onPressed: count > 1
              ? () => changeCountOnBasket(productUid, -1)
              : () => removeFromBasket(productUid),
        ),
        Text("$count",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        IconButton(
          icon: Icon(Icons.add, color: Colors.white,),
          onPressed: () => changeCountOnBasket(productUid, 1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Color(
            int.parse("#6F61C0".substring(1, 7), radix: 16) + 0xFF000000),
        centerTitle: true,
      ),
      drawer: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0), // Yuvarlak köşe
            topRight: Radius.circular(40), // Yuvarlak köşe
            bottomLeft: Radius.circular(0), // Sivri köşe
            bottomRight: Radius.circular(40),
          ),
          side: BorderSide(
            width: 1,
            color: Color(
                int.parse("#6F61C0".substring(1, 7), radix: 16) + 0xFF000000),
          ),
        ),
        backgroundColor: Color(
            int.parse("#6F61C0".substring(1, 7), radix: 16) + 0xFF000000),
        shadowColor: Color(
            int.parse("#FFFFFF".substring(1, 7), radix: 16) + 0xFF000000),
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
          [
            Text("Filtrele", style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(int.parse("#FFFFFF".substring(1, 7), radix: 16) +
                    0xFF000000)),),
            SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Card(
                    color: Color(int.parse("#A084E8".substring(1, 7), radix: 16) + 0xFF000000),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 3,),
                        Text("Kategori: ", style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(int.parse("#8BE8E5".substring(1, 7), radix: 16) +
                                0xFF000000)),),
                        DropdownButton<String>(
                          style: TextStyle(color: Colors.white),
                          dropdownColor: Color(int.parse("#A084E8".substring(1, 7), radix: 16) + 0xFF000000),
                          iconEnabledColor: Color(int.parse("#8BE8E5".substring(1, 7), radix: 16) + 0xFF000000),
                          iconDisabledColor: Color(int.parse("#8BE8E5".substring(1, 7), radix: 16) + 0xFF000000),
                          value: category.isNotEmpty ? category : null,
                          onChanged: (String? newValue) {
                            setState(() {
                              category = newValue!;
                              currentSubCategories =
                              categories.firstWhere((category) => category['uid'] ==
                                  newValue)['subCategories'];
                              subcategory = "";
                              print(category);
                            });
                          },
                          items: categories.map<DropdownMenuItem<String>>((dynamic value) {
                            return DropdownMenuItem<String>(
                              value: value["uid"],
                              child: Text(value["name"], textAlign: TextAlign.center,),
                            );
                          }).toList(),
                        ),
                        SizedBox(width: 1,),

                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Card(
                    color: Color(int.parse("#A084E8".substring(1, 7), radix: 16) + 0xFF000000),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 3,),
                        Text("Alt Kategori: ", style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(int.parse("#8BE8E5".substring(1, 7), radix: 16) +
                                0xFF000000)),),
                        DropdownButton<String>(
                          style: TextStyle(color: Colors.white),
                          dropdownColor: Color(int.parse("#A084E8".substring(1, 7), radix: 16) + 0xFF000000),
                          iconEnabledColor: Color(int.parse("#8BE8E5".substring(1, 7), radix: 16) + 0xFF000000),
                          iconDisabledColor: Color(int.parse("#8BE8E5".substring(1, 7), radix: 16) + 0xFF000000),
                          value: subcategory.isNotEmpty ? subcategory : null,
                          onChanged: (String? newValue) {
                            setState(() {
                              subcategory = newValue!;
                              print(subcategory);
                            });
                          },
                          items: currentSubCategories.map<DropdownMenuItem<String>>((dynamic value) {
                            return DropdownMenuItem<String>(
                              value: value["uid"],
                              child: Text(value["name"], textAlign: TextAlign.center,),
                            );
                          }).toList(),
                        ),
                        SizedBox(width: 1,),

                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Card(
                    color: Color(int.parse("#A084E8".substring(1, 7), radix: 16) + 0xFF000000),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 3,),
                        Text("Fiyat Aralığı: ", style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(int.parse("#8BE8E5".substring(1, 7), radix: 16) +
                                0xFF000000)),),
                        TextFormField(
                          controller: _minPriceController,
                          decoration: InputDecoration(labelText: 'Min'),
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          controller: _maxPriceController,
                          decoration: InputDecoration(labelText: 'Max'),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(width: 1,),

                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(int.parse("#A084E8".substring(1, 7), radix: 16) + 0xFF000000)),
                onPressed: onConfirmFilters,
                child: Text("Filtreleri Onayla", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
            ),
            SizedBox(height: 10,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(int.parse("#A084E8".substring(1, 7), radix: 16) + 0xFF000000)),
                onPressed: onResetFilters,
                child: Text("Filtreleri Sıfırla", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
            ),
          ],
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (1 / 1.6),
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return buildProductCard(products[index]);
        },
      ),
      backgroundColor: Color(
          int.parse("#A084E8".substring(1, 7), radix: 16) + 0xFF000000),

    );
  }
}
