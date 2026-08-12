import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:product_tracker/models/daily_report_model.dart';
import 'package:product_tracker/repositories/production_repository.dart';
import 'package:product_tracker/repositories/quality_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ProductionRepository _productionRepo = ProductionRepository();
  final QualityRepository _qualityRepo = QualityRepository();

  bool _isLoading = true;
  List<DailyReport> _reports = [];
  DailyReport? _selectedReport;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await _productionRepo.getDailyReports();
      setState(() {
        _reports = reports;
        if (reports.isNotEmpty) _selectedReport = reports.first;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _generatePdf() async {
    if (_selectedReport == null) return;

    try {
      final entries = await _productionRepo.getProductionEntries(_selectedReport!.id!);
      final checks = await _qualityRepo.getQualityChecks(dailyReportId: _selectedReport!.id!);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text('Daily Production Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Report Number: ${_selectedReport!.reportNumber}'),
              pw.Text('Date: ${_selectedReport!.date}'),
              pw.Text('Shift: ${_selectedReport!.shift}'),
              pw.Text('Production Line: ${_selectedReport!.productionLine}'),
              pw.SizedBox(height: 20),
              
              pw.Header(level: 1, child: pw.Text('Production Entries')),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Hour', 'Model', 'Target', 'Achieved', 'Efficiency', 'Downtime'],
                data: entries.map((e) => [
                  e.hour,
                  e.model,
                  e.target.toString(),
                  e.achieved.toString(),
                  '${e.efficiency.toStringAsFixed(1)}%',
                  e.downtime.toString(),
                ]).toList(),
              ),
              
              pw.SizedBox(height: 20),
              pw.Header(level: 1, child: pw.Text('Quality Checks')),
              pw.TableHelper.fromTextArray(
                context: context,
                headers: ['Parameter', 'Category', 'Result', 'Checked By'],
                data: checks.map((c) => [
                  c.parameter,
                  c.category,
                  c.result,
                  c.checkedBy,
                ]).toList(),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Generate Report', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  if (_reports.isEmpty)
                    const Text('No reports available.')
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownButtonFormField<DailyReport>(
                              initialValue: _selectedReport,
                              items: _reports.map((r) => DropdownMenuItem(value: r, child: Text('${r.reportNumber} - ${r.date}'))).toList(),
                              onChanged: (v) => setState(() => _selectedReport = v),
                              decoration: const InputDecoration(labelText: 'Select Daily Report', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Generate PDF'),
                              onPressed: _generatePdf,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
