import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

class LocalizationsEnabledWidget extends StatelessWidget {
  const LocalizationsEnabledWidget(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: const Locale('fr'),
      delegates: [
        GettextLocalizationsDelegate(defaultLanguage: 'fr'),
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      child: child,
    );
  }
}
