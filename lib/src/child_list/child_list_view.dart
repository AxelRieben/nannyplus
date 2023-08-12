import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:intl/intl.dart';
import 'package:nannyplus/cubit/child_list_state.dart';
import 'package:nannyplus/data/model/child.dart';
import 'package:nannyplus/provider/child_list_provider.dart';
import 'package:nannyplus/provider/show_pending_invoice_provider.dart';
import 'package:nannyplus/src/app_settings/app_settings_view.dart';
import 'package:nannyplus/src/child_form/child_form.dart';
import 'package:nannyplus/src/child_list/main_drawer.dart';
import 'package:nannyplus/src/common/loading_indicator.dart';
import 'package:nannyplus/src/constants.dart';
import 'package:nannyplus/src/invoice_settings/invoice_settings_view.dart';
import 'package:nannyplus/src/price_list/price_list_view.dart';
import 'package:nannyplus/src/statement_list_view/statement_list_view.dart';
import 'package:nannyplus/src/tab_view/tab_view.dart';
import 'package:nannyplus/src/ui/list_view.dart';
import 'package:nannyplus/src/ui/sliver_curved_persistent_header.dart';
import 'package:nannyplus/src/ui/view.dart';
import 'package:nannyplus/utils/i18n_utils.dart';
import 'package:nannyplus/utils/prefs_util.dart';
import 'package:nannyplus/utils/snack_bar_util.dart';
import 'package:url_launcher/url_launcher.dart';

class ChildListView extends ConsumerStatefulWidget {
  const ChildListView({super.key});

  @override
  ConsumerState<ChildListView> createState() => _ChildListViewState();
}

class _ChildListViewState extends ConsumerState<ChildListView> {
  bool showArchivedFolders = false;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final showPendingInvoice = ref.watch(showPendingInvoiceProvider);

    final childListState = ref.watch(childListControllerProvider);

    if (childListState is ChildListInitial) {
      ref.read(childListControllerProvider.notifier).loadChildList(
            loadArchivedFolders: showArchivedFolders,
          );
    }

    if (childListState is ChildListLoaded) {
      if (childListState.showOnboarding) {
        Future<void>.delayed(
          Duration.zero,
          () => _showOnboardingDialog(context),
        );
      }
    }

    if (childListState is ChildListError) {
      Future<void>.delayed(
        Duration.zero,
        () => ScaffoldMessenger.of(context).failure(childListState.message),
      );
    }

