import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kit_core/utils/extensions/string_ext.dart';

import '../../../core/utils/pokemon_utils.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final bool isCompareMode;
  final bool isSelectedForCompare;
  final VoidCallback? onCompareTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
    this.isFavorite = false,
    required this.onFavoriteToggle,
    this.isCompareMode = false,
    this.isSelectedForCompare = false,
    this.onCompareTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryType = pokemon.types.first.type.name;
    final bgColor = PokemonUtils.getTypeColor(primaryType);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelectedForCompare
            ? const BorderSide(color: Color(0xFF3B82F6), width: 2.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isCompareMode
            ? (onCompareTap != null
                  ? () {
                      HapticFeedback.lightImpact();
                      onCompareTap?.call();
                    }
                  : null)
            : onTap,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    bgColor.withValues(alpha: 0.6),
                    bgColor.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'pokemon-${pokemon.id}',
                      child: CachedNetworkImage(
                        imageUrl:
                            pokemon
                                .sprites
                                .other
                                ?.officialArtwork
                                ?.frontDefault ??
                            pokemon.sprites.frontDefault ??
                            '',
                        fit: BoxFit.contain,
                        memCacheWidth: 350,
                        placeholder: (context, url) => Center(
                          child: Icon(
                            Icons.catching_pokemon,
                            size: 48,
                            color: bgColor.withValues(alpha: 0.2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.catching_pokemon,
                          size: 64,
                          color: bgColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#${pokemon.id.toString().padLeft(3, '0')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pokemon.name.capitalize,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: pokemon.types.take(2).map((type) {
                            final typeColor = PokemonUtils.getTypeColor(
                              type.type.name,
                            );
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                type.type.name.capitalize,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Favorite button — hidden in compare mode
            if (!isCompareMode)
              Positioned(
                top: 4,
                right: 4,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onFavoriteToggle();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ),

            // Compare selector badge
            if (isCompareMode)
              Positioned(
                top: 6,
                right: 6,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelectedForCompare
                        ? const Color(0xFF3B82F6)
                        : Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelectedForCompare
                          ? const Color(0xFF3B82F6)
                          : Colors.white.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isSelectedForCompare
                        ? Icons.check_rounded
                        : Icons.add_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
