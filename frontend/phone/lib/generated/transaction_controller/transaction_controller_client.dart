// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/create_transaction_request.dart';
import '../models/transaction_response.dart';

part 'transaction_controller_client.g.dart';

@RestApi()
abstract class TransactionControllerClient {
  factory TransactionControllerClient(Dio dio, {String? baseUrl}) =
      _TransactionControllerClient;

  @GET('/api/v1/transactions')
  Future<List<TransactionResponse>> getAllTransactions();

  @POST('/api/v1/transactions')
  Future<TransactionResponse> createTransaction({
    @Body() required CreateTransactionRequest body,
  });

  @GET('/api/v1/transactions/{transactionId}')
  Future<TransactionResponse> getTransactionById({
    @Path('transactionId') required String transactionId,
  });

  @DELETE('/api/v1/transactions/{transactionId}')
  Future<void> deleteTransaction({
    @Path('transactionId') required String transactionId,
  });

  @PATCH('/api/v1/transactions/{transactionId}')
  Future<TransactionResponse> updateTransaction({
    @Path('transactionId') required String transactionId,
    @Body() required Map<String, dynamic> body,
  });
}
