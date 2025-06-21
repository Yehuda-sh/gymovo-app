// lib/widgets/exercise_history_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/unified_models.dart';

/// Widget מתקדם להצגת היסטוריית תרגיל עם אנליטיקה
class ExerciseHistoryWidget extends StatefulWidget {
  final ExerciseHistory exerciseHistory;
  final bool showPersonalRecords;
  final bool showDetailedStats;
  final bool showProgressChart;
  final int maxSetsToShow;
  final VoidCallback? onViewAllSets;

  const ExerciseHistoryWidget({
    super.key,
    required this.exerciseHistory,
    this.showPersonalRecords = true,
    this.showDetailedStats = true,
    this.showProgressChart = false,
    this.maxSetsToShow = 10,
    this.onViewAllSets,
  });

  @override
  State<ExerciseHistoryWidget> createState() => _ExerciseHistoryWidgetState();
}

class _ExerciseHistoryWidgetState extends State<ExerciseHistoryWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showAllStats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildQuickStats(),
          if (widget.showPersonalRecords) ...[
            const SizedBox(height: 16),
            _buildPersonalRecords(),
          ],
          if (widget.showDetailedStats) ...[
            const SizedBox(height: 16),
            _buildDetailedStatsSection(),
          ],
          const SizedBox(height: 16),
          _buildTabSection(),
        ],
      ),
    );
  }

  /// כותרת עם שם התרגיל ופרטים בסיסיים
  Widget _buildHeader() {
    final colors = AppTheme.colors;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.exerciseHistory.exerciseId,
                style: GoogleFonts.assistant(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: colors.text.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.exerciseHistory.lastWorkoutDate != null
                        ? 'אימון אחרון: ${_formatDate(widget.exerciseHistory.lastWorkoutDate!)}'
                        : 'אימון ראשון',
                    style: GoogleFonts.assistant(
                      fontSize: 14,
                      color: colors.text.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildTrendIndicator(),
      ],
    );
  }

  /// אינדיקטור מגמה
  Widget _buildTrendIndicator() {
    final stats = widget.exerciseHistory.getDetailedStatistics();
    final strengthTrend = stats['strength_trend'] as String? ?? 'stable';

    Color trendColor;
    IconData trendIcon;
    String trendText;

    switch (strengthTrend) {
      case 'increasing':
        trendColor = Colors.green;
        trendIcon = Icons.trending_up;
        trendText = 'עלייה';
        break;
      case 'decreasing':
        trendColor = Colors.red;
        trendIcon = Icons.trending_down;
        trendText = 'ירידה';
        break;
      default:
        trendColor = Colors.orange;
        trendIcon = Icons.trending_flat;
        trendText = 'יציב';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: trendColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trendIcon, size: 16, color: trendColor),
          const SizedBox(width: 4),
          Text(
            trendText,
            style: GoogleFonts.assistant(
              fontSize: 12,
              color: trendColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// סטטיסטיקות מהירות
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'סטים',
            widget.exerciseHistory.totalSets.toString(),
            Icons.repeat,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'נפח כולל',
            '${widget.exerciseHistory.totalVolume?.toStringAsFixed(0) ?? '0'}ק"ג',
            Icons.fitness_center,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'מפגשים',
            widget.exerciseHistory.totalSessions.toString(),
            Icons.calendar_today,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'ממוצע',
            '${widget.exerciseHistory.averageWeight.toStringAsFixed(1)}ק"ג',
            Icons.scale,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  /// כרטיס סטטיסטיקה
  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.assistant(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.headline,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.assistant(
              fontSize: 11,
              color: AppTheme.colors.text.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// שיאים אישיים
  Widget _buildPersonalRecords() {
    final colors = AppTheme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'שיאים אישיים',
          style: GoogleFonts.assistant(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.headline,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            if (widget.exerciseHistory.maxWeightPR != null)
              _buildPRChip(
                'משקל מקסימלי',
                widget.exerciseHistory.maxWeightPR!.formattedValue,
                Icons.fitness_center,
                Colors.red,
              ),
            if (widget.exerciseHistory.maxRepsPR != null)
              _buildPRChip(
                'חזרות מקסימליות',
                widget.exerciseHistory.maxRepsPR!.formattedValue,
                Icons.repeat,
                Colors.blue,
              ),
            if (widget.exerciseHistory.maxVolumePR != null)
              _buildPRChip(
                'נפח מקסימלי',
                widget.exerciseHistory.maxVolumePR!.formattedValue,
                Icons.trending_up,
                Colors.green,
              ),
            if (widget.exerciseHistory.maxOneRMPR != null)
              _buildPRChip(
                '1RM משוער',
                widget.exerciseHistory.maxOneRMPR!.formattedValue,
                Icons.emoji_events,
                Colors.amber,
              ),
          ],
        ),
      ],
    );
  }

  /// תג שיא אישי
  Widget _buildPRChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.headline,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.assistant(
                  fontSize: 11,
                  color: AppTheme.colors.text.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// סקציית סטטיסטיקות מפורטות
  Widget _buildDetailedStatsSection() {
    final colors = AppTheme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'סטטיסטיקות מתקדמות',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.headline,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showAllStats = !_showAllStats;
                });
              },
              child: Text(
                _showAllStats ? 'הצג פחות' : 'הצג עוד',
                style: GoogleFonts.assistant(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDetailedStats(),
      ],
    );
  }

  /// סטטיסטיקות מפורטות
  Widget _buildDetailedStats() {
    final stats = widget.exerciseHistory.getDetailedStatistics();

    final basicStats = [
      _StatItem('ממוצע משקל',
          '${(stats['avg_weight'] ?? 0).toStringAsFixed(1)}ק"ג', Icons.scale),
      _StatItem('ממוצע חזרות', '${stats['avg_reps'] ?? 0}', Icons.repeat),
      _StatItem(
          'נפח ממוצע לסט',
          '${(stats['avg_volume_per_set'] ?? 0).toStringAsFixed(1)}',
          Icons.analytics),
      _StatItem(
          '1RM משוער',
          '${(stats['estimated_1rm'] ?? 0).toStringAsFixed(0)}ק"ג',
          Icons.emoji_events),
    ];

    final advancedStats = [
      _StatItem('תדירות חודשית', '${stats['month_frequency'] ?? 0} ימים',
          Icons.calendar_today),
      _StatItem('יום הטוב ביותר', '${stats['best_day_of_week'] ?? 'לא ידוע'}',
          Icons.today),
      _StatItem('זמן הטוב ביותר', '${stats['best_time_of_day'] ?? 'לא ידוע'}',
          Icons.access_time),
      _StatItem(
          'זמן מנוחה ממוצע', '${stats['avg_rest_time'] ?? 0}s', Icons.timer),
      if (stats['avg_rpe'] != null && stats['avg_rpe'] > 0)
        _StatItem(
            'RPE ממוצע',
            '${(stats['avg_rpe'] as double).toStringAsFixed(1)}',
            Icons.psychology),
      if (stats['quarter_progression'] != null)
        _StatItem(
            'התקדמות רבעונית',
            '${(stats['quarter_progression'] as double).toStringAsFixed(1)}%',
            Icons.trending_up),
    ];

    return Column(
      children: [
        _buildStatsGrid(basicStats),
        if (_showAllStats) ...[
          const SizedBox(height: 12),
          _buildStatsGrid(advancedStats),
        ],
      ],
    );
  }

  /// רשת סטטיסטיקות
  Widget _buildStatsGrid(List<_StatItem> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 8,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.colors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.colors.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                stat.icon,
                size: 16,
                color: AppTheme.colors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat.value,
                      style: GoogleFonts.assistant(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.colors.headline,
                      ),
                    ),
                    Text(
                      stat.label,
                      style: GoogleFonts.assistant(
                        fontSize: 11,
                        color: AppTheme.colors.text.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// סקציית טאבים
  Widget _buildTabSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.assistant(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.assistant(),
          tabs: const [
            Tab(text: 'סטים אחרונים'),
            Tab(text: 'מגמות'),
            Tab(text: 'השוואות'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRecentSetsTab(),
              _buildTrendsTab(),
              _buildComparisonsTab(),
            ],
          ),
        ),
      ],
    );
  }

  /// טאב סטים אחרונים
  Widget _buildRecentSetsTab() {
    final recentSets =
        widget.exerciseHistory.getRecentSets(widget.maxSetsToShow);

    if (recentSets.isEmpty) {
      return const Center(
        child: Text('אין סטים להצגה'),
      );
    }

    return ListView.builder(
      itemCount: recentSets.length,
      itemBuilder: (context, index) {
        final set = recentSets[index];
        return _buildRecentSetItem(set, index);
      },
    );
  }

  /// פריט סט אחרון
  Widget _buildRecentSetItem(ExerciseSet set, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: set.isPR
              ? Colors.amber.withOpacity(0.5)
              : AppTheme.colors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // אייקון סט
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: set.isPR ? Colors.amber : AppTheme.colors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: set.isPR
                  ? const Icon(Icons.star, size: 16, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: GoogleFonts.assistant(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // פרטי הסט
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${set.weight}ק"ג × ${set.reps}',
                      style: GoogleFonts.assistant(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.colors.headline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (set.setType != SetType.normal)
                      _buildMiniChip(set.setType.displayName, Colors.purple),
                    if (set.rpe != null)
                      _buildMiniChip('RPE ${set.rpe}', Colors.orange),
                  ],
                ),
                Text(
                  _formatDate(set.date),
                  style: GoogleFonts.assistant(
                    fontSize: 12,
                    color: AppTheme.colors.text.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // נפח
          Text(
            '${set.volume.toStringAsFixed(0)}',
            style: GoogleFonts.assistant(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// טאב מגמות
  Widget _buildTrendsTab() {
    final stats = widget.exerciseHistory.getDetailedStatistics();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTrendCard(
            'מגמת כוח',
            stats['strength_trend'] as String? ?? 'stable',
            Icons.fitness_center,
          ),
          const SizedBox(height: 12),
          _buildTrendCard(
            'מגמת נפח',
            stats['volume_trend'] as String? ?? 'stable',
            Icons.analytics,
          ),
          const SizedBox(height: 12),
          _buildTrendCard(
            'מגמת תדירות',
            stats['frequency_trend'] as String? ?? 'stable',
            Icons.calendar_today,
          ),
          const SizedBox(height: 12),
          if (stats['quarter_progression'] != null)
            _buildProgressionCard(
              'התקדמות רבעונית',
              stats['quarter_progression'] as double,
            ),
        ],
      ),
    );
  }

  /// כרטיס מגמה
  Widget _buildTrendCard(String title, String trend, IconData icon) {
    Color trendColor;
    String trendText;
    IconData trendIcon;

    switch (trend) {
      case 'increasing':
        trendColor = Colors.green;
        trendText = 'מגמת עלייה';
        trendIcon = Icons.trending_up;
        break;
      case 'decreasing':
        trendColor = Colors.red;
        trendText = 'מגמת ירידה';
        trendIcon = Icons.trending_down;
        break;
      default:
        trendColor = Colors.orange;
        trendText = 'מגמה יציבה';
        trendIcon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: trendColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: trendColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.colors.headline,
                  ),
                ),
                Text(
                  trendText,
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: trendColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(trendIcon, size: 20, color: trendColor),
        ],
      ),
    );
  }

  /// כרטיס התקדמות
  Widget _buildProgressionCard(String title, double progression) {
    final isPositive = progression > 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 24,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.colors.headline,
                  ),
                ),
                Text(
                  '${progression.toStringAsFixed(1)}%',
                  style: GoogleFonts.assistant(
                    fontSize: 18,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// טאב השוואות
  Widget _buildComparisonsTab() {
    final thisMonth = widget.exerciseHistory.getSetsInDateRange(
      DateTime.now().subtract(const Duration(days: 30)),
      DateTime.now(),
    );

    final lastMonth = widget.exerciseHistory.getSetsInDateRange(
      DateTime.now().subtract(const Duration(days: 60)),
      DateTime.now().subtract(const Duration(days: 30)),
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildComparisonCard(
            'השוואה חודשית',
            'חודש זה',
            'חודש שעבר',
            thisMonth,
            lastMonth,
          ),
        ],
      ),
    );
  }

  /// כרטיס השוואה
  Widget _buildComparisonCard(
    String title,
    String period1,
    String period2,
    List<ExerciseSet> sets1,
    List<ExerciseSet> sets2,
  ) {
    final volume1 = sets1.fold<double>(0, (sum, set) => sum + set.volume);
    final volume2 = sets2.fold<double>(0, (sum, set) => sum + set.volume);
    final avgWeight1 = sets1.isNotEmpty
        ? sets1.fold<double>(0, (sum, set) => sum + (set.weight ?? 0)) /
            sets1.length
        : 0.0;
    final avgWeight2 = sets2.isNotEmpty
        ? sets2.fold<double>(0, (sum, set) => sum + (set.weight ?? 0)) /
            sets2.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.assistant(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.headline,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildComparisonColumn(
                  period1,
                  sets1.length,
                  volume1,
                  avgWeight1,
                ),
              ),
              Container(
                width: 1,
                height: 80,
                color: AppTheme.colors.primary.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildComparisonColumn(
                  period2,
                  sets2.length,
                  volume2,
                  avgWeight2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// עמודת השוואה
  Widget _buildComparisonColumn(
    String title,
    int sets,
    double volume,
    double avgWeight,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.assistant(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$sets סטים',
          style: GoogleFonts.assistant(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.headline,
          ),
        ),
        Text(
          '${volume.toStringAsFixed(0)} נפח',
          style: GoogleFonts.assistant(
            fontSize: 14,
            color: AppTheme.colors.text.withOpacity(0.7),
          ),
        ),
        Text(
          '${avgWeight.toStringAsFixed(1)}ק"ג ממוצע',
          style: GoogleFonts.assistant(
            fontSize: 14,
            color: AppTheme.colors.text.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// בניית תג מיני
  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.assistant(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// עיצוב תאריך
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'היום';
    if (difference == 1) return 'אתמול';
    if (difference < 7) return 'לפני $difference ימים';
    if (difference < 30) return 'לפני ${(difference / 7).round()} שבועות';
    return 'לפני ${(difference / 30).round()} חודשים';
  }
}

/// מחלקת עזר לפריט סטטיסטיקה
class _StatItem {
  final String label;
  final String value;
  final IconData icon;

  _StatItem(this.label, this.value, this.icon);
}
