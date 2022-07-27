import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:min_tube_simple/util/api_util.dart';
import 'package:min_tube_simple/screens/home_screen.dart';

/// ログイン画面
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

/// ログイン画面ステート
class _LoginScreenState extends State<LoginScreen> {
  /// APIインスタンス
  ApiUtil _api = ApiUtil.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loginScreenBody(),
    );
  }

  /// ログイン画面ボディ
  Widget _loginScreenBody() {
    final double buttonHeight = 56;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 120, right: 32, bottom: 48),
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                ? 'assets/images/logo_dark.png'
                : 'assets/images/logo_light.png',
            ),
          ),
          ElevatedButton.icon(
            icon: FaIcon(FontAwesomeIcons.google,),
            label: Text(
              'Sign in with Google',
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () async {
              final user = await _api.login();
              if (user != null) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(),
                  ),
                  (route) => false
                );
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}