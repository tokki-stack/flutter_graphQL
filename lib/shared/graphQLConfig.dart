import "package:flutter/material.dart";
import "package:graphql_flutter/graphql_flutter.dart";

class GraphQLConfiguration {
  static HttpLink httpLink = HttpLink(
    'https://graphql.anilist.co',
    defaultHeaders: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Charset': 'utf-8'
    },
  );

  static ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
    ),
  );

  static ValueNotifier<GraphQLClient> clientToQuery() {
    return client;
  }
}
