import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/exercise_history.dart';
import '../../../providers/exercise_history_provider.dart';
import 'package:provider/provider.dart';

class ExerciseSetList extends StatelessWidget {
  final List<ExerciseSet> sets;
  final Function(ExerciseSet) onEdit;
  final Function(String) onDelete;
  final bool showDate;

  const ExerciseSetList({
    Key? key,
    required this.sets,
    required this.onEdit,
    required this.onDelete,
    this.showDate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sets.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'אין סטים להצגה',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets[index];
        return Dismissible(
          key: Key(set.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onDelete(set.id),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: InkWell(
              onTap: () => onEdit(set),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${set.weight} ק"ג × ${set.reps} חזרות',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (showDate)
                          Text(
                            '${set.date.day}/${set.date.month}/${set.date.year}',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                    if (set.notes?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      Text(
                        set.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (!set.isCompleted) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'לא הושלם',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
