import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/artist_model.dart';

class ArtistTile extends StatelessWidget {
  final Artist artist;
  final void Function()? onTap;
  final void Function()? moreVert;
  const ArtistTile(
      {super.key,
      required this.artist,
      this.onTap,
      this.moreVert});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // margin: EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        // height: 90,
        decoration: const BoxDecoration(
            // color: Colors.amber,
            ),
        child: Row(
          children: [
            ClipOval(
              // child: FadeInImage.assetNetwork(
              //   placeholder: 'lib/assets/artist.png',
              //   image: artistProfile,
              //   fit: BoxFit.cover,
              //   width: 65,
              //   height: 65,
              //   placeholderColor: Theme.of(context).colorScheme.inversePrimary,
              child: CachedNetworkImage(
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                imageUrl: artist.artistProfile,
                // imageBuilder: (context, imageProvider) {
                // },
                placeholder: (context, url) =>
                    Image.asset('lib/assets/artist.png',color: Theme.of(context).colorScheme.secondary,),
                errorWidget: (context, url, error) =>
                    Image.asset('lib/assets/artist.png',color: Theme.of(context).colorScheme.secondary,),
                // ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              // decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist.artistName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Artist',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Spacer(),
            // const SizedBox(
            //   width: 10,
            // ),
            // InkWell(
            //   onTap: moreVert,
            //   child: const Icon(
            //     Icons.more_vert,
            //     size: 25,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
