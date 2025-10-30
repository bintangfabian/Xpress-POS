import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/datasources/member_remote_datasource.dart';
import 'package:xpress/data/models/response/member_response_model.dart';
import 'package:xpress/data/models/response/member_detail_response_model.dart';

import '../../../core/components/buttons.dart';
import '../../../core/components/custom_date_picker.dart';
import '../../../core/components/spaces.dart';

class MemberEditDialog extends StatefulWidget {
  final Member member;

  const MemberEditDialog({
    super.key,
    required this.member,
  });

  @override
  State<MemberEditDialog> createState() => _MemberEditDialogState();
}

class _MemberEditDialogState extends State<MemberEditDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMemberDetail();
  }

  Future<void> _loadMemberDetail() async {
    if (widget.member.id == null) {
      _populateBasicFields();
      return;
    }

    final result =
        await MemberRemoteDatasource().getMemberDetail(widget.member.id!);
    result.fold(
      (error) {
        // If detail fetch fails, use basic member data
        _populateBasicFields();
      },
      (detailResponse) {
        if (detailResponse.data != null) {
          _populateDetailFields(detailResponse.data!);
        } else {
          _populateBasicFields();
        }
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateBasicFields() {
    _nameController.text = widget.member.name ?? '';
    _emailController.text = widget.member.email ?? '';
    _phoneController.text = widget.member.phone ?? '';
    _dobController.text = widget.member.dateOfBirth ?? '';
    _addressController.text = '';
  }

  void _populateDetailFields(MemberDetail detail) {
    _nameController.text = detail.name ?? '';
    _emailController.text = detail.email ?? '';
    _phoneController.text = detail.phone ?? '';
    _dobController.text = detail.dateOfBirth ?? '';
    _addressController.text = detail.address ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final parsed = _dobController.text.isNotEmpty
        ? DateTime.tryParse(_dobController.text.trim())
        : null;
    final initial = parsed ?? DateTime(now.year - 20, now.month, now.day);
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

    final result = await MemberRemoteDatasource().updateMember(
      id: widget.member.id!,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
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
            const Text('Edit Member',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
            IconButton(
              icon: Assets.icons.cancel.svg(
                  colorFilter:
                      const ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
                  height: 32,
                  width: 32),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: _isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              : Form(
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
                            decoration:
                                _inputDecoration('Masukkan nama lengkap'),
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
                            decoration:
                                _inputDecoration('Masukkan nomor telepon'),
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
                          label: 'Alamat',
                          child: TextFormField(
                            controller: _addressController,
                            decoration: _inputDecoration('Masukkan alamat'),
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            minLines: 1,
                          ),
                        ),
                        const SpaceHeight(24),
                        _FieldRow(
                          label: 'Tanggal Lahir',
                          child: TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            decoration: _inputDecoration('Pilih tanggal lahir')
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today_outlined),
                                onPressed: _pickDate,
                              ),
                            ),
                            onTap: _pickDate,
                          ),
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      actions: [
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
                        color: AppColors.primary,
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
                      label: 'Update',
                      color: AppColors.primary,
                      onPressed: _submit,
                    ),
            ),
          ],
        ),
      ],
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
