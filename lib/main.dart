import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/dart.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

import 'generator/model_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Json to Dart update',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final textCtl = TextEditingController();
  final classNameCtrl = TextEditingController();
  String? generatedCode;
  final _formKey = GlobalKey<FormState>();

  final controller = CodeController(
    text: '...', // Initial code
    language: dart,
  );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Json To Dart"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: height * .8,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          controller: textCtl,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(10),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please input json here.";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: width / 4,
                            child: TextFormField(
                              controller: classNameCtrl,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Please define your dart class name.";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  hintText: "Dart class name",
                                  border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                try {
                                  final classGenerator =
                                      ModelGenerator(classNameCtrl.text);
                                  DartCode dartCode = classGenerator
                                      .generateDartClasses(textCtl.text);

                                  setState(() {
                                    generatedCode = dartCode.code.toString();
                                  });
                                  controller.text = generatedCode ?? "";
                                } on FormatException {
                                  // throw FormatException();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Error json format.")));
                                }
                              },
                              child: const Text("Generate Dart"))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * .8,
                    width: width / 2.05,
                    child: SingleChildScrollView(
                      child: CodeTheme(
                        data: CodeThemeData(styles: atomOneDarkTheme),
                        child: CodeField(
                          controller: controller,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (generatedCode != null) {
                        Clipboard.setData(ClipboardData(text: generatedCode!))
                            .then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Copied to your clipboard")));
                        });
                      }
                    },
                    icon: const Icon(Icons.copy),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
