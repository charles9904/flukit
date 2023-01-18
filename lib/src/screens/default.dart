import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class FluDefaultScreen extends StatelessWidget {
  const FluDefaultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FluScreen(
          body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Flu.appSettings.defaultPaddingSize),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Flukit.',
                    style: TextStyle(
                        fontFamily: FluFonts.neptune.name,
                        package: 'flukit',
                        fontWeight: FontWeight.bold,
                        fontSize: Flu.appSettings.headlineFs + 15,
                        color: Flu.theme.primary)),
                const SizedBox(height: 5),
                const Text(
                  'Voluptates ut earum voluptatum dolore sed. Perferendis qui enim aut labore eos. Deleniti quasi possimus molestiae eligendi est et porro et voluptatem. Libero et sunt modi aut quas accusamus fuga excepturi.',
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ));
}
