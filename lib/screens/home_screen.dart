import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube_simple/util/api_util.dart';
import 'package:min_tube_simple/screens/channel_screen/channel_screen.dart';
import 'package:min_tube_simple/widgets/floating_search_button.dart';
import 'package:min_tube_simple/widgets/favorite_button.dart';
import 'package:min_tube_simple/widgets/original_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ホーム画面
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// ホーム画面ステート
class _HomeScreenState extends State<HomeScreen> {
  /// APIインスタンス
  ApiUtil _api = ApiUtil.instance;
  /// APIレスポンス
  SubscriptionListResponse? _response;
  /// 登録チャンネル一覧
  List<Subscription> _items = [];

  @override
  void initState() {
    initHomeScreen();
    super.initState();
  }

  /// ホーム画面を初期化する
  Future<void> initHomeScreen() async {
    final response = await _api.getSubscriptionResponse();
    _response = response;
    _items = response.items!;
    int itemLength = _items.length;
    while (itemLength < _response!.pageInfo!.totalResults!) {
      final response = await _api.getSubscriptionResponse(
        pageToken: _response!.nextPageToken!,
      );
      _items.addAll(response.items!);
      itemLength = _items.length;
    }
    if (mounted) {
      setState(() {
        _response = _response;
        _items = _response!.items!;
      });
    }
    final preferences = await SharedPreferences.getInstance();
    final user = preferences.getString('userId');
    List<String>? favoriteIds = preferences.getStringList(user! + 'favoriteIds');
    if (favoriteIds != null) {
      for (var f in favoriteIds) {
        final favoriteChannel = _items.firstWhere(
          (subscription) => subscription.snippet!.resourceId!.channelId! == f
        );
        _items.remove(favoriteChannel);
        _items.insert(0, favoriteChannel);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OriginalAppBar(),
      body: _homeScreenBody(),
      floatingActionButton: FloatingSearchButton(),
    );
  }

  /// ホーム画面ボディ
  Widget _homeScreenBody() {
    if (_response != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ListView.builder(
          itemCount: _items.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == _items.length) { // 最後のインデックスの場合
              if (_items.length == 0) { // アイテム数が0の場合
                return Center(
                  child: Text('登録しているチャンネルがありません'),
                );
              }
              return Container();
            }
            return _profileCard(_items[index]);
          },
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }

  /// プロフィールカード
  Widget _profileCard(Subscription subscription) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChannelScreen(
            channelId: subscription.snippet!.resourceId!.channelId!,
            tabPage: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                subscription.snippet!.thumbnails!.medium!.url!
              ),
            ),
            SizedBox(width: 16,),
            Expanded(
              child: Text(
                subscription.snippet!.title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            FavoriteButton(
              channelId: subscription.snippet!.resourceId!.channelId!,
            ),
          ],
        ),
      ),
    );
  }
}
