import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  const GifPage(this._gifData);

  final dynamic _gifData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_gifData['title'].toString()),
          backgroundColor: Colors.black,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.share(
                    _gifData['images']['fixed_height']['url'].toString());
              },
            )
          ],
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Image.network(
              _gifData['images']['fixed_height']['url'].toString()),
        ));
  }
}
