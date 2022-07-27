import 'package:googleapis/youtube/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// APIサービスクラス
class ApiUtil {
  /// コンストラクタ
  ApiUtil._instantiate();

  /// シングルトンインスタンス
  static final ApiUtil instance = ApiUtil._instantiate();

  /// GoogleSignInインスタンス
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      YouTubeApi.youtubeScope,
    ],
  );

  /// 現在のユーザ
  GoogleSignInAccount? _user = _googleSignIn.currentUser;

  /// SharedPreferences
  late SharedPreferences _preferences;

  /// 現在のユーザを取得する
  /// ログインしていない場合はnullを返す
  Future<GoogleSignInAccount?> get user async {
    if (_user == null) {
      _user = await _googleSignIn.signInSilently();
    }
    return _user;
  }

  /// ログインしてユーザを返す
  Future<GoogleSignInAccount?> login() async {
    _user = await _googleSignIn.signIn();
    _preferences = await SharedPreferences.getInstance();
    _preferences.setString('userId', _user!.id);
    return _user;
  }

  /// ログアウトする
  Future<void> logout() async {
    await _googleSignIn.signOut();
    _user = null;
  }

  /// YouTube API
  Future<YouTubeApi> getYouTubeApi() async {
    final httpClient = await _googleSignIn.authenticatedClient();
    return YouTubeApi(httpClient!);
  }

  /// 検索結果のリストを取得する
  Future<SearchListResponse> getSearchList({
    String? channelId,
    int maxResults = 30,
    String? order,
    String? pageToken,
    String? query,
    List<String>? type,
  }) async {
    final youTubeApi = await getYouTubeApi();
    final SearchListResponse response = await youTubeApi.search.list(
      ['snippet'],
      channelId: channelId,
      maxResults: maxResults,
      order: order,
      pageToken: pageToken,
      q: query,
      type: type,
    );
    return response;
  }

  /// 動画のリストを取得する
  Future<VideoListResponse> getVideoList({required List<String> ids,}) async {
    final youTubeApi = await getYouTubeApi();
    final VideoListResponse response = await youTubeApi.videos.list(
      ['snippet', 'contentDetails', 'statistics', 'liveStreamingDetails'],
      id: ids,
      maxResults: ids.length,
    );
    return response;
  }

  /// 動画の評価を取得する
  Future<VideoGetRatingResponse> getVideoRating({required List<String> ids,}) async {
    final youTubeApi = await getYouTubeApi();
    final VideoGetRatingResponse response = await youTubeApi.videos.getRating(ids);
    return response;
  }

  /// 動画を評価する
  Future<void> rateVideo({required String id, required String rating}) async {
    final youTubeApi = await getYouTubeApi();
    await youTubeApi.videos.rate(id, rating);
  }

  /// チャンネルのリストを取得する
  Future<ChannelListResponse> getChannelList({
    List<String>? ids,
    bool? mine,
  }) async {
    final youTubeApi = await getYouTubeApi();
    final ChannelListResponse response = await youTubeApi.channels.list(
      ['snippet', 'contentDetails', 'statistics', 'brandingSettings'],
      id: ids,
      maxResults: ids?.length,
      mine: mine,
    );
    return response;
  }

  /// プレイリストのリストを取得する
  Future<PlaylistListResponse> getPlaylistList({
    String? channelId,
    List<String>? ids,
    int maxResults = 30,
    bool? mine,
    String? pageToken,
  }) async {
    final youTubeApi = await getYouTubeApi();
    final PlaylistListResponse response = await youTubeApi.playlists.list(
      ['snippet', 'contentDetails'],
      channelId: channelId,
      id: ids,
      maxResults: maxResults,
      mine: mine,
      pageToken: pageToken,
    );
    return response;
  }

  /// プレイリスト内のアイテムのリストを取得する
  Future<PlaylistItemListResponse> getPlaylistItemList({
    required String id,
    int maxResults = 30,
    String pageToken = '',
  }) async {
    final youTubeApi = await getYouTubeApi();
    final PlaylistItemListResponse response = await youTubeApi.playlistItems.list(
      ['snippet', 'contentDetails', 'status'],
      maxResults: maxResults,
      pageToken: pageToken,
      playlistId: id,
    );
    return response;
  }

  /// ログイン中ユーザの登録チャンネルのリストを取得する
  Future<SubscriptionListResponse> getSubscriptionResponse({
    String? forChannelId,
    int maxResults = 50,
    String? order = 'alphabetical',
    String? pageToken,
  }) async {
    final youTubeApi = await getYouTubeApi();
    final SubscriptionListResponse response = await youTubeApi.subscriptions.list(
      ['snippet', 'contentDetails'],
      forChannelId: forChannelId,
      maxResults: maxResults,
      mine: true,
      order: order,
      pageToken: pageToken,
    );
    return response;
  }

  /// チャンネル登録をする
  Future<Subscription> insertSubscription({
    required Channel channel,
  }) async {
    final youTubeApi = await getYouTubeApi();
    final response = await youTubeApi.subscriptions.insert(
      Subscription(
        snippet: SubscriptionSnippet(
          resourceId: ResourceId(channelId: channel.id)
        ),
      ),
      ['snippet'],
    );
    return response;
  }

  /// チャンネル登録を解除する
  Future<void> deleteSubscription({
    required Subscription subscription,
  }) async {
    final youTubeApi = await getYouTubeApi();
    await youTubeApi.subscriptions.delete(subscription.id!);
  }
}
