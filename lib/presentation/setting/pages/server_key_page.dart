import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';

class ServerKeyPage extends StatefulWidget {
  final bool isTablet;
  const ServerKeyPage({
    super.key,
    this.isTablet = false,
  });

  @override
  State<ServerKeyPage> createState() => _ServerKeyPageState();
}

class _ServerKeyPageState extends State<ServerKeyPage> {
  TextEditingController? serverKeyController;

  String serverKey = '';

  Future<void> getServerKey() async {
    serverKey = await AuthLocalDataSource().getMitransServerKey();
  }

  @override
  void initState() {
    super.initState();
    serverKeyController = TextEditingController();
    getServerKey();
    //delay 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      serverKeyController!.text = serverKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Server Key'),
        centerTitle: true,
      ),
      //textfield untuk input server key
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: serverKeyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Server Key',
              ),
            ),
          ),
          //button untuk save server key
          ElevatedButton(
            onPressed: () {
              AuthLocalDataSource()
                  .saveMidtransServerKey(serverKeyController!.text);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Server Key saved'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
