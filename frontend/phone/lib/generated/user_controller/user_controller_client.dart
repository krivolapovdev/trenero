// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'user_controller_client.g.dart';

@RestApi()
abstract class UserControllerClient {
  factory UserControllerClient(Dio dio, {String? baseUrl}) =
      _UserControllerClient;

  @DELETE('/api/v1/users/me')
  Future<void> deleteMyAccount();
}
