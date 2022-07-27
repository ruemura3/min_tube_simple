import 'package:flutter/material.dart';
import 'package:min_tube_simple/util/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// お気に入りボタン
class FavoriteButton extends StatefulWidget {
  /// チャンネルID
  final String channelId;

  /// コンストラクタ
  FavoriteButton({required this.channelId});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

/// お気に入りボタンステート
class _FavoriteButtonState extends State<FavoriteButton> {
  /// お気に入りフラグ
  bool _isInFavorites = false;
  /// ボタン活性フラグ
  bool _isEnabled = false;
  /// お気に入りID一覧
  List<String> _favoriteIds = [];
  /// SharedPreferences
  late SharedPreferences _preferences;
  /// ユーザID
  late String _userId;

  @override
  void initState() {
    Future(() async {
      _preferences = await SharedPreferences.getInstance();
      _userId = _preferences.getString('userId')!;
      _getFavoriteIdList();
      final id = _favoriteIds.firstWhere(
        (id) => id == widget.channelId,
        orElse: () => '',
      );
      setState(() {
        if (id != '') {
          _isInFavorites = true;
        }
      });
      _isEnabled = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isEnabled
        ? () {
          setState(() {
            _isEnabled = false;
          });
          _onFavoriteButtonPressed();
        }
        : null,
      icon: _isInFavorites ? Icon(Icons.star) : Icon(Icons.star_border),
    );
  }

  /// 最新のお気に入りリストを取得する
  void _getFavoriteIdList() {
    final favoriteIds = _preferences.getStringList(_userId + 'favoriteIds');
    if (favoriteIds != null) {
      _favoriteIds = favoriteIds;
    }
  }

  /// お気に入りボタン押下時挙動
  Future<void> _onFavoriteButtonPressed() async {
    _getFavoriteIdList();
    if (_isInFavorites) {
      _favoriteIds.remove(widget.channelId);
      _preferences.setStringList(_userId + 'favoriteIds', _favoriteIds);
      if (mounted) {
        setState(() {
          _isInFavorites = false;
          _isEnabled = true;
        });
      }
      Util.showSnackBar(context, 'お気に入りから外しました');
    } else {
      _favoriteIds.add(widget.channelId);
      _preferences.setStringList(_userId + 'favoriteIds', _favoriteIds);
      if (mounted) {
        setState(() {
          _isInFavorites = true;
          _isEnabled = true;
        });
      }
      Util.showSnackBar(context, 'お気に入りに登録しました\nお気に入りはホーム画面の一番上に表示されます');
    }
  }
}