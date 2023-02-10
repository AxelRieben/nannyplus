import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
// ignore: implementation_imports
import 'package:gettext_i18n/src/gettext_localizations.dart';
import 'package:intl/intl.dart';
import 'package:nannyplus/cubit/statement_list_cubit.dart';
import 'package:nannyplus/data/model/monthly_statement.dart';
import 'package:nannyplus/data/model/yearly_statement.dart';
import 'package:nannyplus/src/constants.dart';
import 'package:nannyplus/src/statement_view/statement_view.dart';
import 'package:nannyplus/src/ui/list_view.dart';
import 'package:nannyplus/src/ui/sliver_curved_persistent_header.dart';
import 'package:nannyplus/src/ui/ui_card.dart';
import 'package:nannyplus/src/ui/view.dart';
import 'package:nannyplus/utils/text_extension.dart';

class StatementListView extends StatelessWidget {
  const StatementListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<StatementListCubit>().loadStatements();

    return BlocBuilder<StatementListCubit, StatementListState>(
      builder: (context, state) {
        return UIView(
          title: Text(
            context.t('Statements'),
          ),
          persistentHeader:
              const UISliverCurvedPersistenHeader(child: Text('')),
          body: UIListView.fromChildren(
            horizontalPadding: kdDefaultPadding,
            children: [
              if (state is StatementListLoaded)
                ...(() sync* {
                  for (final statement in state.statements) {
                    yield _YearlyStatementCard(statement: statement);
                  }
                })(),
            ],
          ),
        );
      },
    );
  }
}

class _YearlyStatementCard extends StatelessWidget {
  const _YearlyStatementCard({
    Key? key,
    required this.statement,
  }) : super(key: key);

  final YearlyStatement statement;

  @override
  Widget build(BuildContext context) {
    return UICard(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${statement.year}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  statement.amount.toStringAsFixed(2),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => openPDF(context, DateTime(statement.year)),
              ),
            ],
          ),
        ),
        const Divider(
          height: 2,
        ),
        ...statement.monthlyStatements.map(
          (statement) => _MonthlyStatementCard(
            statement: statement,
          ),
        ),
      ],
    );
  }

  void openPDF(BuildContext context, DateTime date) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => StatementView(
          type: StatementViewType.yearly,
          date: date,
          gettext: GettextLocalizations.of(context),
          //  invoice,
          //  GettextLocalizations.of(context),
        ),
      ),
    );
  }
}

class _MonthlyStatementCard extends StatelessWidget {
  const _MonthlyStatementCard({
    Key? key,
    required this.statement,
  }) : super(key: key);

  final MonthlyStatement statement;

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMMM').format(statement.date).capitalize();

    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              month,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              statement.amount.toStringAsFixed(2),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => openPDF(context, statement.date),
          ),
        ],
      ),
    );
  }

  void openPDF(BuildContext context, DateTime date) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => StatementView(
          type: StatementViewType.monthly,
          date: date,
          gettext: GettextLocalizations.of(context),
          //  invoice,
          //  GettextLocalizations.of(context),
        ),
      ),
    );
  }
}
