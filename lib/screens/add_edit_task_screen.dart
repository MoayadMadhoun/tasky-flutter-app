import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/connectivity_provider.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  static const routeName = '/add_edit';

  const AddEditTaskScreen({super.key});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _completed = false;
  bool _saving = false;

  Task? _editing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;

    if (arg is Task && _editing == null) {
      _editing = arg;
      _title.text = arg.title;
      _desc.text = arg.description;
      _completed = arg.completed;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  String? _validateTitle(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Title is required';
    if (s.length < 3) return 'Minimum 3 characters';
    return null;
  }

  String? _validateDesc(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Description is required';
    if (s.length < 5) return 'Minimum 5 characters';
    return null;
  }

  Future<void> _save() async {
    final isOnline = context.read<ConnectivityProvider>().isOnline;
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offline: cannot save right now')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final provider = context.read<TaskProvider>();

      if (_editing == null) {
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch,
          title: _title.text.trim(),
          description: _desc.text.trim(),
          completed: _completed,
        );
        await provider.addTask(newTask);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created')),
        );
      } else {
        final updated = _editing!.copyWith(
          title: _title.text.trim(),
          description: _desc.text.trim(),
          completed: _completed,
        );
        await provider.updateExisting(updated);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.select<ConnectivityProvider, bool>((p) => p.isOnline);
    final editing = _editing != null;

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Task' : 'Add Task')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 700 ? 700.0 : constraints.maxWidth;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (!isOnline)
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Text('Offline: saving is disabled.'),
                                ),
                              ),
                            TextFormField(
                              controller: _title,
                              decoration: const InputDecoration(labelText: 'Title'),
                              validator: _validateTitle,
                              enabled: isOnline && !_saving,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _desc,
                              decoration: const InputDecoration(labelText: 'Description'),
                              minLines: 3,
                              maxLines: 5,
                              validator: _validateDesc,
                              enabled: isOnline && !_saving,
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              value: _completed,
                              onChanged: (isOnline && !_saving) ? (v) => setState(() => _completed = v) : null,
                              title: const Text('Completed'),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: (isOnline && !_saving) ? _save : null,
                                icon: _saving
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.save),
                                label: Text(_saving ? 'Saving...' : 'Save'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
