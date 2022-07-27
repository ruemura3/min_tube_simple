import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube_simple/util/api_util.dart';
import 'package:min_tube_simple/screens/playlist_screen.dart';

/// チャンネル画面のプレイリストタブ
class PlaylistTab extends StatefulWidget {
  /// チャンネルインスタンス
  final Channel channel;
  /// ログイン中ユーザのチャンネルかどうか
  final bool isCurrentUser;

  /// コンストラクタ
  PlaylistTab({
    required this.channel,
    required this.isCurrentUser
  });

  @override
  _PlaylistTabState createState() => _PlaylistTabState();
}

/// プレイリストタブステート
class _PlaylistTabState extends State<PlaylistTab> with AutomaticKeepAliveClientMixin {
  /// APIインスタンス
  ApiUtil _api = ApiUtil.instance;
  /// ロード中フラグ
  bool _isLoading = false;
  /// APIレスポンス
  PlaylistListResponse? _response;
  /// プレイリスト一覧
  List<Playlist> _items = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _isLoading = true;
    Future(() async {
      final response = await _api.getPlaylistList(
        channelId: widget.channel.id!
      );
      if (mounted) {
        setState(() {
          _response = response;
          _items = response.items!;
          _isLoading = false;
        });
      }
    });
    super.initState();
  }

  /// 追加のプレイリスト読み込み
  bool _getAdditionalPlaylistItem(ScrollNotification scrollDetails) {
    if (!_isLoading && // ロード中でない
      scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent && // 最後までスクロールしている
      _items.length < _response!.pageInfo!.totalResults!) { // 現在のアイテム数が全アイテム数より少ない
      _isLoading = true;
      Future(() async {
        final response = await _api.getPlaylistList(
          channelId: widget.channel.id!,
          pageToken: _response!.nextPageToken!,
        );
        if (mounted) {
          setState(() {
            _response = response;
            _items.addAll(response.items!);
            _isLoading = false;
          });
        }
      });
    }
    return false;
  }

  /// プレイリストのアイテム数
  int _getTotalResults() {
    if (widget.isCurrentUser) { // ログイン中ユーザの場合
      // 高評価リストの分、1つ少ないとみなす
      return _response!.pageInfo!.totalResults! - 1;
    }
    return _response!.pageInfo!.totalResults!;
  }

  @override
  Widget build(BuildContext context) {
    if (_response != null) { // レスポンスがnullでない場合
      if (_items.length == 0) { // アイテム数が0の場合
        return Center(
          child: Text('このチャンネルにはプレイリストがありません'),
        );
      }
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalPlaylistItem,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            itemCount: _items.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == _items.length) { // 最後のインデックスの場合
                if (_items.length < _getTotalResults()) { // 全てのプレイリストを読み込んでいない場合
                  return Center(child: CircularProgressIndicator(),);
                }
                return Container();
              }
              return _playlistCard(_items[index]);
            },
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }

  /// プレイリストカード
  Widget _playlistCard(Playlist playlist) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlaylistScreen(
            playlist: playlist,
          ),
        ),
      ),
      child: Container(
        height: 112,
        padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
        child: Row(
          children: <Widget>[
            Stack(
              alignment: Alignment.centerRight,
              children: [
                Image.network(
                  playlist.snippet!.thumbnails!.medium!.url!,
                  errorBuilder: (c, o, s) {
                    return AspectRatio(
                      child: Container(),
                      aspectRatio: 16/9,
                    );
                  },
                ),
                Container(
                  color: Colors.black.withOpacity(0.7),
                  width: 64,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${playlist.contentDetails!.itemCount!.toString()}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8,),
                      Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 16,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      playlist.snippet!.title!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    playlist.snippet!.channelTitle!,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}