String getAnimeByPage = """
query (\$page: Int, \$perPage: Int, \$search: String) {
  Page (page: \$page, perPage: \$perPage) {
    pageInfo {
      total
      perPage
    }
    media (search: \$search, type: ANIME, sort: FAVOURITES_DESC){
      id
      title {
        english
        native
      }
    }
  }
}
""";
String getAnimeInfoByID = """
query (\$id: Int) { 
  Media (id: \$id){
    id
    title {
      english
      native
    }
    season
    status
		duration
    episodes
    characters {
      nodes {
        id
        name {
          full
        }
        age
        gender
        bloodType
      }
    }
  }
}
""";
