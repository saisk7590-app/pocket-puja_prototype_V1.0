import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/profile_models.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Pass an existing [address] to edit it, or leave null to add a new one.
class AddEditAddressScreen extends StatefulWidget {
  final AddressData? address;
  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  late String _label;
  late TextEditingController _lineController;
  late TextEditingController _landmarkController;
  late TextEditingController _pincodeController;
  late bool _isDefault;
  bool _dirty = false;

  bool get _isEditing => widget.address != null;
  final _labels = ['Home', 'Office', 'Other'];

  @override
  void initState() {
    super.initState();
    _label = widget.address?.label ?? 'Home';
    _lineController = TextEditingController(text: widget.address?.line ?? '');
    _landmarkController = TextEditingController(text: widget.address?.landmark ?? '');
    _pincodeController = TextEditingController(text: widget.address?.pincode ?? '');
    _isDefault = widget.address?.isDefault ?? false;
    _lineController.addListener(_markDirty);
    _landmarkController.addListener(_markDirty);
    _pincodeController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  bool get _isValid =>
      _lineController.text.trim().isNotEmpty &&
      _pincodeController.text.trim().length >= 5;

  void _save() {
    // Prototype note: no backend/state store here — this just confirms
    // the UI flow. Wiring to real persistence happens when a data layer exists.
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Address updated' : 'Address added')),
    );
  }

  void _delete() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: _isEditing ? 'Edit Address' : 'New Address',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // Label chips
          const SectionLabel('LABEL'),
          const SizedBox(height: 10),
          Row(
            children: _labels.map((l) {
              final sel = _label == l;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(l),
                  selected: sel,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  labelStyle: TextStyle(
                    color: sel ? AppColors.onPrimary : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() {
                    _label = l;
                    _dirty = true;
                  }),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Street Address
          const SectionLabel('STREET ADDRESS'),
          const SizedBox(height: 10),
          TextField(
            controller: _lineController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDeco('House / Flat no., Apartment, Street, Area'),
          ),
          const SizedBox(height: 16),

          // Landmark
          const SectionLabel('LANDMARK (OPTIONAL)'),
          const SizedBox(height: 10),
          TextField(
            controller: _landmarkController,
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDeco('Near temple, opposite park, etc.'),
          ),
          const SizedBox(height: 16),

          // Pincode
          const SectionLabel('PINCODE'),
          const SizedBox(height: 10),
          TextField(
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(color: Colors.white),
            decoration: _fieldDeco('6-digit pincode').copyWith(counterText: ''),
          ),
          const SizedBox(height: 16),

          // Default toggle
          GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set as default address',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Used automatically for new bookings & orders',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isDefault,
                  activeThumbColor: AppColors.onPrimary,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() {
                    _isDefault = v;
                    _dirty = true;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Save CTA
          PrimaryButton(
            label: _isEditing ? 'Save Changes' : 'Add Address',
            enabled: _isValid && (_dirty || !_isEditing),
            onTap: _save,
          ),

          if (_isEditing) ...[
            const SizedBox(height: 14),
            DestructiveButton(
              label: 'Delete Address',
              icon: Icons.delete_outline,
              onTap: _delete,
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _fieldDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  @override
  void dispose() {
    _lineController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }
}
