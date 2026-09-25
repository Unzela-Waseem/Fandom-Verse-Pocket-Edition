import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/media/cloudinary_media_service.dart';
import '../../library/domain/library_models.dart';

enum AdminFieldType {
  text,
  multiline,
  number,
  toggle,
  categoryPicker,
  datePicker,
}

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
    this.enablePriceDropTrigger = false,
  });

  final String collection;
  final String title;
  final String primaryField;
  final List<AdminField> fields;
  final bool enablePriceDropTrigger;

  static const categories = AdminCollectionConfig(
    collection: 'categories',
    title: 'Categories',
    primaryField: 'name',
    fields: [
      AdminField('name', 'Name'),
      AdminField('description', 'Description', type: AdminFieldType.multiline),
      AdminField('icon', 'Icon name', required: false),
      AdminField('imageUrl', 'HTTPS image URL', required: false),
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
      AdminField('body', 'Body (or description)', type: AdminFieldType.multiline, required: false),
      AdminField('summary', 'Summary', type: AdminFieldType.multiline, required: false),
      AdminField('creator', 'Creator'),
      AdminField('categoryId', 'Category', type: AdminFieldType.categoryPicker),
      AdminField('contentType', 'Content type (e.g. video, story, news)'),
      AdminField('tags', 'Tags (comma separated)', required: false),
      AdminField('imageUrl', 'HTTPS image URL (optional if video)', required: false),
      AdminField('videoUrl', 'HTTPS video URL', required: false),
      AdminField(
        'published',
        'Published (visible to fans)',
        type: AdminFieldType.toggle,
        defaultBool: true,
      ),
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
      AdminField('categoryId', 'Category', type: AdminFieldType.categoryPicker),
      AdminField('city', 'City'),
      AdminField('venue', 'Venue / address'),
      AdminField('latitude', 'Latitude', type: AdminFieldType.number),
      AdminField('longitude', 'Longitude', type: AdminFieldType.number),
      AdminField('eventDate', 'Event date', type: AdminFieldType.datePicker),
      AdminField('ticketLink', 'HTTPS ticket link', required: false),
      AdminField('imageUrl', 'HTTPS image URL', required: false),
    ],
  );

  static const merchandise = AdminCollectionConfig(
    collection: 'merchandise',
    title: 'Merchandise',
    primaryField: 'name',
    enablePriceDropTrigger: true,
    fields: [
      AdminField('name', 'Name'),
      AdminField('description', 'Description', type: AdminFieldType.multiline),
      AdminField('price', 'Price', type: AdminFieldType.number),
      AdminField(
        'previousPrice',
        'Previous price (for price-drop notification)',
        type: AdminFieldType.number,
        required: false,
      ),
      AdminField('categoryId', 'Category', type: AdminFieldType.categoryPicker),
      AdminField('type', 'Type (apparel / collectible / digital)'),
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
      AdminField(
        'published',
        'Published (visible to all fans)',
        type: AdminFieldType.toggle,
      ),
    ],
  );
}

// ── Collection List Screen ────────────────────────────────────────────────────

class AdminCollectionScreen extends StatefulWidget {
  const AdminCollectionScreen({super.key, required this.config});

  final AdminCollectionConfig config;

  @override
  State<AdminCollectionScreen> createState() => _AdminCollectionScreenState();
}

