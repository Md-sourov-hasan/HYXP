import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawiisaac/core/utils/constants/colors.dart';
import 'package:hawiisaac/features/profile/controller/privacy_policy_controller.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrivacyPolicyController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, controller),
            const SizedBox(height: 6),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _SectionTitle('Privacy Policy'),
                    SizedBox(height: 8),
                    _BodyText(
                      'This Privacy Policy describes how we collect, use, and protect your information when you use the app. '
                      'By using the app, you agree to the collection and use of information in accordance with this policy.',
                    ),
                    SizedBox(height: 18),

                    _SectionTitle('1. Information We Collect'),
                    SizedBox(height: 8),
                    _BodyText(
                      '- Account information (e.g., name, email)\n'
                      '- Profile data you provide (e.g., photo, bio)\n'
                      '- App usage information (e.g., screens viewed, feature interactions)',
                    ),
                    SizedBox(height: 18),

                    _SectionTitle('2. How We Use Information'),
                    SizedBox(height: 8),
                    _BodyText(
                      '- Provide and improve app features\n'
                      '- Personalize your experience\n'
                      '- Communicate important updates\n'
                      '- Maintain security and prevent fraud',
                    ),
                    SizedBox(height: 18),

                    _SectionTitle('3. Sharing of Information'),
                    SizedBox(height: 8),
                    _BodyText(
                      'We do not sell your personal information. We may share information only when required to provide services, '
                      'comply with legal obligations, or protect the rights and safety of users.',
                    ),
                    SizedBox(height: 18),

                    _SectionTitle('4. Data Security'),
                    SizedBox(height: 8),
                    _BodyText(
                      'We use reasonable safeguards to protect your data. However, no method of transmission over the Internet '
                      'or electronic storage is 100% secure.',
                    ),
                    SizedBox(height: 18),

                    _SectionTitle('5. Your Choices'),
                    SizedBox(height: 8),
                    _BodyText(
                      'You can review or update certain profile information from your Profile settings. You may also log out '
                      'or request account deletion where available.',
                    ),
                    SizedBox(height: 18),

                    _SectionTitle('6. Changes to This Policy'),
                    SizedBox(height: 8),
                    _BodyText(
                      'We may update this Privacy Policy from time to time. Changes will be reflected in this screen.',
                    ),
                    SizedBox(height: 18),

                    _SectionTitle('7. Contact Us'),
                    SizedBox(height: 8),
                    _BodyText(
                      'If you have questions about this Privacy Policy, please contact support.',
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    PrivacyPolicyController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: controller.onBack,
              icon: Icon(
                Icons.chevron_left,
                size: 28,
                color: AppColors.blackColor,
              ),
            ),
          ),
          Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        height: 1.45,
        color: Color(0xFF6F6F6F),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

