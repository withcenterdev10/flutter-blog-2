import 'package:dio/dio.dart';

final dio = Dio(
  BaseOptions(
    headers: {'User-Agent': 'Flutter App', 'Accept': 'application/json'},
  ),
);
