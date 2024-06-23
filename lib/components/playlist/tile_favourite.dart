import 'package:flutter/material.dart';
import 'package:music_app/firebase/firestore.dart';

class FavouriteTile extends StatefulWidget {
  final void Function()? onTap;
  final void Function()? moreVert;
  const FavouriteTile({
    super.key,
    this.onTap,
    this.moreVert,
  });

  @override
  State<FavouriteTile> createState() => _FavouriteTileState();
}

class _FavouriteTileState extends State<FavouriteTile> {
  final FirestoreService firestoreService = FirestoreService();
  late final dynamic playlistProvider;

  List playlist = [];
  int numOfTrack=0;

  @override
  void initState(){
    super.initState();
    getNum();

  }

  @override
  void dispose(){
    super.dispose();
    getNum();
  }

  void getNum() async{
    int tmp=await firestoreService.getTracksLength();
    if (!mounted) return;
    setState(() {
      numOfTrack=tmp-1;
    });
  }

  @override
  Widget build(BuildContext context) {
    getNum();
    // print(numOfTrack);
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const Image(
                image: AssetImage('lib/assets/heart.png'),
                fit: BoxFit.cover,
                width: 65,
                height: 65,

                // child: CachedNetworkImage(
                //   width: 65,
                //   height: 65,
                //   fit: BoxFit.cover,
                //   imageUrl:
                //       albumCover,
                //   // imageBuilder: (context, imageProvider) {
                //   // },
                //   placeholder: (context, url) =>
                //       const CircularProgressIndicator(),
                //   errorWidget: (context, url, error) => const Icon(Icons.error),
                // ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Favourite',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$numOfTrack tracks',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )
                  ), 
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
