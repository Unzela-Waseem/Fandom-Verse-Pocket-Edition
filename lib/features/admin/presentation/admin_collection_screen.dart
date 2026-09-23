import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/media/cloudinary_media_service.dart';
import '../../library/domain/library_models.dart';

enum AdminFieldType { text, multiline, number, toggle }

class AdminField {
  const AdminField(
    this.key,
    this.label, {
    this.type = AdminFieldType.text,
    this.required = true,
    this.defaultBool = false,
  });

  final String key;
  final String label;
  final AdminFieldType type;
  final bool required;
  final bool defaultBool;
}

class AdminCollectionConfig {
  const AdminCollectionConfig({
    required this.collection,
    required this.title,
    required this.primaryField,
    required this.fields,
  });

  final String collection;
  final String title;
  final String primaryField;
  final List<AdminField> fields;

  static const categories = AdminCollectionConfig(
    collection: 'categories',
    title: 'Categories',
    primaryField: 'name',
    fields: [
      AdminField('name', 'Name'),
      AdminField('description', 'Description', type: AdminFieldType.multiline),
      AdminField('icon', 'Icon name', required: false),
      AdminField(
        'active',
        'Active',
        type: AdminFieldType.toggle,
        defaultBool: true,
      ),
    ],
  );
  static const content = AdminCollectionConfig(
    collection: 'content',
    title: 'Fandom content',
    primaryField: 'title',
    fields: [
      AdminField('title', 'Title'),
      AdminField('body', 'Body', type: AdminFieldType.multiline),
      AdminField('summary', 'Summary', type: AdminFieldType.multiline),
      AdminField('creator', 'Creator'),
      AdminField('categoryId', 'Category ID'),
      AdminField('contentType', 'Content type'),
      AdminField('tags', 'Tags (comma separated)', required: false),
      AdminField('imageUrl', 'HTTPS image URL', required: false),
      AdminField('videoUrl', 'HTTPS video URL', required: false),
      AdminField('published', 'Published', type: AdminFieldType.toggle),
      AdminField('trending', 'Featured on home', type: AdminFieldType.toggle),
    ],
  );
  static const events = AdminCollectionConfig(
    collection: 'events',
    title: 'Events',
    primaryField: 'title',
    fields: [
      AdminField('title', 'Title'),
      AdminField('description', 'Description', type: AdminFieldType.multiline),
      AdminField('categoryId', 'Category ID'),
      AdminField('city', 'City'),
      AdminField('venue', 'Venue / address'),
      AdminField('latitude', 'Latitude', type: AdminFieldType.number),
      AdminField('longitude', 'Longitude', type: AdminFieldType.number),
      AdminField('eventDate', 'Date (ISO 8601)'),
      AdminField('ticketLink', 'HTTPS ticket link', required: false),
      AdminField('imageUrl', 'HTTPS image URL', required: false),
    ],
  );
  static const merchandise = AdminCollectionConfig(
    collection: 'merchandise',
    title: 'Merchandise',
    primaryField: 'name',
    fields: [
      AdminField('name', 'Name'),
      AdminField('description', 'Description', type: AdminFieldType.multiline),
      AdminField('price', 'Price', type: AdminFieldType.number),
      AdminField(
        'previousPrice',
        'Previous price',
        type: AdminFieldType.number,
        required: false,
      ),
      AdminField('categoryId', 'Category ID'),
      AdminField('type', 'Type'),
      AdminField('stock', 'Stock', type: AdminFieldType.number),
      AdminField('imageUrl', 'HTTPS image URL', required: false),
      AdminField(
        'active',
        'Active',
        type: AdminFieldType.toggle,
        defaultBool: true,
      ),
    ],
  );
  static const announcements = AdminCollectionConfig(
    collection: 'announcements',
    title: 'Announcements',
    primaryField: 'title',
    fields: [
      AdminField('title', 'Title'),
      AdminField('message', 'Message', type: AdminFieldType.multiline),
      AdminField('published', 'Published', type: AdminFieldType.toggle),
    ],
  );
}

class AdminCollectionScreen extends StatefulWidget {
  const AdminCollectionScreen({super.key, required this.config});

  final AdminCollectionConfig config;

  @override
  State<AdminCollectionScreen> createState() => _AdminCollectionScreenState();
}

