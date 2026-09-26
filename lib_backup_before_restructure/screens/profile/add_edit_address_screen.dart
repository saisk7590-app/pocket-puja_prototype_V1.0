import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../data/profile/profile_data.dart';

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

  bool get _isValid => _lineController.text.trim().isNotEmpty && _pincodeController.text.trim().length >= 5;

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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: _isEditing ? 'Edit Address' : 'Add Address',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('LABEL'),
                const SizedBox(height: 10),
                Row(
                  children: _labels.map((l) {
                    final sel = _label == l;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() { _label = l; _dirty = true; }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sel ? AppColors.primary : Colors.white24),
                          ),
                          child: Text(l, style: TextStyle(color: sel ? AppColors.primary : Colors.white60, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('ADDRESS LINE'),
                const SizedBox(height: 10),
                TextField(
                  controller: _lineController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration('Flat / House no., Street, Area'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('LANDMARK'),
                const SizedBox(height: 10),
                TextField(
                  controller: _landmarkController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration('e.g. Near Cyber Towers'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('PINCODE'),
                const SizedBox(height: 10),
                TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration('500081').copyWith(counterText: ''),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Set as Default', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('Used automatically in Booking & Shop', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                Switch(
                  value: _isDefault,
                  activeThumbColor: AppColors.onPrimary,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => setState(() { _isDefault = v; _dirty = true; }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: GhostButton(label: 'Cancel', onTap: () => Navigator.of(context).pop())),
              const SizedBox(width: 12),
              Expanded(child: PrimaryButton(label: _isEditing ? 'Save' : 'Add Address', enabled: _dirty && _isValid, onTap: _save)),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            DestructiveButton(label: 'Delete Address', icon: Icons.delete_outline, onTap: _delete),
          ],
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );
}