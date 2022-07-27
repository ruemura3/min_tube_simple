import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:min_tube_simple/util/api_util.dart';
import 'package:min_tube_simple/screens/home_screen.dart';
import 'package:min_tube_simple/screens/my_page_screen.dart';
import 'package:min_tube_simple/util/util.dart';

/// オリジナルアップバー
class OriginalAppBar extends StatefulWidget with PreferredSizeWidget {
  /// アップバータイトル
  final String? title;
  /// 検索バーかどうか
  final bool isSearch;
  /// プロフィールボタンを表示すべきかどうか
  final bool shouldShowProfileButton;
  /// タブバー
  final TabBar? tabBar;
  /// 戻るボタンを表示すべきかどうか
  final bool shouldShowBackButton;

  /// コンストラクタ
  OriginalAppBar({
    this.title,
    this.isSearch = false,
    this.shouldShowProfileButton = true,
    this.tabBar,
    this.shouldShowBackButton = true,
  });

  @override
  Size get preferredSize {
    if (tabBar != null) {
      return Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
    }
    return Size.fromHeight(kToolbarHeight);
  }

  @override
  _OriginalAppBarState createState() => _OriginalAppBarState();
}

/// オリジナルアップバーステート
class _OriginalAppBarState extends State<OriginalAppBar> {
  /// APIインスタンス
  ApiUtil _api = ApiUtil.instance;
  /// ログイン中ユーザ
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    Future(() async {
      final user = await _api.user;
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: widget.shouldShowBackButton,
      elevation: 0,
      title: _appBarTitle(),
      actions: _appBarActions(),
      bottom: widget.tabBar,
    );
  }

  /// アップバータイトル
  Widget _appBarTitle() {
    if (widget.title != null) {
      if (widget.isSearch) {
        return InkWell(
          onTap: () {
            Util.showSearchDialog(context, query: widget.title!);
          },
          child: Text(
            widget.title!,
            style: TextStyle(
              fontSize: 18,
            ),
          )
        );
      }
      return Text(
        widget.title!,
        style: TextStyle(
          fontSize: 18,
        ),
      );
    }
    return InkWell(
      onTap: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ),
        (route) => false
      ),
      child: Image.asset(
        Theme.of(context).brightness == Brightness.dark
          ? 'assets/images/logo_dark.png'
          : 'assets/images/logo_light.png',
          width: 120,
      ),
    );
  }

  /// アップバーアクション
  List<Widget> _appBarActions() {
    if (widget.shouldShowProfileButton) {
      if (_currentUser != null) {
        return [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyPageScreen(),
              ),
            ),
            child: _currentUser!.photoUrl != null
              ? Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(_currentUser!.photoUrl!)
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  child: Text(_currentUser!.displayName!.substring(0, 1)),
                ),
              )
          ),
          SizedBox(width: 8,),
        ];
      }
      Future(() async {
        final user = await _api.user;
        if (mounted) {
          setState(() {
            _currentUser = user;
          });
        }
      });
    }
    return [];
  }
}