class _AdminCollectionScreenState extends State<AdminCollectionScreen> {
  String _query = '';
  // Pagination: load 20 at a time.
  static const _pageSize = 20;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _records = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection(widget.config.collection)
          .orderBy('updatedAt', descending: true)
          .limit(_pageSize);
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      final snapshot = await query.get();
      final docs = snapshot.docs;
      if (docs.length < _pageSize) _hasMore = false;
      if (docs.isNotEmpty) _lastDocument = docs.last;
      _records.addAll(docs);
    } catch (_) {
      // handled by showing existing records
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    _records.clear();
    _lastDocument = null;
    _hasMore = true;
    await _loadPage();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    final filtered = query.isEmpty
        ? _records
        : _records.where((doc) {
            final value = doc.data()[widget.config.primaryField];
            return value.toString().toLowerCase().contains(query);
          }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.config.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _openEditor(null);
          await _refresh();
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search',
                ),
              ),
            ),
            Expanded(
              child: _loading && _records.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? const Center(child: Text('No matching records.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: filtered.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filtered.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: TextButton.icon(
                              onPressed: _loading ? null : _loadPage,
                              icon: _loading
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.expand_more),
                              label: const Text('Load more'),
                            ),
                          );
                        }
                        final record = filtered[index];
                        final data = record.data();
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              data[widget.config.primaryField]?.toString() ??
                                  'Untitled',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.id,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                if (data['updatedAt'] is Timestamp)
                                  Text(
                                    _formatTs(data['updatedAt'] as Timestamp),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () async {
                              await _openEditor(record);
                              await _refresh();
                            },
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) async {
                                if (action == 'edit') {
                                  await _openEditor(record);
                                  await _refresh();
                                }
                                if (action == 'delete') {
                                  await _delete(record);
                                  await _refresh();
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit_outlined),
                                    title: Text('Edit'),
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete_outline),
                                    title: Text('Delete'),
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTs(Timestamp ts) {
    final dt = ts.toDate().toLocal();
    return '${dt.year}-${_p(dt.month)}-${_p(dt.day)} '
        '${_p(dt.hour)}:${_p(dt.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');

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
    if (confirmed != true || !mounted) return;
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Record deleted.')));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Delete failed.')),
        );
      }
    }
  }
}

// ── Category Picker Widget ────────────────────────────────────────────────────

class _CategoryPickerField extends StatefulWidget {
  const _CategoryPickerField({
    required this.controller,
    required this.label,
    required this.isRequired,
  });

  final TextEditingController controller;
  final String label;
  final bool isRequired;

  @override
  State<_CategoryPickerField> createState() => _CategoryPickerFieldState();
}

class _CategoryPickerFieldState extends State<_CategoryPickerField> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _categories = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('active', isEqualTo: true)
          .orderBy('name')
          .get();
      if (mounted) {
        setState(() {
          _categories = snapshot.docs;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          readOnly: _categories.isNotEmpty,
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: _categories.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: _showPicker,
                  )
                : null,
          ),
          validator: (value) {
            if (widget.isRequired && (value?.trim().isEmpty ?? true)) {
              return '${widget.label} is required.';
            }
            return null;
          },
          onTap: _categories.isNotEmpty ? _showPicker : null,
        ),
        if (!_loaded)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: LinearProgressIndicator(),
          ),
        if (_loaded && _categories.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'No active categories found. Create one first.',
              style: TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _showPicker() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select category'),
        children: _categories.map((cat) {
          final data = cat.data();
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, cat.id),
            child: ListTile(
              title: Text(data['name'] as String? ?? cat.id),
              subtitle: Text(cat.id, style: const TextStyle(fontSize: 11)),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          );
        }).toList(),
      ),
    );
    if (selected != null) {
      widget.controller.text = selected;
    }
  }
}

// ── Date Picker Field ─────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.controller,
    required this.label,
    required this.isRequired,
  });

  final TextEditingController controller;
  final String label;
  final bool isRequired;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    DateTime initial = now;
    try {
      if (controller.text.isNotEmpty) {
        initial = DateTime.parse(controller.text);
      }
    } catch (_) {}

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    final finalDt = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    controller.text = finalDt.toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _pick(context),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      validator: (value) {
        if (isRequired && (value?.trim().isEmpty ?? true)) {
          return '$label is required.';
        }
        return null;
      },
    );
  }
}

