import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/datasources/member_remote_datasource.dart';

import '../../../core/components/buttons.dart';
import '../../../core/components/custom_date_picker.dart';
import '../../../core/components/spaces.dart';

class MemberFormDialog extends StatefulWidget {
  const MemberFormDialog({super.key});

  @override
  State<MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<MemberFormDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final parsed = _dobController.text.isNotEmpty
        ? DateTime.tryParse(_dobController.text.trim())
        : null;
    final initial =
        parsed == null ? DateTime(now.year - 20, now.month, now.day) : parsed;
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_dobController.text.isEmpty) {
      setState(() {
        _error = 'Tanggal lahir harus diisi.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final result = await MemberRemoteDatasource().createMember(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
    );

    if (!mounted) return;

    result.fold(
      (message) {
        setState(() {
          _isSubmitting = false;
          _error = message;
        });
      },
      (_) {
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tambah Member',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
            IconButton(
              icon: Assets.icons.cancel
                  .svg(color: AppColors.grey, height: 32, width: 32),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldRow(
                    label: 'Nama',
                    child: TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Masukkan nama lengkap'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SpaceHeight(24),
                  _FieldRow(
                    label: 'Email',
                    child: TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration('Masukkan email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }
                        final emailRegex =
                            RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SpaceHeight(24),
                  _FieldRow(
                    label: 'Telepon',
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: _inputDecoration('Masukkan nomor telepon'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nomor telepon wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SpaceHeight(24),
                  _FieldRow(
                    label: 'Tanggal Lahir',
                    child: TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      decoration:
                          _inputDecoration('Pilih tanggal lahir').copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today_outlined),
                          onPressed: _pickDate,
                        ),
                      ),
                      onTap: _pickDate,
                    ),
                  ),
                  const SpaceHeight(24),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Button.outlined(
                          label: 'Batal',
                          color: AppColors.white,
                          borderColor: AppColors.grey,
                          textColor: AppColors.grey,
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isSubmitting
                            ? Container(
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                ),
                              )
                            : Button.filled(
                                label: 'Simpan',
                                color: AppColors.success,
                                onPressed: _submit,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldRow({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 4, child: child),
      ],
    );
  }
}
