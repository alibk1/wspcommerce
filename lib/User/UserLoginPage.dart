import 'package:flutter/material.dart';

class UserLoginPage extends StatefulWidget {
  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _signInKey = GlobalKey<FormState>();
  final _signUpKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false; // Kullanıcı giriş yapma veya kayıt olma ekranında mı kontrolü

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Kayıt Ol' : 'Giriş Yap'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _isSignUp ? _signUpKey : _signInKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'İsim'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir isim giriniz';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _surnameController,
                    decoration: InputDecoration(labelText: 'Soyisim'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir soyisim giriniz';
                      }
                      return null;
                    },
                  ),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'E-posta'),
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Geçerli bir e-posta giriniz';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Şifre'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                if (_isSignUp)
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Şifre Tekrarı'),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Şifreler uyuşmuyor';
                      }
                      return null;
                    },
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlue[200], // button color
                  ),
                  onPressed: () {
                    if (_isSignUp) {
                      if (_signUpKey.currentState!.validate()) {
                        // TODO: Kayıt olma işlemleri
                      }
                    } else {
                      if (_signInKey.currentState!.validate()) {
                        // TODO: Giriş yapma işlemleri
                      }
                    }
                  },
                  child: Text(_isSignUp ? 'Kaydol' : 'Giriş Yap'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp; // Kullanıcı giriş yapma/kayıt olma ekranı arasında geçiş yap
                    });
                  },
                  child: Text(_isSignUp ? 'Zaten bir hesabınız var mı? Giriş yapın' : 'Hesabınız yok mu? Kaydolun'),
                ),
                // TODO: Sosyal medya ile giriş yapma butonları
              ],
            ),
          ),
        ),
      ),
    );
  }
}
