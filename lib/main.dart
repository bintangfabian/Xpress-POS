import 'package:flutter/material.dart';
// import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/datasources/auth_remote_datasource.dart';
import 'package:xpress/data/datasources/category_remote_datasource.dart';
import 'package:xpress/data/datasources/discount_remote_datasource.dart';
import 'package:xpress/data/datasources/midtrans_remote_datasource.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:xpress/data/datasources/product_remote_datasource.dart';
import 'package:xpress/data/datasources/order_item_remote_datasource.dart';
import 'package:xpress/presentation/auth/bloc/logout/logout_bloc.dart';
import 'package:xpress/presentation/auth/pages/login_page.dart';
import 'package:xpress/presentation/auth/pages/splash_page.dart';
import 'package:xpress/presentation/home/bloc/get_table_status/get_table_status_bloc.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';
import 'package:xpress/presentation/home/bloc/qris/qris_bloc.dart';
import 'package:xpress/presentation/home/bloc/status_table/status_table_bloc.dart';
import 'package:xpress/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:xpress/presentation/report/blocs/item_sales_report/item_sales_report_bloc.dart';
import 'package:xpress/presentation/report/blocs/product_sales/product_sales_bloc.dart';
import 'package:xpress/presentation/report/blocs/summary/summary_bloc.dart';
import 'package:xpress/presentation/sales/blocs/bloc/last_order_table_bloc.dart';
import 'package:xpress/presentation/sales/blocs/day_sales/day_sales_bloc.dart';
import 'package:xpress/presentation/setting/bloc/add_product/add_product_bloc.dart';
import 'package:xpress/presentation/setting/bloc/get_categories/get_categories_bloc.dart';
import 'package:xpress/presentation/setting/bloc/get_products/get_products_bloc.dart';
import 'package:xpress/presentation/table/blocs/generate_table/generate_table_bloc.dart';
import 'package:xpress/presentation/table/blocs/get_table/get_table_bloc.dart';
import 'package:xpress/presentation/home/bloc/local_product/local_product_bloc.dart';
import 'package:xpress/presentation/home/bloc/order/order_bloc.dart';
import 'package:xpress/presentation/report/blocs/transaction_report/transaction_report_bloc.dart';
import 'package:xpress/presentation/setting/bloc/add_discount/add_discount_bloc.dart';
import 'package:xpress/presentation/setting/bloc/discount/discount_bloc.dart';
import 'package:xpress/presentation/setting/bloc/sync_order/sync_order_bloc.dart';
import 'package:xpress/presentation/setting/bloc/sync_product/sync_product_bloc.dart';
import 'package:xpress/data/datasources/table_remote_datasource.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/colors.dart';
import 'presentation/auth/bloc/login/login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/home/pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => LogoutBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => SyncProductBloc(ProductRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) =>
              LocalProductBloc(ProductLocalDatasource.instance),
        ),
        BlocProvider(
          create: (context) => CheckoutBloc(),
        ),
        BlocProvider(
          create: (context) => OrderBloc(OrderRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => SyncOrderBloc(OrderRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => DiscountBloc(DiscountRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => AddDiscountBloc(DiscountRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => TransactionReportBloc(OrderRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => GenerateTableBloc(TableRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => GetTableBloc(TableRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => StatusTableBloc(ProductLocalDatasource.instance),
        ),
        BlocProvider(
          create: (context) =>
              LastOrderTableBloc(ProductLocalDatasource.instance),
        ),
        BlocProvider(
          create: (context) => GetTableStatusBloc(),
        ),
        BlocProvider(
          create: (context) => AddProductBloc(ProductRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => GetProductsBloc(ProductRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => GetCategoriesBloc(CategoryRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => SummaryBloc(OrderRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => ProductSalesBloc(OrderItemRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => ItemSalesReportBloc(OrderItemRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => DaySalesBloc(ProductLocalDatasource.instance),
        ),
        BlocProvider(
          create: (context) => QrisBloc(MidtransRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => OnlineCheckerBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Xpress',
        theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(
            color: AppColors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              color: AppColors.primary,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            iconTheme: const IconThemeData(
              color: AppColors.primary,
            ),
          ),
        ),
        // Always start at LoginPage to avoid stale tokens
        home: const LoginPage(),
      ),
    );
  }
}
