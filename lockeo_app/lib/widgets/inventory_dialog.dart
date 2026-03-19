import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/inventory.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'button.dart';

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
  final ImagePicker _picker = ImagePicker();
  late List<String> _photos;
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

  Future<void> _onTapSlot(int index) async {
    if (widget.readOnly) return;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() {
      while (_photos.length < 4) {
        _photos.add("");
      }
      _photos[index] = picked.path;
      _photos = _photos.where((p) => p.trim().isNotEmpty).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = "L’état des lieux";
    final maxHeight = MediaQuery.of(context).size.height * 0.82;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 28),
                      splashRadius: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ajouter vos photos",
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              _InventoryPhotosGrid(
                photos: _photos,
                onTapSlot: _onTapSlot,
                readOnly: widget.readOnly,
              ),

              const SizedBox(height: 22),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Commentaire",
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.cape300),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _commentCtrl,
                  enabled: !widget.readOnly,
                  maxLines: 4,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(16),
                    border: InputBorder.none,
                    hintText:
                        "On retrouve quelques endroits abîmés comme :\nle dessous droit et le côté gauche.\nAutres défauts : aucun",
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              CustomButton(
                text: widget.readOnly
                    ? "Fermer l’état des lieux"
                    : "Envoyer l’état des lieux",
                onPressed: () {
                  if (widget.readOnly) {
                    Navigator.pop(context, null);
                    return;
                  }

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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryPhotosGrid extends StatelessWidget {
  final List<String> photos;
  final Future<void> Function(int index) onTapSlot;
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

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: readOnly ? null : () => onTapSlot(i),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: path == null
                  ? Icon(
                      Icons.image_outlined,
                      size: 48,
                      color:
                          readOnly ? AppColors.cape300 : const Color(0xFFD1D5DB),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: path.startsWith('assets/')
                          ? Image.asset(path, fit: BoxFit.cover)
                          : Image.file(File(path), fit: BoxFit.cover),
                    ),
            ),
          ),
        );
      },
    );
  }
}
