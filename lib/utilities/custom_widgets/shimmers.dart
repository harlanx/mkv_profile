import 'package:fluent_ui/fluent_ui.dart';

import 'package:shimmer/shimmer.dart';

class InputTileShimmer extends StatelessWidget {
  const InputTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: FluentTheme.of(context).resources.textFillColorDisabled,
      highlightColor: FluentTheme.of(context).activeColor,
      child: ListTile(
        leading: SizedBox(
          height: 40,
          child: Center(
            child: Container(
              height: 16,
              width: 35,
              decoration: BoxDecoration(
                color: FluentTheme.of(context).resources.textFillColorDisabled,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        title: Container(
          margin: const EdgeInsetsDirectional.symmetric(vertical: 2),
          height: 16,
          width: 150,
          decoration: BoxDecoration(
            color: FluentTheme.of(context).resources.textFillColorDisabled,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        subtitle: Container(
          margin: const EdgeInsetsDirectional.symmetric(vertical: 2),
          height: 12,
          width: 180,
          decoration: BoxDecoration(
            color: FluentTheme.of(context).resources.textFillColorDisabled,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        trailing: SizedBox(
          height: 40,
          child: Center(
            child: Container(
              height: 8,
              width: 25,
              decoration: BoxDecoration(
                color: FluentTheme.of(context).resources.textFillColorDisabled,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TrackShimmer extends StatelessWidget {
  const TrackShimmer({super.key, required this.itemPadding});

  final double itemPadding;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return Shimmer.fromColors(
      baseColor: FluentTheme.of(context).resources.textFillColorDisabled,
      highlightColor: FluentTheme.of(context).activeColor,
      child: Container(
        padding: EdgeInsets.only(left: itemPadding),
        height: 30,
        width: double.infinity,
        decoration: BoxDecoration(
            color: theme.cardColor, borderRadius: BorderRadius.circular(5)),
        child: Row(
          children: [
            Container(
              height: 14,
              width: 14,
              decoration: BoxDecoration(
                color: FluentTheme.of(context).resources.textFillColorDisabled,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 15,
              width: 30,
              decoration: BoxDecoration(
                color: FluentTheme.of(context).resources.textFillColorDisabled,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 15,
              width: 200,
              decoration: BoxDecoration(
                color: FluentTheme.of(context).resources.textFillColorDisabled,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
