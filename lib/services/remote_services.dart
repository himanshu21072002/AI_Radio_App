import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jeevi/models/post.dart';

class RemoteService {
  Future<List<Post>?> getPosts() async {
    var client = http.Client();

    var uri = Uri.parse('https://imbesideyou.herokuapp.com/api/get_data');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      print(response);
      //var json = response.body;
      Iterable l = json.decode(response.body);

      return  List<Post>.from(l.map((model)=> Post.fromJson(model)));;

    }
  }
}