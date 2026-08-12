import 'package:flutter/material.dart';
import 'package:product_tracker/models/daily_report_model.dart';
import 'package:product_tracker/models/production_entry_model.dart';
import 'package:product_tracker/repositories/production_repository.dart';
import 'package:product_tracker/repositories/master_data_repository.dart';

class ProductionListScreen extends StatefulWidget {
  const ProductionListScreen({super.key});

  @override
  State<ProductionListScreen> createState() => _ProductionListScreenState();
}

class _ProductionListScreenState extends State<ProductionListScreen> {
  final ProductionRepository _productionRepo = ProductionRepository();
  final MasterDataRepository _masterDataRepo = MasterDataRepository();

  bool _isLoading = true;
  List<DailyReport> _reports = [];

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showCreateReportDialog() async {
    final formKey = GlobalKey<FormState>();
    String reportNumber = '';
    String date = DateTime.now().toIso8601String().split('T').first;
    String shift = 'Morning';
    String productionLine = '';
    List<String> lines = [];

    try {
      lines = await _masterDataRepo.getProductionLineNames();
      if (lines.isNotEmpty) productionLine = lines.first;
    } catch (e) {
      // Ignore
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Daily Report'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Report Number'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => reportNumber = v!,
                  ),
                  TextFormField(
                    initialValue: date,
                    decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => date = v!,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: shift,
                    items: ['Morning', 'Afternoon', 'Night']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => shift = v!,
                    decoration: const InputDecoration(labelText: 'Shift'),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: productionLine.isEmpty ? null : productionLine,
                    items: lines.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => productionLine = v!,
                    decoration: const InputDecoration(labelText: 'Production Line'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.pop(context);
                  try {
                    await _productionRepo.createDailyReport(DailyReport(
                      reportNumber: reportNumber,
                      date: date,
                      shift: shift,
                      productionLine: productionLine,
                    ));
                    _loadReports();
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewReportDetails(DailyReport report) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _ReportDetailsSheet(
          report: report,
          productionRepo: _productionRepo,
          masterDataRepo: _masterDataRepo,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No reports found'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            child: Icon(Icons.assignment, color: Theme.of(context).colorScheme.onSecondaryContainer),
                          ),
                          title: Text(report.reportNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${report.date} | ${report.shift} | ${report.productionLine}'),
                          onTap: () => _viewReportDetails(report),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateReportDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ReportDetailsSheet extends StatefulWidget {
  final DailyReport report;
  final ProductionRepository productionRepo;
  final MasterDataRepository masterDataRepo;

  const _ReportDetailsSheet({
    required this.report,
    required this.productionRepo,
    required this.masterDataRepo,
  });

  @override
  State<_ReportDetailsSheet> createState() => _ReportDetailsSheetState();
}

class _ReportDetailsSheetState extends State<_ReportDetailsSheet> {
  bool _isLoading = true;
  List<ProductionEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final entries = await widget.productionRepo.getProductionEntries(widget.report.id!);
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showAddEntryDialog() async {
    final formKey = GlobalKey<FormState>();
    String hour = '';
    String personInCharge = '';
    String model = '';
    int target = 0;
    int achieved = 0;
    int downtime = 0;
    String remarks = '';

    List<String> employees = [];
    List<String> models = [];

    try {
      employees = await widget.masterDataRepo.getEmployeeNames();
      models = await widget.masterDataRepo.getModelNames();
      if (employees.isNotEmpty) personInCharge = employees.first;
      if (models.isNotEmpty) model = models.first;
    } catch (e) {
      // Ignore
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Production Entry'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Hour (e.g., 08:00 - 09:00)'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => hour = v!,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: personInCharge.isEmpty ? null : personInCharge,
                    items: employees.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => personInCharge = v!,
                    decoration: const InputDecoration(labelText: 'Person In Charge'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: model.isEmpty ? null : model,
                    items: models.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => model = v!,
                    decoration: const InputDecoration(labelText: 'Model'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Target'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid number' : null,
                    onSaved: (v) => target = int.parse(v!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Achieved'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid number' : null,
                    onSaved: (v) => achieved = int.parse(v!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Downtime (min)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid number' : null,
                    onSaved: (v) => downtime = int.parse(v!),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Remarks'),
                    onSaved: (v) => remarks = v ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.pop(context);
                  try {
                    await widget.productionRepo.addProductionEntry(ProductionEntry(
                      dailyReportId: widget.report.id!,
                      date: widget.report.date,
                      hour: hour,
                      personInCharge: personInCharge,
                      model: model,
                      target: target,
                      achieved: achieved,
                      downtime: downtime,
                      remarks: remarks.isEmpty ? null : remarks,
                    ));
                    _loadEntries();
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Entries for ${widget.report.reportNumber}', style: Theme.of(context).textTheme.titleLarge),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _entries.isEmpty
                      ? const Center(child: Text('No entries found'))
                      : ListView.builder(
                          itemCount: _entries.length,
                          itemBuilder: (context, index) {
                            final entry = _entries[index];
                            return Dismissible(
                              key: ValueKey(entry.id),
                              background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) async {
                                await widget.productionRepo.deleteProductionEntry(entry.id!);
                                _loadEntries();
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text('${entry.hour} - ${entry.model}'),
                                  subtitle: Text('Target: ${entry.target} | Achieved: ${entry.achieved} | Eff: ${entry.efficiency.toStringAsFixed(1)}%'),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Entry'),
                onPressed: _showAddEntryDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
