import 'package:dio/dio.dart';
import 'package:mashrooa_takharog/widgets/articlemodel.dart';

class Plogsnewsserviece {
  final Dio dio;
  Plogsnewsserviece(this.dio);
  Future<List<Articlemodel>> getNews({required String category}) async {
    try {
      var response = await dio.get(
          "https://newsapi.org/v2/everything?q=$category&apiKey=adf9dd31f8d14507a3cc57828c3faa75");
      Map<String, dynamic> josndata = response.data;
      List<dynamic> articles = josndata["articles"];
      List<Articlemodel> articelList = [];
      for (var article in articles) {
        Articlemodel articlemodel = Articlemodel(
            image: article["urlToImage"],
            title: article["title"],
            subtitle: article["description"],
            url: article["url"]);
        articelList.add(articlemodel);
      }
      return articelList;
    } catch (e) {
      return [];
    }
  }
}
