import 'package:flutter/material.dart';
import '../FirebaseController.dart';

class AdminCategoriesPage extends StatefulWidget {
  @override
  _AdminCategoriesPageState createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    var categories = await FirebaseController().getCategories();
    setState(() {
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategoriler'),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (BuildContext context, int index) {
          return ElevatedButton(
            child: Text(_categories[index]['name']),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminCategoryDetailsPage(category: _categories[index])),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminAddCategoryPage()),
          );        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AdminCategoryDetailsPage extends StatefulWidget {
  final Map<String, dynamic> category;

  AdminCategoryDetailsPage({Key? key, required this.category}) : super(key: key);

  @override
  _AdminCategoryDetailsPageState createState() => _AdminCategoryDetailsPageState();
}

class _AdminCategoryDetailsPageState extends State<AdminCategoryDetailsPage> {
  TextEditingController _nameController = TextEditingController();
  FirebaseController _firebaseController = FirebaseController();
  List<dynamic> subs = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.category['name'];
    subs = widget.category['subCategories'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori Detayları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Kategori Adı'),
            ),
            for(int i = 0; i < subs.length; i ++)...[
              Card(
                color: Colors.blueGrey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 20,),
                    Expanded(child: Text(subs[i]["name"], style: TextStyle(color: Colors.white),)),
                    IconButton(
                      onPressed: () {
                        _editSubCategory(context, i, subs[i]["name"]);
                      },
                      icon: Icon(Icons.edit), color: Colors.white,),
                    IconButton(
                        onPressed: () {
                          _deleteSubCategory(context, i);
                        },
                        icon: Icon(Icons.delete, color: Colors.red,)),
                  ],
                ),
              ),
              SizedBox(height: 10,),
            ],
            IconButton(
                onPressed: () {
                  _createSubCategory(context);
                },
                icon: Icon(Icons.add_circle, color: Colors.black,)),
            ElevatedButton(
              onPressed: () {
                _firebaseController.editCategory(widget.category["uid"], _nameController.text);
              },
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _createSubCategory(BuildContext context) {

    TextEditingController subNameController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Alt Kategori Oluştur'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: subNameController,
                decoration: InputDecoration(labelText: 'İsim'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                List<String> uids = await _firebaseController.addSubCategories(widget.category["uid"], [subNameController.text]);
                setState(()  {
                  subs.add({"name" : subNameController.text , "uid" : uids.first });
                });
                Navigator.pop(context);
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _editSubCategory(BuildContext context, int index,String name) {
    TextEditingController subNameController =
    TextEditingController();

    subNameController.text = name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Alt Kategori Oluştur'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: subNameController,
                decoration: InputDecoration(labelText: 'İsim'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                _firebaseController.editSubCategory(widget.category["uid"], widget.category["subCategories"][index]["uid"],subNameController.text);
                setState(()  {
                  subs[index]["name"] = subNameController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSubCategory(BuildContext context, int index) {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Alt Kategoriyi Silmek İstediğinizden Emin Misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () async{
                setState(() {
                  subs.removeAt(index);
                });
                await _firebaseController.deleteSubCategory(widget.category["uid"], widget.category["subCategories"][index]["uid"]);
                Navigator.pop(context);
              },
              child: Text('Evet'),
            ),
          ],
        );
      },
    );
  }

}

class AdminAddCategoryPage extends StatefulWidget {

  @override
  _AdminAddCategoryPageState createState() => _AdminAddCategoryPageState();
}

class _AdminAddCategoryPageState extends State<AdminAddCategoryPage> {
  TextEditingController _nameController = TextEditingController();
  List<String> subs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori Detayları'),
        backgroundColor: Color(0xFF8CB9BD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Kategori Adı'),
            ),
            for(int i = 0; i < subs.length; i ++)...[
              Card(
                color: Colors.blueGrey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 20,),
                    Expanded(child: Text(subs[i], style: TextStyle(color: Colors.white),)),
                    IconButton(
                        onPressed: () {
                          _editSubCategory(context, i, subs[i]);
                        },
                        icon: Icon(Icons.edit), color: Colors.white,),
                    IconButton(
                        onPressed: () {
                          _deleteSubCategory(context, i);
                        },
                        icon: Icon(Icons.delete, color: Colors.red,)),
                  ],
                ),
              ),
              SizedBox(height: 10,),
            ],
            IconButton(
                onPressed: () {
                  _createSubCategory(context);
                },
                icon: Icon(Icons.add_circle, color: Colors.black,)),
            ElevatedButton(
              onPressed: () {
                FirebaseController().createCategory(_nameController.text, subs);
              },
              child: Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _createSubCategory(BuildContext context) {

    TextEditingController subNameController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Alt Kategori Oluştur'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: subNameController,
                decoration: InputDecoration(labelText: 'İsim'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: ()  {
                setState(()  {
                  subs.add(subNameController.text);
                });
                Navigator.pop(context);
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _editSubCategory(BuildContext context, int index,String name) {
    TextEditingController subNameController =
    TextEditingController();

    subNameController.text = name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Alt Kategori Oluştur'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: subNameController,
                decoration: InputDecoration(labelText: 'İsim'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: ()  {
                setState(()  {
                  subs[index] = subNameController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSubCategory(BuildContext context, int index) {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Alt Kategoriyi Silmek İstediğinizden Emin Misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  subs.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Evet'),
            ),
          ],
        );
      },
    );
  }
}