import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/firebase/firestore.dart';

class History extends StatelessWidget {
  History({super.key});

  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('History'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.delete_solid))
        ],
      ),
      // body: StreamBuilder(
      //   stream: firestoreService.getHistory(),
      //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(child: CircularProgressIndicator());
      //     }
      //     if (!snapshot.hasData || snapshot.data!.docs.length == 0) {
      //       return const Center(child: Text('No recently activity.'));
      //     }
      //     return ListView.builder(
      //         itemCount: 1,
      //         itemBuilder: (context, index) {
      //           return Center(child: Text('Nothing here'),);
      //         });
      //   },
      // ),
      body: const Center(child: Text('Nothing here')),
    );
  }
}
