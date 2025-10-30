import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/midtrans_remote_datasource.dart';
import 'package:xpress/data/models/response/qris_response_model.dart';
import 'package:xpress/data/models/response/qris_status_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'qris_event.dart';
part 'qris_state.dart';
part 'qris_bloc.freezed.dart';

class QrisBloc extends Bloc<QrisEvent, QrisState> {
  final MidtransRemoteDatasource datasource;
  QrisBloc(
    this.datasource,
  ) : super(const _Initial()) {
    on<_GenerateQRCode>((event, emit) async {
      emit(const QrisState.loading());
      final response =
          await datasource.generateQRCode(event.orderId, event.grossAmount);
      log("response: $response");
      emit(_QrisResponse(response));
    });

    on<_CheckPaymentStatus>((event, emit) async {
      // emit(const QrisState.loading());
      final response = await datasource.checkPaymentStatus(event.orderId);
      log(" OrderID: ${event.orderId} | response: $response");
      // Future.delayed(const Duration(seconds: 5));
      // emit(QrisState.statusCheck(response));
      if (response.transactionStatus == 'settlement') {
        emit(_Success('Pembayaran Berhasil'));
      }
    });
  }
}
