import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:interviewgraphql/shared/graphQLConfig.dart';
import 'package:interviewgraphql/shared/queries.dart';
import 'package:interviewgraphql/widgets/texts.dart';
import 'package:nb_utils/nb_utils.dart';

class AnimeDetail extends StatefulWidget {
  AnimeDetail({Key? key, this.anime}) : super(key: key);
  final anime;
  @override
  _AnimeDetailState createState() => _AnimeDetailState();
}

class _AnimeDetailState extends State<AnimeDetail> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text((widget.anime["title"]["english"] == null
                  ? widget.anime["title"]["native"]
                  : widget.anime["title"]["english"])
              .toString()),
        ),
        body: GraphQLProvider(
          client: GraphQLConfiguration.clientToQuery(),
          child: Column(
            children: [
              Container(
                child: Query(
                  options: QueryOptions(
                    document: gql(getAnimeInfoByID),
                    variables: {'id': widget.anime["id"]},
                    pollInterval: Duration(seconds: 10),
                  ),
                  builder: (QueryResult result,
                      {refetch, FetchMore? fetchMore}) {
                    if (result.hasException) {
                      return Text("Too many request!");
                    }
                    if (result.data == null) {
                      return Text("no data");
                    }

                    List characters =
                        result.data!["Media"]["characters"]["nodes"];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        detailText("Season", result.data!["Media"]["season"]),
                        detailText("Status", result.data!["Media"]["status"]),
                        detailText("Duration",
                            result.data!["Media"]["duration"].toString()),
                        detailText("Episodes",
                            result.data!["Media"]["episodes"].toString()),
                        TitleText("Characters").paddingTop(20),
                        Container(
                          width: size.width - 40,
                          height: size.height - 300,
                          child: ListView(
                            children: <Widget>[
                              for (var character in characters)
                                ListTile(
                                  title: Text(
                                      (character["name"]["full"]).toString()),
                                  onTap: () {
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return SafeArea(
                                          child: Container(
                                              width: size.width,
                                              height: size.height,
                                              padding: EdgeInsets.all(20),
                                              color: Colors.white,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    top: 10,
                                                    left: 10,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.pink,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                      top: 70,
                                                      left: 10,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          TitleText(
                                                            (character["name"]
                                                                    ["full"])
                                                                .toString(),
                                                          ),
                                                          Container(
                                                            width: size.width,
                                                            height: 1,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .grey),
                                                          ).paddingTop(10),
                                                          detailText(
                                                              "Gender",
                                                              character[
                                                                  "gender"]),
                                                          detailText("Age",
                                                              character["age"]),
                                                          detailText(
                                                              "Blood Type",
                                                              character[
                                                                  "bloodType"]),
                                                        ],
                                                      ))
                                                ],
                                              )),
                                        );
                                      },
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
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ).paddingAll(20),
        ));
  }
}
