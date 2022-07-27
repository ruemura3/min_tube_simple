import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube_simple/util/api_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// チャンネル登録ボタン
class SubscribeButton extends StatefulWidget {
  /// チャンネルインスタンス
  final Channel channel;

  /// コンストラクタ
  SubscribeButton({required this.channel});

  @override
  _SubscribeButtonState createState() => _SubscribeButtonState();
}

/// チャンネル登録ボタンステート
class _SubscribeButtonState extends State<SubscribeButton> {
  /// APIインスタンス
  ApiUtil _api = ApiUtil.instance;
  /// 登録済みフラグ
  bool _isSubscribed = false;
  /// 登録インスタンス
  Subscription? _subscription;
  /// ボタン活性フラグ
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final response = await _api.getSubscriptionResponse(forChannelId: widget.channel.id!);
      if (mounted) {
        setState(() {
          _isSubscribed = response.items!.length != 0;
          if (_isSubscribed) {
            _subscription = response.items![0];
          }
          _isEnabled = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubscribed) {
      return TextButton(
        onPressed: _isEnabled
          ? () => _showUnsubscribeDialog()
          : null,
        style:  ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          minimumSize: MaterialStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          '登録済み',
          style: TextStyle(color: Colors.grey,),
        ),
      );
    } else {
      return TextButton(
        onPressed: _isEnabled
          ? () {
            setState(() {
              _isEnabled = false;
            });
            Future(() async {
              final response = await _api.insertSubscription(channel: widget.channel);
              if (mounted) {
                setState(() {
                  _isSubscribed = true;
                  _subscription = response;
                  _isEnabled = true;
                });
              }
            });
          }
          : null,
        style:  ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          minimumSize: MaterialStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'チャンネル登録',
          style: TextStyle(
            color: Colors.red,
            fontSize: 13
          ),
        ),
      );
    }
  }

  /// チャンネル登録解除のダイアログを表示する
  _showUnsubscribeDialog() {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Text("${widget.channel.snippet!.title} のチャンネル登録を解除しますか？"),
          actions: <Widget>[
            TextButton(
              child: Text("キャンセル"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("登録解除"),
              onPressed: () {
                setState(() {
                  _isEnabled = false;
                });
                Future(() async {
                  await _api.deleteSubscription(subscription: _subscription!);
                  if (mounted) {
                    setState(() {
                      _isSubscribed = false;
                      _subscription = null;
                      _isEnabled = true;
                    });
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
