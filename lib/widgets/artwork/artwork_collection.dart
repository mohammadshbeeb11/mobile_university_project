import 'package:flutter/material.dart';
import 'package:khat_husseini/models/artwork_model.dart';
import 'artwork_card.dart';

class ArtworkGridView extends StatelessWidget {
  final List<Artwork> artworks;
  final Function(Artwork)? onAddToCart;

  const ArtworkGridView({super.key, required this.artworks, this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: artworks.length,
      itemBuilder: (context, index) {
        final artwork = artworks[index];
        return ArtworkCard(
          artwork: artwork,
          onAddToCart: () {
            if (onAddToCart != null) {
              onAddToCart!(artwork);
            }
          },
        );
      },
    );
  }
}
