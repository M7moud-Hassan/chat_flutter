import 'package:chat_app/chat/presentation/pages/home.page.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:chat_app/core/utils/shared_pref.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';

class Category {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;

  const Category({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class CategoresPage extends StatefulWidget {
  const CategoresPage({super.key});

  @override
  State<CategoresPage> createState() => _CategoresPageState();
}

class _CategoresPageState extends State<CategoresPage> {
  final Color mainGreen = const Color.fromRGBO(31, 44, 51, 1);

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  void _checkFirstTime() async {
    bool isFirstTime = SharedPref.instance.getBool('first_time') ?? true;
    if (isFirstTime) {
      await SharedPref.instance.setBool('first_time', false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTermsDialog();
      });
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: Column(
          children: [
            AppBar(
              title: Text('terms'.tr()),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: PdfViewPinch(
                controller: PdfControllerPinch(
                  document: PdfDocument.openAsset('assets/terms.pdf'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('change_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('العربية'),
              onTap: () {
                context.setLocale(Locale('ar'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('English'),
              onTap: () {
                context.setLocale(Locale('en'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _contactUs() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'e55455531@gmail.com',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('cannot_open_email'.tr())),
      );
    }
  }

  List<Category> _categories(BuildContext context) => [
        Category(
          id: 1,
          title: "personal_status_law".tr(),
          subtitle: "marriage_divorce_alimony_custody".tr(),
          icon: Icons.family_restroom,
        ),
        Category(
          id: 2,
          title: "commercial_law".tr(),
          subtitle: "companies_institutions".tr(),
          icon: Icons.business,
        ),
        Category(
          id: 3,
          title: "civil_law".tr(),
          subtitle: "compensations_claims_settlements_rents_contracts".tr(),
          icon: Icons.description,
        ),
        Category(
          id: 4,
          title: "criminal_law".tr(),
          subtitle: "felonies_misdemeanors".tr(),
          icon: Icons.gavel,
        ),
        Category(
          id: 5,
          title: "administrative_law".tr(),
          subtitle: "complaint_dismissal_appointment".tr(),
          icon: Icons.account_balance,
        ),
        Category(
          id: 6,
          title: "traffic_law".tr(),
          subtitle: "violation_travel_ban".tr(),
          icon: Icons.traffic,
        ),
        Category(
          id: 7,
          title: "execution_cases_individuals_companies".tr(),
          subtitle: "enforcement_of_judgments_individuals_companies".tr(),
          icon: Icons.assignment,
        ),
        Category(
          id: 8,
          title: "contact_us".tr(),
          subtitle: "",
          icon: Icons.contact_mail,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final categories = _categories(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('legal_categories'.tr()),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'terms':
                  _showTermsDialog();
                  break;
                case 'language':
                  _showChangeLanguageDialog();
                  break;
                case 'contact':
                  _contactUs();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'terms',
                child: Text('terms'.tr()),
              ),
              PopupMenuItem(
                value: 'language',
                child: Text('change_language'.tr()),
              ),
              PopupMenuItem(
                value: 'contact',
                child: Text('contact_us'.tr()),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 8,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (category.id != 8) {
                  AppUtils.activeRoom = category.id;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomePage(idCategory: category.id),
                    ),
                  );
                } else {
                  _contactUs();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      mainGreen,
                      mainGreen.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: mainGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        category.id.toString(),
                        style: TextStyle(
                          color: mainGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        category.icon,
                        color: Colors.white.withOpacity(0.8),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 🌍 Language Dialog
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('choose_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('العربية'),
              onTap: () {
                context.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
