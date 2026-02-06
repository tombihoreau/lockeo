import 'package:flutter/material.dart';
import '../models/inventory.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class InventoryDialog extends StatefulWidget {
  final int reservationId;
  final Inventory? initialInventory;
  final bool readOnly;

  const InventoryDialog({
    super.key,
    required this.reservationId,
    required this.initialInventory,
    required this.readOnly,
  });

  @override
  State<InventoryDialog> createState() => _InventoryDialogState();
}

class _InventoryDialogState extends State<InventoryDialog> {
  late List<String> _photos; // suppose Inventory.photos: List<String>
  late TextEditingController _commentCtrl;

  @override
  void initState() {
    super.initState();
    _photos = List<String>.from(widget.initialInventory?.photos ?? const <String>[]);
    _commentCtrl = TextEditingController(text: widget.initialInventory?.comment ?? "");
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _onTapSlot(int index) {
    if (widget.readOnly) return;

    // TODO plus tard: image_picker
    const fakePath = 'assets/images/default.jpg';

    setState(() {
      while (_photos.length < 4) {
        _photos.add("");
      }
      _photos[index] = fakePath;
      _photos = _photos.where((p) => p.trim().isNotEmpty).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = "L’état des lieux";

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ajouter vos photos",
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 12),

            _InventoryPhotosGrid(
              photos: _photos,
              onTapSlot: _onTapSlot,
              readOnly: widget.readOnly,
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Commentaire",
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cape300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _commentCtrl,
                enabled: !widget.readOnly,
                maxLines: 4,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                  hintText: "Décris l’état du matériel (défauts, rayures, etc.)",
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.readOnly) {
                    Navigator.pop(context, null);
                    return;
                  }

                  // création d'un Inventory direct (pas de draft)
                  final inv = Inventory(
                    inventoryId: DateTime.now().millisecondsSinceEpoch,
                    reservationId: widget.reservationId,
                    photos: _photos.take(4).toList(),
                    comment: _commentCtrl.text.trim(),
                    createdAt: DateTime.now().toUtc().toString(),
                    status: "submitted",
                  );

                  Navigator.pop(context, inv);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.readOnly ? "Fermer" : "Envoyer l’état des lieux",
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryPhotosGrid extends StatelessWidget {
  final List<String> photos;
  final void Function(int index) onTapSlot;
  final bool readOnly;

  const _InventoryPhotosGrid({
    required this.photos,
    required this.onTapSlot,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    String? slotPhoto(int i) {
      if (i < photos.length && photos[i].trim().isNotEmpty) return photos[i];
      return null;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (_, i) {
        final path = slotPhoto(i);

        return GestureDetector(
          onTap: () => onTapSlot(i),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cape200,
              borderRadius: BorderRadius.circular(16),
              border: readOnly
                  ? Border.all(color: AppColors.cape300, width: 1)
                  : null,
            ),
            child: path == null
                ? Icon(
                    Icons.image_outlined,
                    color: readOnly ? AppColors.cape300 : AppColors.textGrey,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(path, fit: BoxFit.cover),
                  ),
          ),
        );
      },
    );
  }
}
