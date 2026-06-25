import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isGridView;
  final Function(bool?) onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.isGridView,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final categoryColor = AppColors.getCategoryColor(task.category);
    final priorityColor = AppColors.getPriorityColor(task.priority);
    final formattedDate = DateFormat('MMM d, yyyy').format(task.dueDate);
    
    // Check if task is overdue (if not completed and due date is before today)
    final isOverdue = !task.isCompleted && 
        task.dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    // Card background decoration
    final cardBg = task.isCompleted
        ? (isDark ? const Color(0xFF131A26).withOpacity(0.5) : const Color(0xFFF1F5F9))
        : (isDark ? AppColors.cardDark : AppColors.cardLight);

    final opacity = task.isCompleted ? 0.6 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Card(
        color: cardBg,
        elevation: task.isCompleted ? 0 : 2,
        shadowColor: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: task.isCompleted
                ? Colors.transparent
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isGridView 
              ? _buildGridContent(context, categoryColor, priorityColor, formattedDate, isOverdue, theme)
              : _buildListContent(context, categoryColor, priorityColor, formattedDate, isOverdue, theme),
        ),
      ),
    );
  }

  // Layout optimized for Grid View
  Widget _buildGridContent(
    BuildContext context, 
    Color categoryColor, 
    Color priorityColor, 
    String formattedDate, 
    bool isOverdue,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge & Priority Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCategoryBadge(task.category, categoryColor),
            _buildPriorityDot(task.priority, priorityColor),
          ],
        ),
        const SizedBox(height: 12),
        
        // Checkbox & Title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: task.isCompleted,
                onChanged: onToggleComplete,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                activeColor: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  color: task.isCompleted ? Colors.grey : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Description
        Expanded(
          child: Text(
            task.description.isNotEmpty ? task.description : 'No description provided.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Due Date
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: isOverdue ? Colors.redAccent : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                color: isOverdue ? Colors.redAccent : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const Divider(height: 16),

        // Edit / Delete Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit Task',
              color: AppColors.primary,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              tooltip: 'Delete Task',
              color: Colors.redAccent,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
            ),
          ],
        )
      ],
    );
  }

  // Layout optimized for List View
  Widget _buildListContent(
    BuildContext context, 
    Color categoryColor, 
    Color priorityColor, 
    String formattedDate, 
    bool isOverdue,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Completion Checkbox
        Checkbox(
          value: task.isCompleted,
          onChanged: onToggleComplete,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          activeColor: AppColors.secondary,
        ),
        const SizedBox(width: 8),

        // Core Task Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? Colors.grey : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPriorityBadge(task.priority, priorityColor),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                task.description.isNotEmpty ? task.description : 'No description provided.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              
              // Bottom Row: Category and Due Date
              Row(
                children: [
                  _buildCategoryBadge(task.category, categoryColor),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: isOverdue ? Colors.redAccent : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                      color: isOverdue ? Colors.redAccent : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Action Buttons
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Edit Task',
              color: AppColors.primary,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Delete Task',
              color: Colors.redAccent,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCategoryBadge(String category, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityDot(String priority, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          priority,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(String priority, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
