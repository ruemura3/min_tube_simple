import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:min_tube_simple/util/api_util.dart';
import 'package:min_tube_simple/screens/video_screen.dart';
import 'package:min_tube_simple/util/util.dart';

/// チャンネル画面のアップロード動画タブ
class UploadVideoTab extends StatefulWidget {
  /// チャンネルインスタンス
  final Channel channel;

  /// コンストラクタ
  UploadVideoTab({required this.channel});

  @override
  _UploadVideoTabState createState() => _UploadVideoTabState();
}

/// アップロード動画タブステート
class _UploadVideoTabState extends State<UploadVideoTab> with AutomaticKeepAliveClientMixin {
  /// APIインスタンス
  ApiUtil _api = ApiUtil.instance;
  /// ロード中フラグ
  bool _isLoading = false;
  /// APIレスポンス
  SearchListResponse? _response;
  /// アップロード動画一覧
  List<SearchResult> _items = [];
  /// 並び順
  String _order = 'date';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    getVideos(_order);
    super.initState();
  }

  /// 動画一覧を取得する
  Future<void> getVideos(String order, {String? pageToken}) async {
    _isLoading = true;
    final response = await _api.getSearchList(
      channelId: widget.channel.id!,
      order: order,
      pageToken: pageToken,
      type: ['video'],
    );
    if (mounted) {
      setState(() {
        _response = response;
        _items.addAll(response.items!);
        _isLoading = false;
      });
    }
  }

  /// 追加の動画読み込み
  bool _getAdditionalUploadVideo(ScrollNotification scrollDetails) {
    if (!_isLoading && // ロード中でない
    scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent && // 最後までスクロールしている
      _items.length < _response!.pageInfo!.totalResults!) { // 現在のアイテム数が全アイテム数より少ない
      getVideos(_order, pageToken: _response!.nextPageToken!);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_response != null) { // レスポンスがnullでない場合
      if (_items.length == 0) { // アイテム数が0の場合
        return Center(
          child: Text('このチャンネルには動画がありません'),
        );
      }
      return NotificationListener<ScrollNotification>(
        onNotification: _getAdditionalUploadVideo,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.builder(
            itemCount: _items.length + 2,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) { // 最初のインデックスの場合
                return Padding(
                  padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        child: Text('アップロード順'),
                        value: 'date',
                      ),
                      DropdownMenuItem(
                        child: Text('人気順'),
                        value: 'viewCount',
                      ),
                    ],
                    onChanged: (String? value) {
                      _order = value!;
                      _items = [];
                      getVideos(_order);
                    },
                    value: _order,
                  ),
                );
              }
              if (index == _items.length + 1) { // 最後のインデックスの場合
                if (_items.length < _response!.pageInfo!.totalResults!) { // 全ての動画を読み込んでいない場合
                  return Center(child: CircularProgressIndicator(),);
                }
                return Container();
              }
              return _videoCard(_items[index - 1]);
            },
          ),
        ),
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }

  /// 動画カード
  Widget _videoCard(SearchResult searchResult) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoScreen(
            videoId: searchResult.id!.videoId!,
          ),
        ),
      ),
      child: Container(
        height: 112,
        padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
        child: Row(
          children: <Widget>[
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Image.network(
                  searchResult.snippet!.thumbnails!.medium!.url!,
                  errorBuilder: (c, o, s) {
                    return AspectRatio(
                      child: Container(),
                      aspectRatio: 16/9,
                    );
                  },
                ),
                searchResult.snippet!.liveBroadcastContent == 'live'
                  ? Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      color: Colors.red.withOpacity(0.8),
                      padding: const EdgeInsets.only(left: 4, top: 2, right: 4, bottom: 2),
                      child: Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                  : Container(),
              ]
            ),
            SizedBox(width: 16,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      HtmlUnescape().convert(searchResult.snippet!.title!),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    Util.formatTimeago(searchResult.snippet!.publishedAt),
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