class _AdminCollectionScreenState extends State<AdminCollectionScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection(widget.config.collection)
        .orderBy('updatedAt', descending: true)
        .limit(100)
        .snapshots();
    return Scaffold(
      appBar: AppBar(title: Text(widget.config.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(null),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Records could not be loaded.'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final query = _query.toLowerCase();
                final records = snapshot.data!.docs.where((document) {
                  final value = document.data()[widget.config.primaryField];
                  return query.isEmpty ||
                      value.toString().toLowerCase().contains(query);
                }).toList();
                if (records.isEmpty) {
                  return const Center(child: Text('No matching records.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final data = record.data();
                    return Card(
                      child: ListTile(
                        title: Text(
                          data[widget.config.primaryField]?.toString() ??
                              'Untitled',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(record.id),
                        onTap: () => _openEditor(record),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'edit') _openEditor(record);
                            if (action == 'delete') _delete(record);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    QueryDocumentSnapshot<Map<String, dynamic>>? record,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AdminRecordEditor(
        config: widget.config,
        reference: record?.reference,
        initialData: record?.data(),
      ),
    );
  }

  Future<void> _delete(
    QueryDocumentSnapshot<Map<String, dynamic>> record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.delete(record.reference);
      addAdminAudit(
        batch,
        action: 'delete',
        collection: widget.config.collection,
        recordId: record.id,
      );
      await batch.commit();
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Delete failed.')),
        );
      }
    }
  }
}

class _AdminRecordEditor extends StatefulWidget {
  const _AdminRecordEditor({
    required this.config,
    this.reference,
    this.initialData,
  });

  final AdminCollectionConfig config;
  final DocumentReference<Map<String, dynamic>>? reference;
  final Map<String, dynamic>? initialData;

  @override
  State<_AdminRecordEditor> createState() => _AdminRecordEditorState();
}

class _AdminRecordEditorState extends State<_AdminRecordEditor> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _toggles = {};
  final _mediaService = CloudinaryMediaService();
  bool _saving = false;
  String? _uploadingField;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    for (final field in widget.config.fields) {
      final value = widget.initialData?[field.key];
      if (field.type == AdminFieldType.toggle) {
        _toggles[field.key] = value as bool? ?? field.defaultBool;
      } else {
        _controllers[field.key] = TextEditingController(
          text: value is Timestamp
              ? value.toDate().toIso8601String()
              : value?.toString() ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    _mediaService.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving ||
        _uploadingField != null ||
        !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{};
      for (final field in widget.config.fields) {
        if (field.type == AdminFieldType.toggle) {
          data[field.key] = _toggles[field.key] ?? false;
          continue;
        }
        final value = _controllers[field.key]!.text.trim();
        if (field.key == 'tags') {
          data[field.key] = value
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();
        } else if (field.type == AdminFieldType.number) {
          data[field.key] = value.isEmpty ? null : num.parse(value);
        } else if (field.key == 'eventDate') {
          data[field.key] = Timestamp.fromDate(DateTime.parse(value));
        } else {
          data[field.key] = value;
        }
      }
      final user = FirebaseAuth.instance.currentUser!;
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['updatedBy'] = user.uid;
      final reference =
          widget.reference ??
          FirebaseFirestore.instance.collection(widget.config.collection).doc();
      if (widget.reference == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['createdBy'] = user.uid;
      }
      final batch = FirebaseFirestore.instance.batch();
      batch.set(reference, data, SetOptions(merge: true));
      addAdminAudit(
        batch,
        action: widget.reference == null ? 'create' : 'update',
        collection: widget.config.collection,
        recordId: reference.id,
      );
      await batch.commit();
      if (mounted) Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  CloudinaryPurpose? _purposeFor(String field) {
    if (widget.config.collection == 'content') {
      if (field == 'imageUrl') return CloudinaryPurpose.contentImage;
      if (field == 'videoUrl') return CloudinaryPurpose.contentVideo;
    }
    if (widget.config.collection == 'events' && field == 'imageUrl') {
      return CloudinaryPurpose.eventImage;
    }
    if (widget.config.collection == 'merchandise' && field == 'imageUrl') {
      return CloudinaryPurpose.productImage;
    }
    return null;
  }

  Future<void> _uploadMedia(String field, CloudinaryPurpose purpose) async {
    if (_uploadingField != null || _saving) return;
    setState(() {
      _uploadingField = field;
      _uploadProgress = 0;
    });
    try {
      final url = await _mediaService.pickAndUpload(
        purpose: purpose,
        onProgress: (progress) {
          if (mounted) setState(() => _uploadProgress = progress);
        },
      );
      if (url != null && mounted) {
        _controllers[field]!.text = url;
      }
    } on MediaUploadException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media upload failed. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingField = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reference == null ? 'Create record' : 'Edit record'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.config.fields.map((field) {
                if (field.type == AdminFieldType.toggle) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(field.label),
                    value: _toggles[field.key] ?? false,
                    onChanged: (value) =>
                        setState(() => _toggles[field.key] = value),
                  );
                }
                final purpose = _purposeFor(field.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _controllers[field.key],
                        keyboardType: field.type == AdminFieldType.number
                            ? const TextInputType.numberWithOptions(
                                decimal: true,
                              )
                            : null,
                        minLines: field.type == AdminFieldType.multiline
                            ? 3
                            : 1,
                        maxLines: field.type == AdminFieldType.multiline
                            ? 6
                            : 1,
                        decoration: InputDecoration(labelText: field.label),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (field.required && text.isEmpty) {
                            return '${field.label} is required.';
                          }
                          if (text.isNotEmpty &&
                              field.type == AdminFieldType.number &&
                              num.tryParse(text) == null) {
                            return 'Enter a valid number.';
                          }
                          if (text.isNotEmpty &&
                              field.type == AdminFieldType.number) {
                            final number = num.parse(text);
                            if (field.key == 'latitude' &&
                                (number < -90 || number > 90)) {
                              return 'Latitude must be between -90 and 90.';
                            }
                            if (field.key == 'longitude' &&
                                (number < -180 || number > 180)) {
                              return 'Longitude must be between -180 and 180.';
                            }
                            if ((field.key == 'price' ||
                                    field.key == 'previousPrice' ||
                                    field.key == 'stock') &&
                                number < 0) {
                              return 'Enter zero or a positive number.';
                            }
                            if (field.key == 'stock' &&
                                number != number.roundToDouble()) {
                              return 'Stock must be a whole number.';
                            }
                          }
                          if (field.key == 'contentType' &&
                              !ContentType.values.any(
                                (type) => type.name == text,
                              )) {
                            return 'Use: ${ContentType.values.map((type) => type.name).join(', ')}';
                          }
                          if (text.isNotEmpty &&
                              field.key == 'eventDate' &&
                              DateTime.tryParse(text) == null) {
                            return 'Use an ISO date, for example 2026-10-24T18:00:00.';
                          }
                          if (text.isNotEmpty &&
                              (field.key == 'imageUrl' ||
                                  field.key == 'videoUrl' ||
                                  field.key == 'ticketLink')) {
                            final uri = Uri.tryParse(text);
                            if (uri == null ||
                                uri.scheme != 'https' ||
                                uri.host.isEmpty) {
                              return 'Use a valid HTTPS URL.';
                            }
                          }
                          return null;
                        },
                      ),
                      if (purpose != null &&
                          CloudinaryMediaService.isConfigured &&
                          CloudinaryMediaService.isSupportedPlatform) ...[
                        TextButton.icon(
                          onPressed: _uploadingField == null && !_saving
                              ? () => _uploadMedia(field.key, purpose)
                              : null,
                          icon: Icon(
                            field.key == 'videoUrl'
                                ? Icons.video_library_outlined
                                : Icons.add_photo_alternate_outlined,
                          ),
                          label: Text(
                            'Upload ${field.key == 'videoUrl' ? 'video' : 'image'}',
                          ),
                        ),
                        if (_uploadingField == field.key) ...[
                          LinearProgressIndicator(value: _uploadProgress),
                          TextButton(
                            onPressed: _mediaService.cancel,
                            child: const Text('Cancel upload'),
                          ),
                        ],
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving || _uploadingField != null
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving || _uploadingField != null ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

void addAdminAudit(
  WriteBatch batch, {
  required String action,
  required String collection,
  required String recordId,
}) {
  final actor = FirebaseAuth.instance.currentUser!;
  final audit = FirebaseFirestore.instance.collection('audit_logs').doc();
  batch.set(audit, {
    'actorId': actor.uid,
    'actorEmail': actor.email,
    'action': action,
    'collection': collection,
    'recordId': recordId,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
