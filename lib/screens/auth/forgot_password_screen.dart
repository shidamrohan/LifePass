import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _isSubmitted = true;
        });
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Error',
            message: authProvider.error ?? 'Failed to send reset email. Please try again.',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _isSubmitted ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary
                    .withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  Icons.mail_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'Forgot Your Password?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),

          // Email Field
          CustomTextField(
            label: 'Email',
            hint: 'Enter your registered email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Send Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PrimaryButton(
                label: 'Send Reset Link',
                isLoading: authProvider.isLoading,
                onPressed: _submitForm,
              );
            },
          ),
          const SizedBox(height: 20),

          // Back to Login
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Back to Login',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success Icon
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[400]?.withOpacity(0.1),
            ),
            child: Center(
              child: Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green[400],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Title
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          'We\'ve sent a password reset link to:\n${_emailController.text}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.blue[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Please click the link in your email to reset your password. The link will expire in 24 hours.',
            style: TextStyle(
              color: Colors.blue[900],
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Back to Login Button
        PrimaryButton(
          label: 'Back to Login',
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
        const SizedBox(height: 16),

        // Resend Link
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _isSubmitted = false;
              });
            },
            child: Text(
              'Didn\'t receive link? Try again',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
