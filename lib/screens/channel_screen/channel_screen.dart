import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:min_tube_simple/util/api_util.dart';
import 'package:min_tube_simple/screens/channel_screen/home_tab.dart';
import 'package:min_tube_simple/screens/channel_screen/playlist_tab.dart';
import 'package:min_tube_simple/screens/channel_screen/upload_video_tab.dart';
import 'package:min_tube_simple/util/color_util.dart';
import 'package:min_tube_simple/widgets/floating_search_button.dart';
import 'package:min_tube_simple/widgets/original_app_bar.dart';

/// チャンネル画面
class ChannelScreen extends StatefulWidget {
  /// チャンネルID
  final String? channelId;
  /// チャンネルインスタンス
  final Channel? channel;
  /// 初期タブ
  final int tabPage;
  /// ログイン中ユーザのチャンネルかどうか
  final bool isMine;

  /// コンストラクタ
  ChannelScreen({
    this.channelId,
    this.channel,
    this.tabPage = 0,
    this.isMine = false
  });

  @override
  _ChannelScreenState createState() => _ChannelScreenState();
}

/// チャンネル画面ステート
class _ChannelScreenState extends State<ChannelScreen> with SingleTickerProviderStateMixin {
  /// APIインスタンス
  ApiUtil _api = ApiUtil.instance;
  /// チャンネルインスタンス
  Channel? _channel;
  /// タブコントローラ
  late TabController _tabController;

  /// タブ
  final _tabs = <Tab> [
    Tab(text: 'ホーム'),
    Tab(text:'動画'),
    Tab(text:'プレイリスト'),
  ];

  @override
  void initState() {
    _tabController = TabController(length: _tabs.length, vsync: this);
    if (widget.channel != null) { // チャンネルインスタンスが取得済みの場合
      setState(() {
        _channel = widget.channel;
      });
    } else { // チャンネルインスタンスが取得済みでない場合
      Future(() async {
        final channels = await _api.getChannelList(ids: [widget.channelId!]);
        if (mounted) {
          setState(() {
            _channel = channels.items![0];
          });
        }
      });
    }
    _tabController.animateTo(widget.tabPage);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: OriginalAppBar(
          title: _channel != null ? _channel!.snippet!.title : '',
          tabBar: TabBar(
            labelColor: ColorUtil.textColor(context),
            unselectedLabelColor: Colors.grey,
            controller: _tabController,
            tabs: _tabs,
          ),
        ),
        body: _channelScreenBody(),
        floatingActionButton: FloatingSearchButton(),
      ),
    );
  }

  /// チャンネル画面のボディ
  Widget _channelScreenBody() {
    if (_channel != null) { // チャンネルインスタンスがnullでないとき
      return TabBarView(
        controller: _tabController,
        children: [
          HomeTab(channel: _channel!, isCurrentUser: widget.isMine),
          UploadVideoTab(channel: _channel!),
          PlaylistTab(channel: _channel!, isCurrentUser: widget.isMine),
        ],
      );
    }
    return Center(child: CircularProgressIndicator(),);
  }
}
