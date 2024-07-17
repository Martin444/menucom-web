import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickme_up_web/core/config.dart';
import 'package:pickme_up_web/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/formaters/upercase_first_letter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  TextEditingController nameControl = TextEditingController();
  var keyName = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PUColors.primaryColor,
      body: Stack(
        children: [
          const BackgroundCircles(
            withBlur: true,
          ),
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: double.infinity,
                    ),
                    child: Form(
                      key: keyName,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PUInput(
                              labelText: 'Ingresá un nombre de invitado',
                              controller: nameControl,
                              textInputType: TextInputType.name,
                              formaters: [UppercaseFirstLetterFormatter()],
                              validator: (value) {
                                if (value?.isEmpty ?? false) {
                                  return 'Este campo es requerido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ButtonPrimary(
                              title: 'Ingresar',
                              onPressed: () async {
                                var isValid = keyName.currentState?.validate();
                                if (isValid ?? false) {
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'legajo', nameControl.text);
                                  NAME_USER = nameControl.text;
                                  Get.toNamed(PURoutes.HOME);
                                }
                              },
                              load: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
