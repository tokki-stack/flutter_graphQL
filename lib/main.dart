import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:interviewgraphql/pages/anime_detail.dart';
import 'package:interviewgraphql/shared/graphQLConfig.dart';
import 'package:interviewgraphql/shared/queries.dart';
import 'package:nb_utils/nb_utils.dart';

void main() async {
  await initHiveForFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: GraphQLProvider(
          client: GraphQLConfiguration.clientToQuery(),
          child: const MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _nMovies = 20;
  late int _pageNumber;
  ScrollController _scrollController = new ScrollController();
  final _searchController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    _pageNumber = 1;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Text(
            "Anime List",
            style: TextStyle(fontSize: 22),
          ).paddingTop(20),
          Container(
            height: 50,
            width: size.width,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Search",
              ),
              controller: _searchController,
              onFieldSubmitted: (value) async {
                if (value != "" && value != null) {
                  _pageNumber = 1;
                }
              },
            ),
          ),
          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(getAnimeByPage),
                variables: {
                  'page': _pageNumber,
                  'perPage': _nMovies,
                  'search': _searchController.text == ""
                      ? null
                      : _searchController.text
                },
                pollInterval: Duration(seconds: 10),
              ),
              builder: (QueryResult result, {refetch, FetchMore? fetchMore}) {
                if (result.hasException) {
                  return Text("Too many request!");
                }
                if (result.data == null) {
                  return Text("no data");
                }

                final List displayMovies = result.data!["Page"]["media"];
                _pageNumber = _pageNumber + 1;
                FetchMoreOptions opts = FetchMoreOptions(
                  variables: {
                    'page': _pageNumber,
                    'perPage': _nMovies,
                    'search': _searchController.text == ""
                        ? null
                        : _searchController.text
                  },
                  updateQuery: (previousResultData, fetchMoreResultData) {
                    final List<dynamic> movies = [
                      ...previousResultData!["Page"]["media"] as List<dynamic>,
                      ...fetchMoreResultData!["Page"]["media"] as List<dynamic>
                    ];

                    fetchMoreResultData["Page"]["media"] = movies;

                    return fetchMoreResultData;
                  },
                );
                _scrollController
                  ..addListener(() async {
                    if (_scrollController.position.pixels ==
                        _scrollController.position.maxScrollExtent) {
                      if (!result.isLoading) {
                        await fetchMore!(opts);
                      }
                    }
                  });
                return ListView(
                  controller: _scrollController,
                  children: <Widget>[
                    for (var movie in displayMovies)
                      ListTile(
                        title: Text((movie["title"]["english"] == null
                                ? movie["title"]["native"]
                                : movie["title"]["english"])
                            .toString()),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnimeDetail(anime: movie),
                            ),
                          );
                        },
                      ),
                    if (result.isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                        ],
                      ),
                  ],
                );
              },
            ),
          )
        ],
      ).paddingOnly(left: 20, right: 20)),
    );
  }
}
