import 'package:flutter/material.dart';

class ModalBottom extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return SizedBox(
                height: 600,
                child: Center(
                  // child: Text('Your modal content goes here'),
                  child: Form(
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Board name",
                          ),
                          onSaved: (String? value) {
                            print("FUCKING HURRAY");
                          },
                        )
                      ],
                    )
                  )
                )
              );
  }
}
