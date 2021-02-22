import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_gif_finder/ui/gif_page.dart';

import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _urlTrendingGifs =
      'https://api.giphy.com/v1/gifs/trending?api_key=MewXAjNwjDVQVK4KtlplOZRLyBOdJ8K3&limit=20&rating=g';

  final TextEditingController _searchController = TextEditingController();

  int _offset = 0;

  Future<dynamic> _getSearchGifs() async {
    http.Response response;

    if (_searchController.text == null || _searchController.text.isEmpty) {
      response = await http.get(_urlTrendingGifs);
    } else {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=MewXAjNwjDVQVK4KtlplOZRLyBOdJ8K3&q=${_searchController.text}&limit=19&offset=$_offset&rating=g&lang=en');
    }

    return jsonDecode(response.body);
  }

  Widget builder(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
      case ConnectionState.none:
        return Container(
          width: 200,
          height: 200,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 5,
          ),
        );

      default:
        if (snapshot.hasError) {
          return Container();
        }

        return _createGifTable(context, snapshot);
    }
  }

  Widget _createGifTable(
      BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _getCount(snapshot),
      itemBuilder: (BuildContext context, int index) {
        if (_searchController.text == null ||
            index < int.parse(snapshot.data['data'].length.toString())) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              image: snapshot.data['data'][index]['images']['fixed_height']
                      ['url']
                  .toString(),
              height: 300,
              fit: BoxFit.cover,
              placeholder: kTransparentImage,
            ),
            onTap: () {
              Navigator.push<MaterialPageRoute>(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      GifPage(snapshot.data['data'][index]),
                ),
              );
            },
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']
                      ['url']
                  .toString());
            },
          );
        }

        return Container(
          child: GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 70,
                ),
                Text(
                  'Carregar mais...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                )
              ],
            ),
            onTap: () {
              setState(() {
                _offset += 19;
              });
            },
          ),
        );
      },
    );
  }

  int _getCount(AsyncSnapshot<dynamic> snapshot) {
    print(snapshot.data['data']);
    if (_searchController.text == null || _searchController.text.isEmpty) {
      return int.parse(snapshot.data['data'].length.toString());
    } else {
      return int.parse((snapshot.data['data'].length + 1).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquise aqui',
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.text = '';
                    });
                  },
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (String text) {
                setState(() {
                  _searchController.text = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<dynamic>(
              future: _getSearchGifs(),
              builder: builder,
            ),
          )
        ],
      ),
    );
  }
}
