// ignore_for_file: public_member_api_docs, sort_constructors_first, argument_type_not_assignable
import 'dart:convert';

import 'package:flutter/widgets.dart';

@immutable
class Document {
  const Document({
    required this.id,
    required this.childId,
    required this.label,
    required this.path,
  });
  factory Document.fromJson(String source) =>
      Document.fromMap(json.decode(source));

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id']?.toInt() ?? 0,
      childId: map['childId']?.toInt() ?? 0,
      label: map['label'] ?? '',
      path: map['path'] ?? '',
    );
  }
  final int id;
  final int childId;
  final String label;
  final String path;

  Document copyWith({
    int? id,
    int? childId,
    String? label,
    String? path,
  }) {
    return Document(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      label: label ?? this.label,
      path: path ?? this.path,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'childId': childId,
      'label': label,
      'path': path,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Document(id: $id, childId: $childId, label: $label, path: $path)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Document &&
        other.id == id &&
        other.childId == childId &&
        other.label == label &&
        other.path == path;
  }

  @override
  int get hashCode {
    return id.hashCode ^ childId.hashCode ^ label.hashCode ^ path.hashCode;
  }
}
