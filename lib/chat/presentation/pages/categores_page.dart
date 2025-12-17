import 'package:chat_app/chat/presentation/pages/home.page.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:easy_localization/easy_localization.dart'
    show StringTranslateExtension;
import 'package:flutter/material.dart';

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

class CategoresPage extends StatelessWidget {
  CategoresPage({super.key});

  final List<Category> categories = [
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
  ];

  final Color mainGreen = const Color.fromRGBO(31, 44, 51, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('legal_categories'.tr()),
        centerTitle: true,
        backgroundColor: mainGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: () {
                AppUtils.activeRoom = category.id;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(idCategory: category.id),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
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
                padding: const EdgeInsets.all(12),
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
                    Flexible(
                      child: Text(
                        category.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        category.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
}
