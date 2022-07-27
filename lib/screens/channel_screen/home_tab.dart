import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube_simple/util/util.dart';
import 'package:min_tube_simple/widgets/subscribe_button.dart';

/// チャンネル画面のホームタブ
class HomeTab extends StatelessWidget {
  /// チャンネルインスタンス
  final Channel channel;
  /// ログイン中ユーザのチャンネルかどうか
  final bool isCurrentUser;

  /// コンストラクタ
  HomeTab({
    required this.channel,
    required this.isCurrentUser
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _profileCard(context),
    );
  }

  /// プロフィールカード
  Widget _profileCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          channel.brandingSettings!.image != null // バナー画像がある場合は表示
            ? Image.network(
              channel.brandingSettings!.image!.bannerExternalUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (c, o, s) {
                return AspectRatio(
                  child: Container(),
                  aspectRatio: 1/1,
                );
              },
            )
            : Container(),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 24, right: 16, bottom: 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(
                    channel.snippet!.thumbnails!.medium!.url!
                  ),
                ),
                SizedBox(height: 16,),
                Text(
                  channel.snippet!.title!,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8,),
                channel.statistics!.subscriberCount != null // 登録者数非表示でない場合は表示
                  ? Text(
                    'チャンネル登録者数 ${Util.formatNumber(channel.statistics!.subscriberCount!)}人',
                    style: TextStyle(color: Colors.grey),
                  )
                  : Container(),
                !isCurrentUser // ログイン中ユーザのチャンネルでない場合は表示
                  ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SubscribeButton(channel: channel,),
                  )
                  : Container(),
                channel.snippet!.description! != '' // 説明文がある場合は表示
                  ? Column(
                    children: [
                      SizedBox(height: 8,),
                      Divider(color: Colors.grey,),
                      SizedBox(height: 8,),
                      Util.getDescriptionWithUrl(
                        channel.snippet!.description!,
                        context
                      ),
                    ]
                  )
                  : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}