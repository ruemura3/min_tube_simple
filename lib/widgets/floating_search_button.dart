import 'package:flutter/material.dart';
import 'package:min_tube_simple/util/util.dart';

/// 右下の検索ボタン
class FloatingSearchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Util.showSearchDialog(context);
      },
      child: Icon(Icons.search),
    );
  }
}