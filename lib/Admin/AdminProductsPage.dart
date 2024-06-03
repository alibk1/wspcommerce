import 'package:flutter/material.dart';
import '../FirebaseController.dart'; // FirebaseController sınıfınızın olduğu dosyayı import edin
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AdminProductsPage extends StatefulWidget {
  @override
  _AdminProductsPageState createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final FirebaseController _firebaseController = FirebaseController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürünleri Düzenle'),
        backgroundColor: Color(0xFF8CB9BD),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _firebaseController.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu.'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var product = snapshot.data![index];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFFB67352),
                    backgroundColor: Color(0xFFECB159), // Text color
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProductPage(uid: product["UID"]),
                      ),
                    );                  },
                  child: Text('${product['name']} - ${product['barcode']}'),
                );
              },
            );
          } else {
            return Center(child: Text('Ürün bulunamadı.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductPage(),
            ),
          );
        },
        backgroundColor: Color(0xFFB67352),
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  String barcode = '';
  String category = '';
  String subcategory = '';
  double price = 0.0;
  List<File> _images = [];
  List<String> _uploadedFileURLs = [];

  List<dynamic> categories = [];
  List<dynamic> currentSubCategories = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> uploadFile(File file) async {
    String fileName = 'products/${DateTime.now()}.png';
    try {
      await FirebaseStorage.instance.ref(fileName).putFile(file);
      String downloadURL = await FirebaseStorage.instance.ref(fileName).getDownloadURL();
      _uploadedFileURLs.add(downloadURL);
    } catch (e) {
      print(e);
    }
  }

  Future<void> pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _images = selectedImages.map((image) => File(image.path)).toList();
      });
    }
  }

  Future<void> createProduct() async {
    for (File image in _images) {
      await uploadFile(image);
    }
    // FirebaseController kullanarak ürünü oluştur
    await FirebaseController().createProduct(
      name: name,
      description: description,
      barcode: barcode,
      category: category,
      subcategory: subcategory,
      photos: _uploadedFileURLs,
      price: price,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Kaydedildi'),
      duration: Duration(seconds: 8),
    ));
    // Formu ve yüklenen resim listesini temizle
    _formKey.currentState?.reset();
    setState(() {
      _images = [];
      _uploadedFileURLs = [];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async
  {
    categories = await FirebaseController().getCategories();
    setState(()  {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Ekle'),
        backgroundColor: Color(0xFF8CB9BD),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 10,),
              TextFormField(
                decoration: InputDecoration(labelText: 'Ürün İsmi',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(150.0),
                    borderSide: BorderSide(color: Color(
                        int.parse("#04C4D9".substring(1, 7), radix: 16) +
                            0xFF000000), width: 50,),
                  ),),
                onSaved: (value) {
                  name = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir değer giriniz';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10,),
              TextFormField(
                decoration: InputDecoration(labelText: 'Açıklama',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(150.0),
                    borderSide: BorderSide(color: Color(
                        int.parse("#04C4D9".substring(1, 7), radix: 16) +
                            0xFF000000), width: 50,),
                  ),),
                onSaved: (value) {
                  description = value!;
                },
              ),
              SizedBox(height: 10,),
              TextFormField(
                decoration: InputDecoration(labelText: 'Barkod',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(150.0),
                    borderSide: BorderSide(color: Color(
                        int.parse("#04C4D9".substring(1, 7), radix: 16) +
                            0xFF000000), width: 50,),
                  ),),
                onSaved: (value) {
                  barcode = value!;
                },
              ),
              SizedBox(height: 10,),
              DropdownButton<String>(
                hint: Text("Kategori: "),
                disabledHint: Text("Kategori: "),
                value: category.isNotEmpty ? category : null,
                onChanged: (String? newValue) {
                  setState(() {
                    category = newValue!;
                    currentSubCategories = categories.firstWhere((category) => category['uid'] == newValue)['subCategories'];
                    subcategory = "";
                    print(category);
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((dynamic value) {
                  return DropdownMenuItem<String>(
                    value: value["uid"],
                    child: Text(value["name"]),
                  );
                }).toList(),
              ),
              SizedBox(height: 10,),
              DropdownButton<String>(
                hint: Text("Alt Kategori: "),
                disabledHint: Text("Alt Kategori: "),
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
                    child: Text(value["name"]),
                  );
                }).toList(),
              ),
              SizedBox(height: 10,),
              TextFormField(
                decoration: InputDecoration(labelText: 'Fiyat',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(150.0),
                    borderSide: BorderSide(color: Color(
                        int.parse("#04C4D9".substring(1, 7), radix: 16) +
                            0xFF000000), width: 50,),
                  ),),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  price = double.tryParse(value!) ?? 0.0;
                },
              ),
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: pickImages,
                child: Text('Fotoğrafları Seç'),
              ),
              SizedBox(height: 10,),
              Wrap(
                children: _images.map((file) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(file, width: 100, height: 100), // Resim önizlemesi
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red), // "X" butonu
                        onPressed: () {
                          setState(() {
                            _images.remove(file); // Resmi listeden kaldır
                          });
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    createProduct();
                  }
                },
                child: Text('Ürün Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class EditProductPage extends StatefulWidget {
  final String uid; // Düzenlenecek ürünün UID'si

  EditProductPage({Key? key, required this.uid}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController= TextEditingController();
  TextEditingController descController= TextEditingController();
  TextEditingController barcodeController= TextEditingController();
  TextEditingController priceController = TextEditingController();
  String name = '';
  String description = '';
  String barcode = '';
  String category = '';
  String subcategory = '';
  double price = 0.0;

  List<dynamic> categories = [];
  List<dynamic> currentSubCategories = [];
  List<String> _imageURLs = []; // Sunucudan gelen mevcut resimlerin URL'leri
  List<File> _newImages = []; // Kullanıcının seçtiği yeni resimler
  List<String> _deletedImageURLs = []; // Silinecek resimlerin URL'leri

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadProductDetails();
  }

  Future<void> loadProductDetails() async {
    var productDetails = await FirebaseController().getProduct(widget.uid);
    categories = await FirebaseController().getCategories();
    if (productDetails != null) {
      setState(() {
        nameController.text = productDetails['name'];
        descController.text = productDetails['description'];
        barcodeController.text = productDetails['barcode'];
        category = productDetails['category'];
        subcategory = productDetails['subcategory'];
        currentSubCategories = categories.firstWhere((cat) => cat['uid'] == category)['subCategories'];
        priceController.text = productDetails['price'].toString();
        _imageURLs = List<String>.from(productDetails['photos']);
      });
    }
  }

  Future<void> pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _newImages.addAll(selectedImages.map((image) => File(image.path)).toList());
      });
    }
  }

  Future<void> uploadFile(File file) async {
    String fileName = 'products/${DateTime.now()}.png';
    try {
      await FirebaseStorage.instance.ref(fileName).putFile(file);
      String downloadURL = await FirebaseStorage.instance.ref(fileName).getDownloadURL();
      _imageURLs.add(downloadURL);
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteImageFromStorage(String url) async {
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateProduct() async {
    // Yeni resimleri yükle
    for (File newImage in _newImages) {
      await uploadFile(newImage);
    }

    // Silinecek resimleri Storage'dan sil
    for (String deletedImageUrl in _deletedImageURLs) {
      await deleteImageFromStorage(deletedImageUrl);
    }

    // FirebaseController kullanarak ürünü güncelle
    await FirebaseController().updateProduct(
      uid: widget.uid,
      name: nameController.text,
      description: descController.text,
      category: category,
      subcategory: subcategory,
      photos: _imageURLs,
      price: double.parse(priceController.text),
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ürün güncellendi'),
      duration: Duration(seconds: 8),
    ));
  }

  Widget buildImageList() {
    // Mevcut ve yeni resimlerin birleşimi
    List<Widget> widgets = [];
    _imageURLs.forEach((url) {
      widgets.add(Stack(
        alignment: Alignment.topRight,
        children: [
          Image.network(url, width: 100, height: 100),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                _deletedImageURLs.add(url);
                _imageURLs.remove(url);
              });
            },
          ),
        ],
      ));
    });
    _newImages.forEach((file) {
      widgets.add(Stack(
        alignment: Alignment.topRight,
        children: [
          Image.file(file, width: 100, height: 100),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                _newImages.remove(file);
              });
            },
          ),
        ],
      ));
    });
    return Wrap(
      children: widgets,
      spacing: 8.0, // Resimler arası boşluk
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürünü Düzenle'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 10,),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Ürün Adı',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(150.0),
                    borderSide: BorderSide(color: Color(
                        int.parse("#04C4D9".substring(1, 7), radix: 16) +
                            0xFF000000), width: 50,),
                  ),),
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Ürün Açıklaması',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(150.0),
                    borderSide: BorderSide(color: Color(
                        int.parse("#04C4D9".substring(1, 7), radix: 16) +
                            0xFF000000), width: 50,),
                  ),),
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: barcodeController,
                decoration: InputDecoration(labelText: 'Barkod',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(150.0),
                    borderSide: BorderSide(color: Color(
                        int.parse("#04C4D9".substring(1, 7), radix: 16) +
                            0xFF000000), width: 50,),
                  ),),
              ),
              SizedBox(height: 10,),
              DropdownButton<String>(
                hint: Text("Alt Kategori: "),
                disabledHint: Text("Alt Kategori: "),
                value: category.isNotEmpty ? category : null,
                onChanged: (String? newValue) {
                  setState(() {
                    category = newValue!;
                    currentSubCategories = categories.firstWhere((cat) => cat['uid'] == newValue)['subCategories'];
                    subcategory = "";
                    print(category);
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((dynamic value) {
                  return DropdownMenuItem<String>(
                    value: value["uid"],
                    child: Text(value["name"]),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                hint: Text("Alt Kategori: "),
                disabledHint: Text("Alt Kategori: "),
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
                    child: Text(value["name"]),
                  );
                }).toList(),
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Ürün Fiyatı',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(150.0),
                    borderSide: BorderSide(color: Color(
                        int.parse("#04C4D9".substring(1, 7), radix: 16) +
                            0xFF000000), width: 50,),
                  ),),
              ),
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () => pickImages(),
                child: Text('Resim Seç'),
              ),
              SizedBox(height: 10,),
              buildImageList(),
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () => updateProduct(),
                child: Text('Ürünü Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}