import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:product_tracker/models/daily_report_model.dart';
import 'package:product_tracker/repositories/production_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ProductionRepository _productionRepo;

  bool _isLoading = true;
  Map<String, dynamic> _metrics = {};
  List<DailyReport> _recentReports = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _productionRepo = ProductionRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final metrics = await _productionRepo.getDashboardMetrics();
      final reports = await _productionRepo.getDailyReports();
      setState(() {
        _metrics = metrics;
        _recentReports = reports.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          Text('Production Trend (Last 7 Days)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildChart(),
          const SizedBox(height: 24),
          Text('Recent Reports', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildRecentReports(),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final totalReports = _metrics['totalReports'] ?? 0;
    final totalProduction = _metrics['totalProduction'] ?? 0;
    final avgEfficiency = _metrics['avgEfficiency'] ?? 0.0;
    final totalDowntime = _metrics['totalDowntime'] ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Total Reports', '$totalReports', Icons.assignment, Theme.of(context).colorScheme.primary),
        _buildMetricCard('Total Production', '$totalProduction', Icons.precision_manufacturing, Colors.green),
        _buildMetricCard('Avg Efficiency', '${(avgEfficiency as num).toStringAsFixed(1)}%', Icons.speed, Colors.orange),
        _buildMetricCard('Total Downtime', '$totalDowntime min', Icons.timer_off, Colors.red),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card.filled(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color.withValues(alpha: 0.8))),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const titles = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      return Text(titles[value.toInt() % 7], style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 80, color: Theme.of(context).colorScheme.primary)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 65, color: Theme.of(context).colorScheme.primary)]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 90, color: Theme.of(context).colorScheme.primary)]),
                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 75, color: Theme.of(context).colorScheme.primary)]),
                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 85, color: Theme.of(context).colorScheme.primary)]),
                BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 60, color: Theme.of(context).colorScheme.primary)]),
                BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 95, color: Theme.of(context).colorScheme.primary)]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReports() {
    if (_recentReports.isEmpty) {
      return const Center(child: Text('No recent reports'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentReports.length,
      itemBuilder: (context, index) {
        final report = _recentReports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.assignment, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            title: Text(report.reportNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${report.date} | ${report.shift} Shift | Line: ${report.productionLine}'),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