    return UIView(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.folder),
            label: context.t('Folders'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: context.t('Options'),
          ),
        ],
      ),
      drawer: const MainDrawer(),
      title: const Text(ksAppName),
      persistentHeader: UISliverCurvedPersistenHeader(
        child: _currentIndex == 0
            ? GestureDetector(
                onTap: () {
                  ref.read(showPendingInvoiceProvider.notifier).toggle();
                },
                child: showPendingInvoice
                    ? Text(
                        '${context.t('Pending invoice')} : ${childListState is ChildListLoaded ? childListState.pendingInvoice.toStringAsFixed(2) : '...'}',
                      )
                    : Text(
                        '${context.t('Pending total')} : ${childListState is ChildListLoaded ? childListState.pendingTotal.toStringAsFixed(2) : '...'}',
                      ),
              )
            : Text(
                context.t('Options'),
              ),
      ),
      body: _currentIndex == 0
          ? _buildChildList(context, childListState)
          : _buildTabView(context, childListState),
    );
  }

  Future<void> _showOnboardingDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            context.t('Welcome !'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t(
                  'Since this is the first time you run this app, we inserted some sample data.',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  context.t(
                    'Thanks for using Nanny+ !',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(context.t('Close')),
              onPressed: () async {
                final prefs = await PrefsUtil.getInstance();
                prefs.showOnboarding = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ignore: long-method
  Widget _buildChildList(BuildContext context, ChildListState state) {
    return (state is ChildListLoaded)
        ? UIListView(
            itemBuilder: (context, index) {
              return _ChildListTile(
                index: index,
                state: state,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => TabView(state.children[index].id!),
                    ),
                  );
                  await ref
                      .read(childListControllerProvider.notifier)
                      .loadChildList(
                        loadArchivedFolders: showArchivedFolders,
                      );
                },
                onToggleShowArchivedFolders: () {
                  final child = state.children[index];
                  if (!child.isArchived) {
                    ref
                        .read(childListControllerProvider.notifier)
                        .archive(child);
                    ScaffoldMessenger.of(context)
                        .success(context.t('Archived successfully'));
                  } else {
                    ref
                        .read(childListControllerProvider.notifier)
                        .unarchive(child);
                    ScaffoldMessenger.of(context)
                        .success(context.t('Unarchived successfully'));
                  }
                  ref.read(childListControllerProvider.notifier).loadChildList(
                        loadArchivedFolders: showArchivedFolders,
                      );
                },
              );
            },
            itemCount: state.children.length,
            extraWidget: TextButton(
              onPressed: () {
                setState(() {
                  showArchivedFolders = !showArchivedFolders;
                });
              },
              child: Text(
                context.t(
                  showArchivedFolders
                      ? 'Hide archived folders'
                      : 'Show archived folders',
                ),
              ),
            ),
            onFloatingActionPressed: () async {
              final child = await Navigator.of(context).push<Child>(
                MaterialPageRoute(
                  builder: (context) => const ChildForm(),
                ),
              );
              if (child != null) {
                await ref
                    .read(childListControllerProvider.notifier)
                    .create(child);
              }
            },
          )
        : const LoadingIndicator();
  }

  // ignore: long-method
  Widget _buildTabView(BuildContext context, ChildListState state) {
    return UIListView.fromChildren(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            elevation: 4,
            shape: Theme.of(context).listTileTheme.shape,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const PriceListView(),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: ListTile(
                leading: const Icon(Icons.payment),
                title: Text(
                  context.t('Price list'),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            elevation: 4,
            shape: Theme.of(context).listTileTheme.shape,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const AppSettingsView(),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: ListTile(
                leading: const Icon(Icons.app_settings_alt),
                title: Text(
                  context.t('Application settings'),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            elevation: 4,
            shape: Theme.of(context).listTileTheme.shape,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const InvoiceSettingsView(),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: Text(
                  context.t('Invoice settings'),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            elevation: 4,
            shape: Theme.of(context).listTileTheme.shape,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const StatementListView(),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: ListTile(
                leading: const Icon(Icons.description),
                title: Text(
                  context.t('Statements'),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChildListTile extends ConsumerWidget {
  const _ChildListTile({
    required this.index,
    required this.state,
    required this.onToggleShowArchivedFolders,
    this.onTap,
  });

  final ChildListLoaded state;
  final int index;
  final void Function()? onTap;
  final void Function() onToggleShowArchivedFolders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = state.children[index];
    final serviceInfo = state.servicesInfo[child.id];
    final lastEntry = serviceInfo != null
        ? (serviceInfo.lastEnty!.isBefore(
            DateTime.now().subtract(
              const Duration(days: 7),
            ),
          )
            ? DateFormat.yMd(I18nUtils.localeString)
                .format(serviceInfo.lastEnty!)
            : DateFormat(DateFormat.WEEKDAY, I18nUtils.localeString)
                .format(serviceInfo.lastEnty!))
        : '...';
    final pendingTotal = serviceInfo != null
        ? serviceInfo.pendingTotal.toStringAsFixed(2)
        : '0.00';
    final pendingInvoice = serviceInfo != null
        ? serviceInfo.pendingInvoice.toStringAsFixed(2)
        : '0.00';

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        elevation: 4,
        shape: Theme.of(context).listTileTheme.shape,
        child: GestureDetector(
          onTap: child.isArchived ? null : onTap,
          behavior: HitTestBehavior.opaque,
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.phone,
                    color: child.hasPhoneNumber
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                  ),
                  onPressed: () {
                    child.hasPhoneNumber
                        ? launchUrl(Uri.parse('tel://${child.phoneNumber}'))
                        : ScaffoldMessenger.of(context).failure(
                            context.t('No phone number'),
                          );
                  },
                ),
              ],
            ),
            title: Text(
              child.displayName,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontStyle:
                        child.isArchived ? FontStyle.italic : FontStyle.normal,
                    color: child.isArchived
                        ? Colors.grey
                        : (state.invoicesInfo.contains(child.id)
                            ? Colors.red
                            : null),
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.hasAllergies
                      ? child.allergies!
                      : context.t('No known allergies'),
                ),
                Text(
                  '${context.t('Last entry')} : $lastEntry',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                ),
                Text(
                  '${context.t('Pending invoice')} : $pendingInvoice',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(pendingTotal),
                ),
                PopupMenuButton(
                  onSelected: (value) async {
                    switch (value) {
                      case 1:
                        if (!child.isArchived &&
                            serviceInfo?.pendingTotal != 0) {
                          ScaffoldMessenger.of(context).failure(
                            context.t(
                              'There are existing services for this child',
                            ),
                          );
                        } else {
                          final archive = await _showConfirmationDialog(
                            context,
                            child.isArchived
                                ? context.t(
                                    'Are you sure you want to unarchive this folder ?',
                                  )
                                : context.t(
                                    'Are you sure you want to archive this folder ?',
                                  ),
                          );
                          if (archive ?? false) {
                            onToggleShowArchivedFolders();
                          }
                        }
                        break;
                      case 2:
                        if (serviceInfo != null) {
                          ScaffoldMessenger.of(context).failure(
                            context.t(
                              'There are existing services for this child',
                            ),
                          );
                        } else {
                          final delete = await _showConfirmationDialog(
                            context,
                            context.t(
                              "Are you sure you want to delete this child's folder ?",
                            ),
                          );
                          if (delete ?? false) {
                            await ref
                                .read(childListControllerProvider.notifier)
                                .delete(child);
                            ScaffoldMessenger.of(context).success(
                              context.t('Removed successfully'),
                            );
                          }
                        }
                        break;
                      case 3:
                        final clone = await Navigator.of(context).push<Child>(
                          MaterialPageRoute<Child>(
                            builder: (context) => ChildForm(
                              childToClone: child,
                            ),
                          ),
                        );
                        if (clone != null) {
                          await ref
                              .read(childListControllerProvider.notifier)
                              .create(clone);
                        }

                        break;
                    }
                  },
                  padding: EdgeInsets.zero,
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 3,
                        child: ListTile(
                          leading: const Icon(
                            Icons.copy,
                            color: kcAlmostBlack,
                          ),
                          title: Text(
                            context.t('Clone folder'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: ListTile(
                          leading: const Icon(
                            Icons.hide_source_outlined,
                            color: kcAlmostBlack,
                          ),
                          title: Text(
                            child.isArchived
                                ? context.t('Unarchive folder')
                                : context.t('Archive folder'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        enabled: !child.isArchived,
                        child: ListTile(
                          leading: Icon(
                            Icons.delete_forever_outlined,
                            color: !child.isArchived &&
                                    !state.servicesInfo.containsKey(child.id)
                                ? kcDangerColor
                                : null,
                          ),
                          title: Text(
                            context.t('Delete'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String message,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(context.t('Delete')),
          content: Text(message),
          actions: [
            TextButton(
              child: Text(context.t('Yes')),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text(context.t('No')),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }
}
