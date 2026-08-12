import 'package:flutter/material.dart';
import 'package:product_tracker/models/quality_check_model.dart';
import 'package:product_tracker/repositories/quality_repository.dart';
import 'package:product_tracker/repositories/production_repository.dart';
import 'package:product_tracker/repositories/master_data_repository.dart';

class QualityCheckScreen extends StatefulWidget {
  const QualityCheckScreen({super.key});

  @override
  State<QualityCheckScreen> createState() => _QualityCheckScreenState();
}

class _QualityCheckScreenState extends State<QualityCheckScreen> {
  final QualityRepository _qualityRepo = QualityRepository();
  final ProductionRepository _productionRepo = ProductionRepository();
  final MasterDataRepository _masterDataRepo = MasterDataRepository();

  bool _isLoading = true;
  List<QualityCheck> _checks = [];

  @override
  void initState() {
    super.initState();
    _loadChecks();
  }

  Future<void> _loadChecks() async {
    setState(() => _isLoading = true);
    try {
      final checks = await _qualityRepo.getQualityChecks();
      setState(() {
        _checks = checks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _getResultColor(String result) {
    switch (result.toLowerCase()) {
      case 'pass':
        return Colors.green;
      case 'fail':
        return Colors.red;
      case 'conditional':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showQualityCheckForm([QualityCheck? check]) async {
    final formKey = GlobalKey<FormState>();
    int? dailyReportId = check?.dailyReportId;
    String parameter = check?.parameter ?? '';
    String category = check?.category ?? '';
    String result = check?.result ?? 'Pass';
    String checkedBy = check?.checkedBy ?? '';
    String remarks = check?.remarks ?? '';
    String date = check?.date ?? DateTime.now().toIso8601String().split('T').first;

    List<int> reportIds = [];
    List<String> parameters = [];
    List<String> employees = [];

    try {
      final reports = await _productionRepo.getDailyReports();
      reportIds = reports.map((r) => r.id!).toList();
      if (reportIds.isNotEmpty && dailyReportId == null) dailyReportId = reportIds.first;

      parameters = await _masterDataRepo.getParameterNames();
      if (parameters.isNotEmpty && parameter.isEmpty) parameter = parameters.first;

      employees = await _masterDataRepo.getEmployeeNames();
      if (employees.isNotEmpty && checkedBy.isEmpty) checkedBy = employees.first;
    } catch (e) {
      // Ignore
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(check == null ? 'Add Quality Check' : 'Edit Quality Check'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: dailyReportId,
                    items: reportIds.map((id) => DropdownMenuItem(value: id, child: Text('Report ID: $id'))).toList(),
                    onChanged: (v) => dailyReportId = v,
                    decoration: const InputDecoration(labelText: 'Daily Report'),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: parameter.isEmpty ? null : parameter,
                    items: parameters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => parameter = v!,
                    decoration: const InputDecoration(labelText: 'Parameter'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => category = v!,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: result,
                    items: ['Pass', 'Fail', 'Conditional'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => result = v!,
                    decoration: const InputDecoration(labelText: 'Result'),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: checkedBy.isEmpty ? null : checkedBy,
                    items: employees.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => checkedBy = v!,
                    decoration: const InputDecoration(labelText: 'Checked By'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    initialValue: remarks,
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
                    final newCheck = QualityCheck(
                      id: check?.id,
                      dailyReportId: dailyReportId!,
                      date: date,
                      parameter: parameter,
                      category: category,
                      result: result,
                      checkedBy: checkedBy,
                      remarks: remarks.isEmpty ? null : remarks,
                    );
                    if (check == null) {
                      await _qualityRepo.addQualityCheck(newCheck);
                    } else {
                      await _qualityRepo.updateQualityCheck(newCheck);
                    }
                    _loadChecks();
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: Text(check == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _checks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No quality checks found'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadChecks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _checks.length,
                    itemBuilder: (context, index) {
                      final check = _checks[index];
                      return Dismissible(
                        key: ValueKey(check.id),
                        background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) async {
                          await _qualityRepo.deleteQualityCheck(check.id!);
                          _loadChecks();
                        },
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getResultColor(check.result),
                              child: const Icon(Icons.check, color: Colors.white),
                            ),
                            title: Text(check.parameter, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${check.category} | Checked by: ${check.checkedBy} | Date: ${check.date}'),
                            trailing: Text(check.result, style: TextStyle(color: _getResultColor(check.result), fontWeight: FontWeight.bold)),
                            onTap: () => _showQualityCheckForm(check),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQualityCheckForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
