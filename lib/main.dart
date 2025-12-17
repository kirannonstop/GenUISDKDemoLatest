// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:genui_sdk_demo/chat_screen.dart';
import 'package:logging/logging.dart';

import 'configuration.dart';

// If you want to convert to using Firebase AI, run:
//
//   sh tool/refresh_firebase.sh <project_id>
//
// to refresh the Firebase configuration for a specific Firebase project.
// and uncomment the Firebase initialization code and import below that is
// marked with UNCOMMENT_FOR_FIREBASE, and set the value of `aiBackend` to
// `AiBackend.firebase` in `lib/configuration.dart`.

// import 'firebase_options.dart'; // UNCOMMENT_FOR_FIREBASE

// Conditionally import non-web version so we can read from shell env vars in
// non-web version.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize Firebase if we are using the Firebase backend.
  if (aiBackend == AiBackend.firebase) {
    await Firebase.initializeApp(
      // UNCOMMENT_FOR_FIREBASE (See top of file for details)
      // options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  configureGenUiLogging(level: Level.ALL);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooking Assistant',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const DefaultOrCustomCatalogScreen(),
    );
  }
}

class DefaultOrCustomCatalogScreen extends StatelessWidget {
  const DefaultOrCustomCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cooking Assistant Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'GenUI Catalog - Default Demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'GenUI Catalog - Custom Catalog Demo - Upcoming Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
