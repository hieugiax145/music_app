
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/components/miniplayer.dart';
import 'package:music_app/firebase/firestore.dart';
import 'package:music_app/model/playlist_model.dart';
import 'package:music_app/model/playlist_provider.dart';
import 'package:music_app/model/songsprovider.dart';
import 'package:music_app/tabs/tab_navigator.dart';
import 'package:music_app/tabs/home.dart';
import 'package:music_app/tabs/library.dart';
import 'package:music_app/tabs/search.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final FirestoreService firestoreService = FirestoreService();
  late final dynamic allPlaylistsProvider;
  late final dynamic songsProvider;
  final user = FirebaseAuth.instance.currentUser!;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
    allPlaylistsProvider =
        Provider.of<AllPlaylistsProvider>(context, listen: false);
    // playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    // getNum();
    WidgetsBinding.instance.addObserver(this);
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    // fetchData();
    // getNum();
  }

  @override
  void didChangeMetrics() {
    // Check the keyboard visibility when the metrics change
    final bottomInset = View.of(context).viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0;
    });
  }

  void fetchData() async {
    QuerySnapshot querySnapshot = await firestoreService.playlists.get();
    List<Playlist> tmp = querySnapshot.docs
        .where((element) => element.reference.id != 'null')
        .map((doc) {
      // List<Song> songs=[];
      // getSongs(doc.id).then((value) => songs=value);
      return Playlist(
          playlistID: doc.id, title: doc['playlistName'], songs: []);
    }).toList();
    if (!mounted) return;
    allPlaylistsProvider.addPlaylists(tmp);
    // setState(() {
    //   playlists = tmp;
    //   // isDone = true;
    // });
  }

  final tabs = [
    const Home(),
    const Search(),
    const Library(),
  ];

  int _currentIndex = 0;
  var _currentTab = 'home';

  List<String> tabKeys = ['home', 'search', 'library'];
  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "home": GlobalKey<NavigatorState>(),
    "search": GlobalKey<NavigatorState>(),
    "library": GlobalKey<NavigatorState>(),
  };

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentTab) {
      _navigatorKeys[tabItem]?.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
        _currentTab = tabKeys[index];
      });
    }
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
        showNavigationBar: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    // var currentSongIndex=songsProvider.currentSongIndex;
    Color navColor = ElevationOverlay.applySurfaceTint(
        Theme.of(context).colorScheme.surface,
        Theme.of(context).colorScheme.surfaceTint,
        3);
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
        systemNavigationBarContrastEnforced: true,
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
        systemNavigationBarDividerColor:
            Theme.of(context).colorScheme.background,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
      child: WillPopScope(
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
              !await _navigatorKeys[_currentTab]!.currentState!.maybePop();
          if (isFirstRouteInCurrentTab) {
            if (_currentTab != 'home') {
              _selectTab('home', 0);

              return false;
            }
          }
          // let system handle back button if we're on the first route
          return isFirstRouteInCurrentTab;
        },
        child: Scaffold(
          bottomNavigationBar: _isKeyboardVisible
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MiniPlayer(),
                    SalomonBottomBar(
                      currentIndex: _currentIndex,
                      onTap: (index) {
                        _selectTab(tabKeys[index], index);
                      },
                      backgroundColor: Theme.of(context).colorScheme.background,
                      selectedItemColor:
                            Theme.of(context).colorScheme.primary,
                      unselectedItemColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                      items: [
                        SalomonBottomBarItem(
                          icon: const Icon(CupertinoIcons.home),
                          title: const Text('Home'),
                        ),
                        SalomonBottomBarItem(
                          icon: const Icon(CupertinoIcons.search_circle),
                          title: const Text('Search'),
                        ),
                        SalomonBottomBarItem(
                          icon: const Icon(CupertinoIcons.collections),
                          title: const Text('Library'),
                        ),
                      ],
                    ),
                    // GNav(
                    //     backgroundColor: Theme.of(context).colorScheme.secondary,
                    //     color: Theme.of(context).colorScheme.primary,
                    //     activeColor: Theme.of(context).colorScheme.secondary,
                    //     tabBackgroundColor:
                    //         Theme.of(context).colorScheme.inversePrimary,
                    //     // tabActiveBorder:Border.all(color: Theme.of(context).colorScheme.inversePrimary, width: 2),
                    //     gap: 5,
                    //     padding: EdgeInsets.symmetric(
                    //         horizontal: screenWidth * 0.07, vertical: 5),
                    //     tabMargin: const EdgeInsets.all(10),
                    //     iconSize: 24,
                    //     onTabChange: (index) {
                    //       _selectTab(tabKeys[index], index);
                    //       print(tabKeys[index]);
                    //     },
                    //     tabs: const [
                    //       GButton(
                    //         // gap: 10,
                    //         icon: CupertinoIcons.home,
                    //         text: 'Home',
                    //       ),
                    //       GButton(
                    //         // gap: 10,
                    //         icon: CupertinoIcons.search_circle,
                    //         text: 'Search',
                    //       ),
                    //       GButton(
                    //         // gap: 10,
                    //         icon: CupertinoIcons.collections,
                    //         text: 'Library',
                    //       ),
                    //     ]),
                    // Connectivity(),
                  ],
                ),
          body: Stack(children: <Widget>[
            _buildOffstageNavigator('home'),
            _buildOffstageNavigator('search'),
            _buildOffstageNavigator('library'),
          ]),
        ),
      ),
    );
  }
}
