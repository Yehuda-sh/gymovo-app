import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeekPlanScreen extends StatefulWidget {
  const WeekPlanScreen({super.key});

  @override
  State<WeekPlanScreen> createState() => _WeekPlanScreenState();
}

class _WeekPlanScreenState extends State<WeekPlanScreen> {
  int selectedWeekOffset =
      0; // 0 = השבוע הנוכחי, 1 = השבוע הבא, -1 = השבוע הקודם

  final List<String> weekDays = [
    'ראשון',
    'שני',
    'שלישי',
    'רביעי',
    'חמישי',
    'שישי',
    'שבת',
  ];

  // דוגמה לנתוני אימונים
  final Map<String, List<String>> weeklyWorkouts = {
    'ראשון': ['חזה + כתפיים', '45 דקות'],
    'שני': ['גב + ביצפס', '50 דקות'],
    'שלישי': ['רגליים', '60 דקות'],
    'רביעי': ['מנוחה', ''],
    'חמישי': ['חזה + טריצפס', '45 דקות'],
    'שישי': ['כתפיים + בטן', '40 דקות'],
    'שבת': ['מנוחה', ''],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildWeekSelector(theme),
          Expanded(
            child: _buildWeekPlan(theme),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Text(
        'תוכנית השבוע',
        style: GoogleFonts.assistant(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // פתיחת הגדרות
            _showSettingsDialog();
          },
        ),
      ],
    );
  }

  Widget _buildWeekSelector(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                selectedWeekOffset--;
              });
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            _getWeekTitle(),
            style: GoogleFonts.assistant(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedWeekOffset++;
              });
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekPlan(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final day = weekDays[index];
          final workouts = weeklyWorkouts[day] ?? ['אין אימון', ''];
          final isToday = _isToday(index);
          final isRestDay =
              workouts[0] == 'מנוחה' || workouts[0] == 'אין אימון';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: isToday ? 4 : 1,
              color: isToday ? theme.primaryColor.withOpacity(0.1) : null,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isRestDay
                        ? Colors.grey.withOpacity(0.3)
                        : theme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      day.substring(0, 1),
                      style: GoogleFonts.assistant(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isRestDay ? Colors.grey : theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  day,
                  style: GoogleFonts.assistant(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workouts[0],
                      style: GoogleFonts.assistant(
                        fontSize: 14,
                        color: isRestDay ? Colors.grey : null,
                      ),
                    ),
                    if (workouts[1].isNotEmpty)
                      Text(
                        workouts[1],
                        style: GoogleFonts.assistant(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
                trailing: isRestDay
                    ? const Icon(Icons.hotel, color: Colors.grey)
                    : Icon(
                        Icons.fitness_center,
                        color: theme.primaryColor,
                      ),
                onTap: () {
                  if (!isRestDay) {
                    _openWorkoutDetails(day, workouts);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () {
        _showAddWorkoutDialog();
      },
      icon: const Icon(Icons.add),
      label: Text(
        'הוסף אימון',
        style: GoogleFonts.assistant(),
      ),
    );
  }

  String _getWeekTitle() {
    if (selectedWeekOffset == 0) {
      return 'השבוע הנוכחי';
    } else if (selectedWeekOffset == 1) {
      return 'השבוע הבא';
    } else if (selectedWeekOffset == -1) {
      return 'השבוע הקודם';
    } else if (selectedWeekOffset > 1) {
      return 'בעוד $selectedWeekOffset שבועות';
    } else {
      return 'לפני ${selectedWeekOffset.abs()} שבועות';
    }
  }

  bool _isToday(int dayIndex) {
    if (selectedWeekOffset != 0) return false;
    final now = DateTime.now();
    final today = now.weekday == 7 ? 0 : now.weekday; // המרה ליום ראשון = 0
    return dayIndex == today;
  }

  void _openWorkoutDetails(String day, List<String> workouts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'אימון יום $day',
                  style: GoogleFonts.assistant(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              workouts[0],
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (workouts[1].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'משך זמן: ${workouts[1]}',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              'פרטי האימון:',
              style: GoogleFonts.assistant(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'כאן יוצגו פרטי התרגילים, מספר הסטים והחזרות',
                    style: GoogleFonts.assistant(fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // מעבר למסך האימון
                },
                child: Text(
                  'התחל אימון',
                  style: GoogleFonts.assistant(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'הוסף אימון חדש',
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'תכונה זו תפותח בקרוב',
              style: GoogleFonts.assistant(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'סגור',
              style: GoogleFonts.assistant(),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'הגדרות תוכנית השבוע',
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(
                'התראות',
                style: GoogleFonts.assistant(),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // טיפול בהתראות
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(
                'שעות מועדפות',
                style: GoogleFonts.assistant(),
              ),
              onTap: () {
                // פתיחת בחירת שעות
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'סגור',
              style: GoogleFonts.assistant(),
            ),
          ),
        ],
      ),
    );
  }
}
