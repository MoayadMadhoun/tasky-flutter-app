import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/connectivity_provider.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  static const routeName = '/details';

  const TaskDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as int;
    final isOnline = context.select<ConnectivityProvider, bool>((p) => p.isOnline);

    final task = context.select<TaskProvider, Task?>((p) => p.byId(id));

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: Text('Task not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: isOnline
                ? () => Navigator.pushNamed(
                      context,
                      AddEditTaskScreen.routeName,
                      arguments: task,
                    )
                : null,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: isOnline
                ? () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete task?'),
                        content: const Text('This action cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                        ],
                      ),
                    );

                    if (ok != true) return;

                    try {
                      await context.read<TaskProvider>().deleteById(task.id);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task deleted')),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Delete failed: $e')),
                      );
                    }
                  }
                : null,
              icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _DetailsCard(task: task, isOnline: isOnline),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final Task task;
  final bool isOnline;

  const _DetailsCard({required this.task, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(task.completed ? Icons.check_circle : Icons.circle_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(task.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text(task.completed ? 'Completed' : 'Pending'),
                  side: BorderSide(color: scheme.outline),
                ),
                const Spacer(),
                if (!isOnline)
                  const Row(
                    children: [
                      Icon(Icons.wifi_off, size: 18),
                      SizedBox(width: 6),
                      Text('Offline'),
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
