import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../widgets/animated_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide > 600;

    return CupertinoPageScaffold(
      child: AnimatedBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: AppColors.bgDark.withValues(alpha: 0.85),
              border: null,
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.back, color: AppColors.accent),
                onPressed: () => Navigator.pop(context),
              ),
              largeTitle: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: AppColors.textGold,
                  fontSize: isTablet ? 28 : 22,
                ),
              ),
            ),

            // Header card
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  isTablet ? 40 : 16,
                  16,
                  isTablet ? 40 : 16,
                  8,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent.withValues(alpha: 0.15),
                      AppColors.bgCard,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderGold),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.shield_lefthalf_fill,
                        color: AppColors.accent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OveRune Forging',
                            style: TextStyle(
                              color: AppColors.textGold,
                              fontSize: isTablet ? 17 : 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'We respect your privacy and are committed to protecting your personal data.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isTablet ? 13 : 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sections
            ..._sections(isTablet).map((section) => _buildSection(section, isTablet)),

            SliverToBoxAdapter(child: SizedBox(height: mq.padding.bottom + 40)),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSection(_PolicySection section, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.fromLTRB(
          isTablet ? 40 : 16,
          8,
          isTablet ? 40 : 16,
          0,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCardLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Text(section.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(
                    section.title,
                    style: TextStyle(
                      color: AppColors.textGold,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            // Section body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                section.body,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 14 : 13,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_PolicySection> _sections(bool isTablet) => [
        const _PolicySection(
          icon: '📜',
          title: 'Introduction',
          body:
              'Developer ("us", "we", or "our") operates the OveRune Forging mobile application (hereinafter referred to as the "Service"). This page informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.\n\nWe use your data to provide and improve the Service. By using the Service, you agree to the collection and use of information in accordance with this policy.',
        ),
        const _PolicySection(
          icon: '📖',
          title: 'Definitions',
          body:
              'Service — the OveRune Forging mobile application operated by Developer.\n\nPersonal Data — data about a living individual who can be identified from those data (or from those and other information either in our possession or likely to come into our possession).\n\nUsage Data — data collected automatically either generated by the use of the Service or from the Service infrastructure itself (for example, the duration of a page visit).\n\nCookies — small files stored on your device (computer or mobile device).',
        ),
        const _PolicySection(
          icon: '🗂️',
          title: 'Information Collection and Use',
          body:
              'We collect several different types of information for various purposes to provide and improve our Service to you.\n\nPersonal Data: While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you. This may include, but is not limited to: Cookies and Usage Data.\n\nUsage Data: When you access the Service by or through a mobile device, we may collect certain information automatically, including the type of mobile device you use, your mobile device unique ID, the IP address of your mobile device, your mobile operating system, the type of mobile Internet browser you use, unique device identifiers and other diagnostic data.\n\nTracking & Cookies Data: We use cookies and similar tracking technologies to track the activity on our Service. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent. However, if you do not accept cookies, you may not be able to use some portions of our Service.',
        ),
        const _PolicySection(
          icon: '⚙️',
          title: 'Use of Data',
          body:
              'Service uses the collected data for various purposes:\n\n• To provide and maintain the Service\n• To notify you about changes to our Service\n• To allow you to participate in interactive features of our Service when you choose to do so\n• To provide customer care and support\n• To provide analysis or valuable information so that we can improve the Service\n• To monitor the usage of the Service\n• To detect, prevent and address technical issues',
        ),
        const _PolicySection(
          icon: '🌍',
          title: 'Transfer of Data',
          body:
              'Your information, including Personal Data, may be transferred to — and maintained on — computers located outside of your state, province, country or other governmental jurisdiction where the data protection laws may differ than those from your jurisdiction.\n\nIf you are located outside Seychelles and choose to provide information to us, please note that we transfer the data, including Personal Data, to Seychelles and process it there. Your consent to this Privacy Policy followed by your submission of such information represents your agreement to that transfer.\n\nService will take all steps reasonably necessary to ensure that your data is treated securely and in accordance with this Privacy Policy.',
        ),
        const _PolicySection(
          icon: '⚖️',
          title: 'Disclosure of Data',
          body:
              'Service may disclose your Personal Data in the good faith belief that such action is necessary to:\n\n• Comply with a legal obligation\n• Protect and defend the rights or property of Service\n• Prevent or investigate possible wrongdoing in connection with the Service\n• Protect the personal safety of users of the Service or the public\n• Protect against legal liability\n\nAs a European citizen, under GDPR, you have certain individual rights. You can learn more about these guides in the GDPR Guide.',
        ),
        const _PolicySection(
          icon: '🔒',
          title: 'Security of Data',
          body:
              'The security of your data is important to us but remember that no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.',
        ),
        const _PolicySection(
          icon: '🤝',
          title: 'Service Providers',
          body:
              'We may employ third party companies and individuals to facilitate our Service ("Service Providers"), to provide the Service on our behalf, to perform Service-related services or to assist us in analyzing how our Service is used. These third parties have access to your Personal Data only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.',
        ),
        const _PolicySection(
          icon: '🔗',
          title: 'Links to Other Sites',
          body:
              'Our Service may contain links to other sites that are not operated by us. If you click a third party link, you will be directed to that third party\'s site. We strongly advise you to review the Privacy Policy of every site you visit. We have no control over and assume no responsibility for the content, privacy policies or practices of any third party sites or services.',
        ),
        const _PolicySection(
          icon: '👶',
          title: "Children's Privacy",
          body:
              'Our Service does not address anyone under the age of 18 ("Children"). We do not knowingly collect personally identifiable information from anyone under the age of 18.\n\nIf you are a parent or guardian and you are aware that your Child has provided us with Personal Data, please contact us. If we become aware that we have collected Personal Data from children without verification of parental consent, we take steps to remove that information from our servers.',
        ),
        const _PolicySection(
          icon: '🔄',
          title: 'Changes to This Privacy Policy',
          body:
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. We will let you know via email and/or a prominent notice on our Service, prior to the change becoming effective.\n\nYou are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.',
        ),
      ];
}

class _PolicySection {
  final String icon;
  final String title;
  final String body;
  const _PolicySection({required this.icon, required this.title, required this.body});
}
