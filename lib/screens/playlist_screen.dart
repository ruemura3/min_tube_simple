import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube_simple/util/api_util.dart';
import 'package:min_tube_simple/screens/channel_screen/channel_screen.dart';
import 'package:min_tube_simple/widgets/floating_search_button.dart';
import 'package:min_tube_simple/widgets/original_app_bar.dart';
import 'package:min_tube_simple/widgets/video_card.dart';

/// プレイリスト画面
class PlaylistScreen extends StatefulWidget {
  /// プレイリストID
  final String? playlistId;
  /// プレイリストインスタンス
  final Playlist? playlist;

  /// コンストラクタ
  PlaylistScreen({this.playlistId, this.playlist});

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

/// プレイリスト画面ステート
class _PlaylistScreenState extends State<PlaylistScreen> {
  /// APIインスタンス
  ApiUtil _api = ApiUtil.instance;
  /// ロード中フラグ
  bool _isLoading = false;
  /// プレイリストインスタンス
  Playlist? _playlist;
  /// APIレスポンス
  PlaylistItemListResponse? _response;
  /// プレイリストアイテム一覧
  List<PlaylistItem> _items = [];
  /// 非表示動画の数
  int _privateCount = 0;

  @override
  void initState() {
    _isLoading = true;
    if (widget.playlist != null) { // プレイリストインスタンスが取得済みの場合
      _playlist = widget.playlist;
      Future(() async {
        await _getPlaylistItems();
      });
    } else {
      Future(() async {
        final response = await _api.getPlaylistList(ids: [widget.playlistId ?? 'LL']);
        if (mounted) {
          setState(() {
            _playlist = response.items![0];
          });
        }
        await _getPlaylistItems();
      });
    }
    super.initState();
  }

  /// プレイリストアイテムを取得する
  Future<void> _getPlaylistItems() async {
    final response = await _api.getPlaylistItemList(
      id: _playlist!.id!,
    );
    if (mounted) {
      setState(() {
        _response = response;
        _items = response.items!;
        _isLoading = false;
      });
    }
  }

  /// 追加のプレイリストアイテムを取得する
  bool _getAdditionalPlaylistItem(ScrollNotification scrollDetails) {
    if (!_isLoading && // ロード中でない
      scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent && // 最後までスクロールしている
      _items.length < _response!.pageInfo!.totalResults!) { // 現在のアイテム数が全アイテム数より少ない
      _isLoading = true;
      Future(() async {
        final response = await _api.getPlaylistItemList(
          id: _playlist!.id!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OriginalAppBar(
        title: _playlist != null ? _playlist!.snippet!.title! : '',
      ),
      body: _playlistScreenBody(),
      floatingActionButton: FloatingSearchButton(),
    );
  }

  /// プレイリスト画面ボディ
  Widget _playlistScreenBody() {
    if (_response != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalPlaylistItem,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            itemCount: _items.length + 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) { // 最初のインデックスの場合
                return _playlistDetail();
              }
              if (_items.length == 0) { // アイテム数が0の場合
                return Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16,),
                  child: Center(
                    child: Text('このプレイリストには動画がありません'),
                  ),
                );
              }
              if (index == _items.length + 1) { // 最後のインデックスの場合
                if (_items.length < _response!.pageInfo!.totalResults!) { // 全てのプレイリストアイテムを読み込んでいない場合
                  return Center(child: CircularProgressIndicator(),);
                }
                if (_privateCount != 0) { // 非表示動画があった場合
                  return Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 16,),
                    child: Center(
                      child: Text('$_privateCount本の利用できない動画が非表示になっています'),
                    ),
                  );
                }
                return Container();
              }
              if (_items[index - 1].status!.privacyStatus != 'public') {
                _privateCount += 1;
              }
              return VideoCardForPlaylist(
                playlist: _playlist!,
                response: _response!,
                items: _items,
                idx: index - 1,
              );
            },
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }

  /// プレイリスト詳細
  Widget _playlistDetail() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Text(
              _playlist!.snippet!.title!,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 8,),
          Container(
            width: double.infinity,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChannelScreen(
                    channelId: _playlist!.snippet!.channelId!,
                  ),
                ),
              ),
              child: _playlist!.snippet!.channelTitle != null
                ? Text(
                  _playlist!.snippet!.channelTitle!,
                  style: TextStyle(fontSize: 16),
                )
                : Container(),
            ),
          ),
          SizedBox(height: 8,),
          Container(
            width: double.infinity,
            child: Text(
              _playlist!.snippet!.description!,
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}
