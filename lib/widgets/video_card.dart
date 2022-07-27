import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube_simple/screens/video_screen.dart';
import 'package:min_tube_simple/util/util.dart';

/// プレイリスト用の動画カード
class VideoCardForPlaylist extends StatelessWidget {
  /// プレイリストインスタンス
  final Playlist playlist;
  /// プレイリストアイテムのレスポンス
  final PlaylistItemListResponse response;
  /// プレイリストアイテム
  final List<PlaylistItem> items;
  /// 現在のインデックス
  final int idx;

  /// コンストラクタ
  VideoCardForPlaylist({
    required this.playlist,
    required this.response,
    required this.items,
    required this.idx,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoScreen(
            playlist: playlist,
            response: response,
            items: items,
            idx: idx,
            isForPlaylist: true,
          ),
        ),
      ),
      child: items[idx].snippet!.thumbnails!.medium != null
      ? Container(
          height: 112,
          padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
          child: Row(
            children: <Widget>[
              Image.network(
                  items[idx].snippet!.thumbnails!.medium!.url!,
                  errorBuilder: (c, o, s) {
                    return AspectRatio(
                      child: Container(),
                      aspectRatio: 16/9,
                    );
                  },
              ),
              SizedBox(width: 16,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        items[idx].snippet!.title!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      Util.formatTimeago(items[idx].contentDetails!.videoPublishedAt),
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
        )
        : Container(),
    );
  }
}
