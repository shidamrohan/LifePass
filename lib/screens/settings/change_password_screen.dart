import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Password Mismatch',
          message: 'New password and confirmation do not match.',
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (context) => SuccessDialog(
          title: 'Password Updated',
          message: 'Your password has been changed successfully.',
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          message: authProvider.error ?? 'Unable to change password.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update your password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Current Password',
                hint: 'Enter current password',
                controller: _oldPasswordController,
                isPassword: true,
                validator: (value) => value == null || value.isEmpty ? 'Current password is required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'New Password',
                hint: 'Enter new password',
                controller: _newPasswordController,
                isPassword: true,
                validator: (value) => value == null || value.isEmpty ? 'New password is required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Confirm New Password',
                hint: 'Confirm new password',
                controller: _confirmPasswordController,
                isPassword: true,
                validator: (value) => value == null || value.isEmpty ? 'Please confirm new password' : null,
              ),
              const SizedBox(height: 28),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) => PrimaryButton(
                  label: 'Change Password',
                  isLoading: authProvider.isLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
