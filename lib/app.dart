import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:nannyplus/cubit/child_list_cubit.dart';
import 'package:nannyplus/cubit/prestation_list_cubit.dart';
import 'package:nannyplus/cubit/price_list_cubit.dart';
import 'package:nannyplus/data/children_repository.dart';
import 'package:nannyplus/data/prestations_repository.dart';
import 'package:nannyplus/data/prices_repository.dart';
import 'package:provider/provider.dart';

import 'views/child_list_view.dart';

class NannyPlusApp extends StatelessWidget {
  const NannyPlusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<ChildListCubit>(
          create: (context) => ChildListCubit(const ChildrenRepository()),
        ),
        BlocProvider<PriceListCubit>(
          create: (context) => PriceListCubit(const PricesRepository()),
        ),
        BlocProvider<PrestationListCubit>(
          create: (context) =>
              PrestationListCubit(const PrestationsRepository()),
        ),
      ],
      child: MaterialApp(
        home: const ChildListView(),
        theme: ThemeData(),
        darkTheme: ThemeData.dark(),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: [
          GettextLocalizationsDelegate(defaultLanguage: 'fr'),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeListResolutionCallback: (locales, supportedLocales) {
          if (locales != null) {
            for (var locale in locales) {
              var supportedLocale = supportedLocales.where((element) =>
                  element.languageCode == locale.languageCode &&
                  element.countryCode == locale.countryCode);
              if (supportedLocale.isNotEmpty) {
                return supportedLocale.first;
              }
              supportedLocale = supportedLocales.where(
                  (element) => element.languageCode == locale.languageCode);
              if (supportedLocale.isNotEmpty) {
                return supportedLocale.first;
              }
            }
          }
          return null;
        },
      ),
    );
  }
}
