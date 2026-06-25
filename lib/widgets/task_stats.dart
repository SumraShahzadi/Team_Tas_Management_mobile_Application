import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskStats extends StatelessWidget {
  final List<Task> tasks;

  const TaskStats({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;
    final double completionRate = total > 0 ? completed / total : 0.0;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFEEF2FF),
                  const Color(0xFFE0E7FF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF222F4D) : const Color(0xFFC7D2FE),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company Workspace',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.indigo[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time Task Overview',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white38 : Colors.black54,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: theme.colorScheme.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(completionRate * 100).toStringAsFixed(0)}% Done',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.indigo[900],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  title: 'Total Tasks',
                  value: total.toString(),
                  icon: Icons.assignment_outlined,
                  iconColor: Colors.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  title: 'Completed',
                  value: completed.toString(),
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  title: 'Pending',
                  value: pending.toString(),
                  icon: Icons.pending_actions_outlined,
                  iconColor: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.indigo.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                completionRate == 1.0 ? Colors.teal : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
