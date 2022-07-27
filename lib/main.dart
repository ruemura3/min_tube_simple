import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:min_tube_simple/util/api_util.dart';
import 'package:min_tube_simple/screens/home_screen.dart';
import 'package:min_tube_simple/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp]
  ).then((_) {
    runApp(new MinTube());
  });
}

/// MinTubeクラス
class MinTube extends StatefulWidget {
  @override
  _MinTubeState createState() => _MinTubeState();
}

/// MinTubeステート
class _MinTubeState extends State<MinTube> {
  /// APIインスタンス
  ApiUtil _api = ApiUtil.instance;
  /// ログイン中ユーザ
  GoogleSignInAccount? _currentUser;
  /// ログイン完了フラグ
  bool _isLaunched = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final user = await _api.user;
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLaunched = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.cyan,
          onPrimary: Colors.white,
          secondary: Colors.cyan,
          onSecondary: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
          foregroundColor: Colors.black,
        )
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.cyan,
          onPrimary: Colors.white,
          secondary: Colors.cyan,
          onSecondary: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
        )
      ),
      themeMode: ThemeMode.system,
      home: _home(),
    );
  }

  /// ホーム画面
  Widget _home() {
    if (_isLaunched) {
      if (_currentUser != null) {
        return HomeScreen();
      }
      return LoginScreen();
    }
    return Center(child: CircularProgressIndicator(),);
  }
}
