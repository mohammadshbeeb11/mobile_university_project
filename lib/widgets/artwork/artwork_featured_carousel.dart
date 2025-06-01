import 'package:flutter/material.dart';
import 'package:khat_husseini/models/artwork_model.dart';
import 'artwork_card.dart';

class ArtworkCarousel extends StatelessWidget {
  final double height;
  final List<Artwork> artworks;
  final Function(Artwork)? onAddToCart;

  const ArtworkCarousel({
    super.key,
    this.height = 400,
    required this.artworks,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: PageView.builder(
        itemCount: artworks.length,
        controller: PageController(viewportFraction: 0.85),
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
      ),
    );
  }
}
