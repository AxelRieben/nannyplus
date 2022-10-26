import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:intl/intl.dart';
import 'package:nannyplus/cubit/file_list_cubit.dart';
import 'package:nannyplus/cubit/settings_cubit.dart';
import 'package:nannyplus/data/model/child.dart';
import 'package:nannyplus/data/model/document.dart';
import 'package:nannyplus/src/constants.dart';
import 'package:nannyplus/src/ui/list_view.dart';
import 'package:nannyplus/src/ui/sliver_curved_persistent_header.dart';
import 'package:nannyplus/src/ui/view.dart';
import 'package:nannyplus/utils/i18n_utils.dart';
import 'package:open_file_plus/open_file_plus.dart';

class NewChildForm extends StatelessWidget {
  const NewChildForm({
    Key? key,
    this.child,
  }) : super(key: key);

  final Child? child;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();
    context.read<FileListCubit>().loadFiles(child?.id ?? 0);

    return FormBuilder(
      key: formKey,
      initialValue: {
        'firstName': child?.firstName,
        'lastName': child?.lastName,
        'birthdate': child?.birthdate != null
            ? DateFormat('yyyy-MM-dd').parse(child!.birthdate!)
            : null,
        'phoneNumber': child?.phoneNumber,
        'parentsName': child?.parentsName,
        'address': child?.address,
        'allergies': child?.allergies,
        'labelForPhoneNumber2': child?.labelForPhoneNumber2,
        'phoneNumber2': child?.phoneNumber2,
        'labelForPhoneNumber3': child?.labelForPhoneNumber3,
        'phoneNumber3': child?.phoneNumber3,
        'freeText': child?.freeText,
      },
      child: UIView(
        title: Text(
          child != null ? context.t('Edit Child') : context.t('Add Child'),
        ),
        persistentHeader: const UISliverCurvedPersistenHeader(
          child: Text(''),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              onPressed: () {
                formKey.currentState!.save();
                if (formKey.currentState!.validate()) {
                  final map =
                      Map<String, dynamic>.from(formKey.currentState!.value);
                  if (map['birthdate'] != null) {
                    map['birthdate'] = DateFormat('yyyy-MM-dd')
                        .format(map['birthdate'] as DateTime);
                  }
                  final data = Child.fromMap(map);

                  Navigator.of(context).pop(data);
                }
              },
              icon: const Icon(Icons.save, color: kcOnPrimaryColor),
            ),
          ),
        ],
        body: UIListView.fromChildren(
          horizontalPadding: kdDefaultPadding,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: kdDefaultPadding),
              child: Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      validator: (value) => (value == null) || (value.isEmpty)
                          ? context.t('Please entrer the first name')
                          : null,
                      name: 'firstName',
                      decoration: InputDecoration(
                        labelText: context.t('First name'),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      autocorrect: false,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {
                        context.read<SettingsCubit>().setLine1(value);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'lastName',
                      validator: (value) => (value == null) || (value.isEmpty)
                          ? context.t('Please entrer the last name')
                          : null,
                      decoration: InputDecoration(
                        labelText: context.t('Last name'),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      autocorrect: false,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: FormBuilderDateTimePicker(
                      name: 'birthdate',
                      decoration: InputDecoration(
                        labelText: context.t('Birthdate'),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                      inputType: InputType.date,
                      format: DateFormat.yMMMMd(I18nUtils.locale),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FormBuilderTextField(
                name: 'allergies',
                decoration: InputDecoration(
                  labelText: context.t('Allergies'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FormBuilderTextField(
                validator: (value) => (value == null) || (value.isEmpty)
                    ? context.t('Please enter the parents name')
                    : null,
                name: 'parentsName',
                decoration: InputDecoration(
                  labelText: context.t('Parents name'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                autocorrect: false,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FormBuilderTextField(
                validator: (value) => (value == null) || (value.isEmpty)
                    ? context.t('Please enter the parents address')
                    : null,
                minLines: 2,
                maxLines: 2,
                name: 'address',
                decoration: InputDecoration(
                  labelText: context.t('Address'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FormBuilderTextField(
                name: 'phoneNumber',
                decoration: InputDecoration(
                  labelText: context.t('Phone number'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                autocorrect: false,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null) || (value.isEmpty)
                    ? context.t('Please enter the phone number')
                    : null,
              ),
            ),

            ///* Phonenumber 2 */

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FormBuilderTextField(
                name: 'labelForPhoneNumber2',
                decoration: InputDecoration(
                  labelText: context.t('Label for phone number {0}', args: [2]),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                autocorrect: false,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                validator: (value) {
                  final labelIsEmpty = value?.isEmpty ?? true;
                  final valueIsEmpty = formKey.currentState!
                          .fields['phoneNumber2']!.value?.isEmpty ??
                      true;

                  return labelIsEmpty && !valueIsEmpty
                      ? context.t(
                          'Please enter the label for phone number {0}',
                          args: [2],
                        )
                      : null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FormBuilderTextField(
                name: 'phoneNumber2',
                decoration: InputDecoration(
                  labelText: context.t('Phone number {0}', args: [2]),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                autocorrect: false,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final labelEmpty = formKey.currentState!
                          .fields['labelForPhoneNumber2']!.value?.isEmpty ??
                      true;
                  final valueEmpty = value?.isEmpty ?? true;

                  return (!labelEmpty && valueEmpty)
                      ? context.t(
                          'Please enter the phone number {0}',
                          args: [2],
                        )
                      : null;
                },
              ),
            ),

            ///* Phonenumber 3 */

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FormBuilderTextField(
                name: 'labelForPhoneNumber3',
                decoration: InputDecoration(
                  labelText: context.t('Label for phone number {0}', args: [3]),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                autocorrect: false,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                validator: (value) {
                  final labelIsEmpty = value?.isEmpty ?? true;
                  final valueIsEmpty = formKey.currentState!
                          .fields['phoneNumber3']!.value?.isEmpty ??
                      true;

                  return labelIsEmpty && !valueIsEmpty
                      ? context.t(
                          'Please enter the label for phone number {0}',
                          args: [3],
                        )
                      : null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FormBuilderTextField(
                name: 'phoneNumber3',
                decoration: InputDecoration(
                  labelText: context.t('Phone number {0}', args: [3]),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                autocorrect: false,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final labelEmpty = formKey.currentState!
                          .fields['labelForPhoneNumber3']!.value?.isEmpty ??
                      true;
                  final valueEmpty = value?.isEmpty ?? true;

                  return (!labelEmpty && valueEmpty)
                      ? context.t(
                          'Please enter the phone number {0}',
                          args: [3],
                        )
                      : null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FormBuilderTextField(
                minLines: 3,
                maxLines: 3,
                name: 'freeText',
                decoration: InputDecoration(
                  labelText: context.t('Free text'),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            BlocBuilder<FileListCubit, FileListState>(
              builder: (builder, state) {
                return state is FileListLoaded
                    ? _DocumentList(child: child, documents: state.files)
                    : Container();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: () async {
                  final file = await openFileChooser();
                  if (file != null) {
                    context.read<FileListCubit>().addFile(child?.id ?? 0, file);
                  }
                },
                child: Text(context.t('Add a document')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File?> openFileChooser() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);

      return file;
    } else {
      return null;
    }
  }
}

class _DocumentList extends StatelessWidget {
  const _DocumentList({
    required Iterable<Document> documents,
    required Child? child,
    Key? key,
  })  : _documents = documents,
        _child = child,
        super(key: key);

  final Child? _child;
  final Iterable<Document> _documents;

  @override
  Widget build(BuildContext context) {
    if (_documents.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.t("Documents"),
          style: const TextStyle(
            fontSize: 0.75 * 16,
          ),
        ),
        ..._documents
            .map(
              (file) => Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      OpenFile.open(file.path);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                      child: Text(
                        file.label,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: () async {
                      context
                          .read<FileListCubit>()
                          .removeFile(_child?.id ?? 0, file);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            )
            .toList(),
      ],
    );
  }
}