// ── Record Editor Dialog ──────────────────────────────────────────────────────

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

  // Track old price for price-drop detection
  num? _oldPrice;

  @override
  void initState() {
    super.initState();
    for (final field in widget.config.fields) {
      final value = widget.initialData?[field.key];
      if (field.type == AdminFieldType.toggle) {
        _toggles[field.key] = value as bool? ?? field.defaultBool;
      } else if (field.type == AdminFieldType.datePicker) {
        _controllers[field.key] = TextEditingController(
          text: value is Timestamp
              ? value.toDate().toIso8601String()
              : value?.toString() ?? '',
        );
      } else {
        _controllers[field.key] = TextEditingController(
          text: value is Timestamp
              ? value.toDate().toIso8601String()
              : value?.toString() ?? '',
        );
      }
    }
    // Remember old price for price-drop trigger
    if (widget.config.enablePriceDropTrigger) {
      _oldPrice = widget.initialData?['price'] as num?;
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
        } else if (field.type == AdminFieldType.datePicker) {
          if (value.isNotEmpty) {
            data[field.key] = Timestamp.fromDate(DateTime.parse(value));
          }
        } else if (field.key == 'eventDate') {
          data[field.key] = Timestamp.fromDate(DateTime.parse(value));
        } else {
          data[field.key] = value.isEmpty ? null : value;
        }
      }

      final user = FirebaseAuth.instance.currentUser!;
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['updatedBy'] = user.uid;

      final reference =
          widget.reference ??
          FirebaseFirestore.instance.collection(widget.config.collection).doc();
      final isCreate = widget.reference == null;
      if (isCreate) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['createdBy'] = user.uid;
      }

      final batch = FirebaseFirestore.instance.batch();
      batch.set(reference, data, SetOptions(merge: true));
      addAdminAudit(
        batch,
        action: isCreate ? 'create' : 'update',
        collection: widget.config.collection,
        recordId: reference.id,
      );

      // Price-drop: if price decreased, write a price_drop_events record so
      // Cloud Functions / manual notification flow can pick it up.
      if (widget.config.enablePriceDropTrigger && !isCreate) {
        final newPrice = data['price'] as num?;
        if (newPrice != null && _oldPrice != null && newPrice < _oldPrice!) {
          final dropRef = FirebaseFirestore.instance
              .collection('price_drop_events')
              .doc();
          batch.set(dropRef, {
            'productId': reference.id,
            'oldPrice': _oldPrice,
            'newPrice': newPrice,
            'triggeredBy': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'notified': false,
          });
          addAdminAudit(
            batch,
            action:
                'price-drop:${_oldPrice!.toStringAsFixed(2)}->${newPrice.toStringAsFixed(2)}',
            collection: 'merchandise',
            recordId: reference.id,
          );
        }
      }

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
    if (widget.config.collection == 'categories' && field == 'imageUrl') {
      return CloudinaryPurpose.contentImage;
    }
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Media upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingField = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.reference == null
            ? 'Create ${widget.config.title}'
            : 'Edit ${widget.config.title}',
      ),
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

                if (field.type == AdminFieldType.categoryPicker) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CategoryPickerField(
                      controller: _controllers[field.key]!,
                      label: field.label,
                      isRequired: field.required,
                    ),
                  );
                }

                if (field.type == AdminFieldType.datePicker) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DatePickerField(
                      controller: _controllers[field.key]!,
                      label: field.label,
                      isRequired: field.required,
                    ),
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
                              text.isNotEmpty &&
                              !ContentType.values.any(
                                (type) => type.name == text,
                              )) {
                            return 'Use: ${ContentType.values.map((type) => type.name).join(', ')}';
                          }
                          if (text.isNotEmpty &&
                              (field.key == 'imageUrl' ||
                                  field.key == 'videoUrl' ||
                                  field.key == 'ticketLink')) {
                            final uri = Uri.tryParse(text);
                            if (uri == null ||
                                uri.scheme != 'https' ||
                                uri.host.isEmpty) {
                              return 'Enter a valid HTTPS link (e.g. https://res.cloudinary.com/...)';
                            }
                          }
                          return null;
                        },
                      ),
                      if (field.key == 'videoUrl')
                        const Padding(
                          padding: EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            'Tip: Paste a Cloudinary video URL (or click Upload below).',
                            style: TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                        ),
                      if (field.key == 'imageUrl')
                        const Padding(
                          padding: EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            'Tip: Paste a Cloudinary image URL (or click Upload below).',
                            style: TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                        ),
                      if (purpose != null &&
                          CloudinaryMediaService.isSupportedPlatform) ...[
                        const SizedBox(height: 6),
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
                            'Upload ${field.key == 'videoUrl' ? 'video' : 'image'} to Cloudinary',
                          ),
                        ),
                        if (_uploadingField == field.key) ...[
                          const SizedBox(height: 4),
                          LinearProgressIndicator(value: _uploadProgress),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _mediaService.cancel,
                              child: const Text('Cancel upload'),
                            ),
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

// ── Audit helper (used by all admin screens) ──────────────────────────────────

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
