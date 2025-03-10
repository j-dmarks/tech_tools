import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

  final TextEditingController serverController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController locationCodeController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController responseController = TextEditingController();
  final TextEditingController response2Controller = TextEditingController();

  final TextEditingController aoController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController itemBarcodeController = TextEditingController();
  List<Map<String, String>> servers = [];

  Socket? socket;
  bool isConnecting = false;
  String selectedTemplate = 'Patron Status';
  





