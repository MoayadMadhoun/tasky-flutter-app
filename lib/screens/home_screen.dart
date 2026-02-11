import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/connectivity_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';
import 'task_details_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = context.read<TaskProvider>().fetchTasks().then((_) {});
  }

  Future<void> _reload() async {
    setState(() {
      _loadFuture = context.read<TaskProvider>().fetchTasks().then((_) {});
    });
    await _loadFuture;
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.select<ConnectivityProvider, bool>((p) => p.isOnline);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!isOnline)
              MaterialBanner(
                content: const Text('You are offline. Internet actions are disabled.'),
                leading: const Icon(Icons.wifi_off),
                actions: [
                  TextButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            Expanded(
              child: FutureBuilder<void>(
                future: _loadFuture,
                builder: (context, snapshot) {
                  final provider = context.watch<TaskProvider>();

                  if (snapshot.connectionState == ConnectionState.waiting && provider.tasks.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError && provider.tasks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load tasks.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _reload,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final tasks = provider.tasks;

                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 700;

                        if (tasks.isEmpty) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(child: Text('No tasks yet. Pull to refresh.')),
                            ],
                          );
                        }

                        if (isWide) {
                          final columns = constraints.maxWidth >= 1000 ? 3 : 2;
                          return GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              childAspectRatio: 3.2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: tasks.length,
                            itemBuilder: (context, i) {
                              final t = tasks[i];
                              return TaskCard(
                                task: t,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  TaskDetailsScreen.routeName,
                                  arguments: t.id,
                                ),
                              );
                            },
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: tasks.length,
                          itemBuilder: (context, i) {
                            final t = tasks[i];
                            return TaskCard(
                              task: t,
                              onTap: () => Navigator.pushNamed(
                                context,
                                TaskDetailsScreen.routeName,
                                arguments: t.id,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isOnline
            ? () => Navigator.pushNamed(context, AddEditTaskScreen.routeName)
            : null,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
