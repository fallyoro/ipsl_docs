import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/core/Responsive.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/view_models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ipsl_docs/src/pages/profile/edit_profile_page.dart';
import 'package:page_transition/page_transition.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _HomeState();
}

class _HomeState extends State<Profile> {
  UserViewModel userViewModel = GetIt.instance<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMobileDevice = Responsive.isMobileDevice(context);

    return Scaffold(
      backgroundColor:
          isDark
              ? AppColors.darkSecondarySystemBackground
              : AppColors.lightSecondarySystemBackground,
      // The constrainedBox make the second container visible
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 280,
              padding: EdgeInsets.only(
                bottom: 44,
                left: 20,
                right: 20,
                top: 50,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                color: AppColors.primaryColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  userViewModel.userNotifier.value?.pictureUrl != null
                      ? CachedNetworkImage(
                        height: 100,
                        imageUrl: userViewModel.userNotifier.value!.pictureUrl!
                            .replaceAll('s96-c', 's400-c'),
                        imageBuilder: (context, imageProvider) {
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: imageProvider,
                          );
                        },
                      )
                      : Icon(
                        Icons.person_outline,
                        size: 100,
                        color: Colors.white,
                      ),

                  // SizedBox(height: 20),
                  ValueListenableBuilder(
                    valueListenable: userViewModel.userNotifier,
                    builder: (context, value, child) {
                      return Text(
                        value!.userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: userViewModel.userNotifier,
                    builder: (context, value, child) {
                      return Text(
                        value!.classe,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      );
                    },
                  ),
                ],
              ),
            ),

            Positioned(
              top: 245,
              left: 0,
              right: 0,
              // bottom: 0,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  // Center what inside
                  alignment: Alignment.center,
                  width: 330,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Contribution",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: userViewModel.userNotifier,
                        builder: (context, value, child) {
                          return Text(
                            value!.numberContribution.toString(),
                            style: TextStyle(
                              fontSize: 50,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            isMobileDevice
                ? Positioned(
                  top: 515,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 300),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                            // maximumSize: const Size(200, 45),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: EditProfilePage(
                                  userName:
                                      userViewModel
                                          .userNotifier
                                          .value!
                                          .userName,
                                  userClass:
                                      userViewModel.userNotifier.value!.classe,
                                ),
                              ),
                            ).then((value) {
                              setState(() {});
                            });
                          },
                          child: Row(
                            spacing: 10,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(FontAwesomeIcons.pen),
                              Text(
                                "Modifier le profil",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                : Container(),
          ],
        ),
      ),
    );
  }
}
