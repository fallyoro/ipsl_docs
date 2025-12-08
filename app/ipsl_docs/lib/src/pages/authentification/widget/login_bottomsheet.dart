import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constant.dart';
import '../../../view_models/user.dart';

void showLoginBottomSheet(BuildContext context) {
  UserViewModel userViewModel = GetIt.I<UserViewModel>();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ListView(
              controller: controller,
              padding: EdgeInsets.all(20),
              children: [
                SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Connectez-vous',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  'Pour continuer, connectez-vous avec votre compte Google.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                ValueListenableBuilder(
                  valueListenable: userViewModel.authState,
                  builder: (context, state, child) {
                    if (state == ViewState.loading) {
                      return Container(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    } else {
                      return SignInButton(
                        Buttons.Google,
                        text: "Se connecter avec google",
                        onPressed: () {
                          final UserViewModel userViewModel =
                              GetIt.I<UserViewModel>();
                          userViewModel.authState.value == ViewState.loading
                              ? null
                              : userViewModel.loginWithGoogle();
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
