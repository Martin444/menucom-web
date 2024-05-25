import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/pu_colors.dart';

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
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
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
                          labelText: 'Ingresá tu número de legajo',
                          controller: nameControl,
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
                          onPressed: () {
                            keyName.currentState?.validate();
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
    );
  }
}
