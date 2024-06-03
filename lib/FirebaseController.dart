import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkAdminCredentials(String username, String password) async {
    try {
      DocumentSnapshot adminCredentials = await _firestore.collection('admin')
          .doc('adminCredentials')
          .get();
      Map<String, dynamic> data = adminCredentials.data() as Map<String,
          dynamic>;
      return data['username'] == username && data['password'] == password;
    } catch (e) {
      print(e);
      return false;
    }
  }


  // E-posta ve şifre ile giriş yapma fonksiyonu
  Future<User?> signInWithEmailAndPassword(String email,
      String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Yeni kullanıcı kaydı oluşturma ve Firestore'da bir döküman oluşturma fonksiyonu
  Future<User?> createUserWithEmailAndPassword(String name, String surname,
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        // Firestore'da users koleksiyonunda bir döküman oluştur
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'surname': surname,
          'email': email,
          'addresses': [],
        });
      }
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // 1- createProduct
  Future<void> createProduct({
    required String name,
    required String description,
    required String barcode,
    required String category,
    required String subcategory,
    required List<String> photos,
    required dynamic price,
  }) async {
    await _firestore.collection('products').add({
      'name': name,
      'description': description,
      'barcode': barcode,
      'category': category,
      'subcategory': subcategory,
      'photos': photos,
      'price': price,
    });
  }

  // 2- getProducts
  Future<List<Map<String, dynamic>>> getProducts() async {
    QuerySnapshot querySnapshot = await _firestore.collection('products').get();
    return querySnapshot.docs.map((doc) {
      return {
        'UID': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  // 3- updateProduct
  Future<void> updateProduct({
    required String uid,
    required String name,
    required String description,
    required String category,
    required String subcategory,
    required List<String> photos,
    required dynamic price,
  }) async {
    await _firestore.collection('products').doc(uid).update({
      'name': name,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'photos': photos,
      'price': price,
    });
  }

  // 4- deleteProduct
  Future<void> deleteProduct(String uid) async {
    await _firestore.collection('products').doc(uid).delete();
  }

  String UserUID() {
    return _auth.currentUser!.uid;
  }

  // 5- getUsers
  Future<List<Map<String, dynamic>>> getUsers() async {
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs.map((doc) {
      return {
        'UID': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    try {
      // Kullanıcı dökümanını al
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(
          uid).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<
          String,
          dynamic>?;

      // orders koleksiyonunu al
      QuerySnapshot ordersSnapshot = await _firestore.collection('users').doc(
          uid).collection('orders').get();
      List<Map<String, dynamic>> ordersData = ordersSnapshot.docs.map((
          doc) => doc.data() as Map<String, dynamic>).toList();

      // basket koleksiyonunu al
      QuerySnapshot basketSnapshot = await _firestore.collection('users').doc(
          uid).collection('basket').get();
      List<Map<String, dynamic>> basketData = basketSnapshot.docs.map((
          doc) => doc.data() as Map<String, dynamic>).toList();

      if (userData != null) {
        return {
          'userDetails': userData,
          'orders': ordersData,
          'basket': basketData,
        };
      }
    } catch (e) {
      print(e);
    }
    return null;
  }


  // 6- updateUser
  Future<void> updateUser({
    required String uid,
    required String name,
    required String email,
    required String password,
  }) async {
    // Firestore'da güncelleme
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'email': email,
      // Şifre güncellemesi burada yapılabilir, ancak Firebase Auth için ayrı bir işlem gereklidir.
    });

    // Firebase Auth'da e-posta ve şifre güncellemesi
    User? user = _auth.currentUser;
    if (user != null && user.uid == uid) {
      await user.updateEmail(email);
      await user.updatePassword(password);
    }
  }

  // 7- deleteUser
  Future<void> deleteUser(String uid) async {
    // Firestore'dan kullanıcı dökümanını sil
    await _firestore.collection('users').doc(uid).delete();
    // Auth'dan kullanıcıyı sil
    User? user = await _auth.currentUser;
    if (user != null && user.uid == uid) {
      await user.delete();
    }
  }

  // 8- addToBasket
  Future<void> addToBasket(String productUID, int count) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid)
          .collection('basket').doc(productUID)
          .set({
        'productUID': productUID,
        'count': count,
      });
    }
  }

  // 9- getBasket
  Future<List<Map<String, dynamic>>> getBasket() async {
    User? user = _auth.currentUser;
    if (user == null) return [];
    QuerySnapshot querySnapshot = await _firestore.collection('users').doc(
        user.uid).collection('basket').get();
    return querySnapshot.docs.map((doc) {
      return {
        'basketUID': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  // 10- removeFromBasket
  Future<void> removeFromBasket(String basketUID) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid)
          .collection('basket')
          .doc(basketUID)
          .delete();
    }
  }

  // 11- changeCountOnBasket
  Future<void> changeCountOnBasket(String basketUID, int change) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference docRef = _firestore.collection('users')
          .doc(user.uid)
          .collection('basket')
          .doc(basketUID);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception("Document does not exist!");
        }
        int currentCount = snapshot.get('count');
        transaction.update(docRef, {'count': currentCount + change});
      });
    }
  }

  // 12- createOrder
  Future<void> createOrder({
    required List<Map<String, dynamic>> basket,
    required String userUID,
    required dynamic totalPrice,
    required String address,
  }) async {
    // users koleksiyonundaki dökümana sipariş ekleyin
    DocumentReference orderRef = await _firestore.collection('orders').add({
      'basket': basket,
      'userUID': userUID,
      'totalPrice': totalPrice,
      'address': address,
      'status': 0,
      'cargoLink': "",
      'date': Timestamp.now(),
    });

    // Sipariş bilgisini kullanıcının dökümanına da ekleyin
    await _firestore.collection('users').doc(userUID).collection('orders').doc(
        orderRef.id).set({
      'orderID': orderRef.id,
      'basket': basket,
      'status': 0,
      'totalPrice': totalPrice,
      'address': address,
      'cargoLink': "",
      'date': Timestamp.now(),
    });
  }

  // 5- getUsers
  Future<List<Map<String, dynamic>>> getOrders() async {
    QuerySnapshot querySnapshot = await _firestore.collection('orders').get();
    return querySnapshot.docs.map((doc) {
      return {
        'UID': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getOrder(String uid) async {
    try {
      DocumentSnapshot docSnapshot = await _firestore.collection('orders').doc(
          uid).get();
      if (docSnapshot.exists) {
        return {
          'UID': uid,
          ...docSnapshot.data() as Map<String, dynamic>,
        };
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> updateOrderStatus(String uid, String userUID, int status) async {
    try {
      await _firestore.collection('orders').doc(uid).update({
        'status': status,
      });
      await _firestore.collection('users').doc(userUID)
          .collection('orders')
          .doc(uid)
          .update({
        'status': status,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateOrderCargoLink(String uid, String userUID,
      String cargoLink) async {
    try {
      await _firestore.collection('orders').doc(uid).update({
        'cargoLink': cargoLink,
      });
      await _firestore.collection('users').doc(userUID)
          .collection('orders')
          .doc(uid)
          .update({
        'cargoLink': cargoLink,
      });
    } catch (e) {
      print(e);
    }
  }

  // 13- getProduct
  Future<Map<String, dynamic>?> getProduct(String uid) async {
    DocumentSnapshot docSnapshot = await _firestore.collection('products').doc(
        uid).get();
    if (docSnapshot.exists) {
      return {
        'UID': uid,
        ...docSnapshot.data() as Map<String, dynamic>,
      };
    }
    return null;
  }

  Future<List<dynamic>> getFilteredProducts({String? category, String? subCategory, double? minPrice, double? maxPrice}) async {
    Query query = _firestore.collection('products');

    // Minimum fiyata göre filtrele
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }

    // Maksimum fiyata göre filtrele
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    // Kategoriye göre filtrele
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    // Alt kategoriye göre filtrele
    if (subCategory != null && subCategory.isNotEmpty) {
      query = query.where('subcategory', isEqualTo: subCategory);
    }

    // Sorguyu çalıştır ve sonuçları getir
    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> createCategory(String name, List<String> subCategories) async {
    DocumentReference categoryRef = await _firestore.collection('categories')
        .add({'name': name});
    for (String subCategoryName in subCategories) {
      await categoryRef.collection('subCategories').add(
          {'name': subCategoryName});
    }
  }

  Future<void> editCategory(String uid, String name) async {
    await _firestore.collection('categories').doc(uid).update({'name': name});
  }

  Future<void> editSubCategory(String catUID, String subCatUID,
      String name) async {
    await _firestore.collection('categories').doc(catUID).collection(
        'subCategories').doc(subCatUID).update({'name': name});
  }

  Future<List<String>> addSubCategories(String uid, List<String> newSubCategories) async {
    DocumentReference categoryRef = _firestore.collection('categories').doc(uid);
    List<String> subCategoryIds = [];

    for (String subCategoryName in newSubCategories) {
      DocumentReference docRef = await categoryRef.collection('subCategories').add({'name': subCategoryName});
      subCategoryIds.add(docRef.id); // Eklenen dökümanın ID'sini listeye ekle
    }

    return subCategoryIds; // Eklenen tüm alt kategorilerin ID'lerini içeren listeyi döndür
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    QuerySnapshot categoriesSnapshot = await _firestore.collection('categories')
        .get();
    List<Map<String, dynamic>> categories = [];
    for (var doc in categoriesSnapshot.docs) {
      DocumentSnapshot categoryDoc = doc;
      List<Map<String, dynamic>> subCategories = [];
      QuerySnapshot subCategoriesSnapshot = await categoryDoc.reference
          .collection('subCategories').get();
      subCategories = subCategoriesSnapshot.docs.map((subDoc) =>
      {
        'uid': subDoc.id,
        ...subDoc.data() as Map<String, dynamic>
      }).toList();
      categories.add({
        'uid': doc.id,
        ...doc.data() as Map<String, dynamic>,
        'subCategories': subCategories,
      });
    }
    return categories;
  }

  Future<void> deleteCategory(String uid) async {
    await _firestore.collection('categories').doc(uid).delete();
  }

  Future<void> deleteSubCategory(String catUID, String subCatUID) async {
    await _firestore.collection('categories').doc(catUID).collection(
        'subCategories').doc(subCatUID).delete();
  }
}
