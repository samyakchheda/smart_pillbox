import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:home/screens/ai/chat_screen.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:home/widgets/common/my_snack_bar.dart';

class ContactUsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ContactUsScreen({super.key, required this.onBack});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  bool _isHovered = false;

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      mySnackBar(context, "Could not launch $url".tr(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: AppColors.buttonColor),
                  onPressed: widget.onBack,
                ),
                Expanded(
                  child: Text(
                    "Contact Us".tr(),
                    textAlign: TextAlign.center,
                    style: AppFonts.headline.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.15),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Card(
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 6,
              shadowColor: AppColors.textSecondary.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Get in Touch".tr(),
                      style: AppFonts.subHeadline.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: 10),
                    Text(
                      "We’re here to help—reach out anytime.".tr(),
                      style: AppFonts.bodyText.copyWith(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildContactCard(
                  icon: Icons.email_outlined,
                  title: "Email Us".tr(),
                  subtitle: "smartdose.care@gmail.com",
                  onTap: () => _launchUrl(
                      'mailto:smartdose.care@gmail.com?subject=Contact%20Us'),
                ),
                _buildContactCard(
                  icon: Icons.phone_outlined,
                  title: "Call Us".tr(),
                  subtitle: "+91 123 456 7890",
                  onTap: () => _launchUrl('tel:+911234567890'),
                ),
                _buildContactCard(
                  icon: Icons.chat_bubble_outline,
                  title: "Live Chat".tr(),
                  subtitle: "Chat with us now".tr(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const ChatScreen(),
                    ),
                  ),
                ),
                _buildContactCard(
                  icon: Icons.location_on_outlined,
                  title: "Visit Us".tr(),
                  subtitle: "SVKM's SBMPCOE, Vile Parle, Mumbai",
                  onTap: () => _launchUrl(
                      'https://www.google.com/maps/search/?api=1&query=SVKM"s Shri Bhagubhai Mafatlal Polytechnic and College of Engineering'),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? AppColors.buttonColor
                  : AppColors.textPlaceholder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.buttonColor.withOpacity(0.3)
                    : AppColors.textSecondary.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: _isHovered
                ? LinearGradient(
                    colors: [
                      AppColors.cardBackground.withOpacity(0.9),
                      AppColors.cardBackground,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSmallScreen ? 28 : 36,
                color: AppColors.buttonColor,
              ).animate().scale(delay: 100.ms, duration: 300.ms),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFonts.subHeadline.copyWith(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppFonts.bodyText.copyWith(
                  fontSize: isSmallScreen ? 12 : 13,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
