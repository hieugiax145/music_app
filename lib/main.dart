import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:music_app/model/song_model.dart';
import 'package:music_app/model/songhandler.dart';
import 'package:music_app/model/songsprovider.dart';
import 'package:music_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/auth_gate.dart';
import 'firebase/firebase_options.dart';

void main() async {
  SongHandler songHandler = await AudioService.init(
    builder: () => SongHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.dum1.app',
      androidNotificationChannelName: 'Dum Player',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode');
  final bool isDark;
  if (isDarkMode == null) {
    isDark = true;
  } else {
    isDark = isDarkMode;
  }
  List<Song> songs;
  int? idx=prefs.getInt('current');
  List<String>? playlistEncode = prefs.getStringList('playlist');
  if (playlistEncode == null) {
    songs = [];
  } else {
    songs = playlistEncode.map((String encodeSong) {
      Map<String, dynamic> json = jsonDecode(encodeSong);
      return Song.fromJson(json);
    }).toList();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider(isDark)),
        ChangeNotifierProvider(create: (context) => SongsProvider(songs,idx,songHandler)..loadMediaItem()),
        // ChangeNotifierProvider(create: (context) => SongProvider()),
        ChangeNotifierProvider(create: (context) => AllPlaylistsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    //   statusBarIconBrightness: Brightness.light,
    // ));
    // Future<SharedPreferences> prefs=SharedPreferences.getInstance;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const AuthGate(),
    );
  }
}
