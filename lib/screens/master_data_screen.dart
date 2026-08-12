import 'package:flutter/material.dart';
import 'package:product_tracker/models/master_data_models.dart';
import 'package:product_tracker/repositories/master_data_repository.dart';

class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({super.key});

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MasterDataRepository _repo = MasterDataRepository();

  bool _isLoading = true;
  List<Employee> _employees = [];
  List<ProductionLine> _lines = [];
  List<ModelItem> _models = [];
  List<QualityParameter> _parameters = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final emp = await _repo.getEmployees();
      final lin = await _repo.getProductionLines();
      final mod = await _repo.getModels();
      final par = await _repo.getParameters();
      setState(() {
        _employees = emp;
        _lines = lin;
        _models = mod;
        _parameters = par;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Employees'),
              Tab(text: 'Lines'),
              Tab(text: 'Models'),
              Tab(text: 'Parameters'),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEmployeeList(),
                _buildLineList(),
                _buildModelList(),
                _buildParameterList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (_tabController.index) {
            case 0: _showEmployeeForm(); break;
            case 1: _showLineForm(); break;
            case 2: _showModelForm(); break;
            case 3: _showParameterForm(); break;
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmployeeList() {
    if (_employees.isEmpty) return const Center(child: Text('No employees'));
    return ListView.builder(
      itemCount: _employees.length,
      itemBuilder: (context, i) {
        final emp = _employees[i];
        return Dismissible(
          key: ValueKey(emp.id),
          onDismissed: (_) async { await _repo.deleteEmployee(emp.id!); _loadAll(); },
          child: ListTile(
            title: Text(emp.name),
            subtitle: Text('${emp.employeeCode} | ${emp.role}'),
            onTap: () => _showEmployeeForm(emp),
          ),
        );
      },
    );
  }

  Widget _buildLineList() {
    if (_lines.isEmpty) return const Center(child: Text('No lines'));
    return ListView.builder(
      itemCount: _lines.length,
      itemBuilder: (context, i) {
        final line = _lines[i];
        return Dismissible(
          key: ValueKey(line.id),
          onDismissed: (_) async { await _repo.deleteProductionLine(line.id!); _loadAll(); },
          child: ListTile(
            title: Text(line.name),
            subtitle: Text('${line.lineCode} | ${line.status}'),
            onTap: () => _showLineForm(line),
          ),
        );
      },
    );
  }

  Widget _buildModelList() {
    if (_models.isEmpty) return const Center(child: Text('No models'));
    return ListView.builder(
      itemCount: _models.length,
      itemBuilder: (context, i) {
        final mod = _models[i];
        return Dismissible(
          key: ValueKey(mod.id),
          onDismissed: (_) async { await _repo.deleteModel(mod.id!); _loadAll(); },
          child: ListTile(
            title: Text(mod.name),
            subtitle: Text('${mod.modelCode} | Target: ${mod.targetRate}'),
            onTap: () => _showModelForm(mod),
          ),
        );
      },
    );
  }

  Widget _buildParameterList() {
    if (_parameters.isEmpty) return const Center(child: Text('No parameters'));
    return ListView.builder(
      itemCount: _parameters.length,
      itemBuilder: (context, i) {
        final p = _parameters[i];
        return Dismissible(
          key: ValueKey(p.id),
          onDismissed: (_) async { await _repo.deleteParameter(p.id!); _loadAll(); },
          child: ListTile(
            title: Text(p.name),
            subtitle: Text('${p.paramCode} | ${p.category}'),
            onTap: () => _showParameterForm(p),
          ),
        );
      },
    );
  }

  Future<void> _showEmployeeForm([Employee? emp]) async {
    final formKey = GlobalKey<FormState>();
    String code = emp?.employeeCode ?? '';
    String name = emp?.name ?? '';
    String role = emp?.role ?? 'Operator';
    String shift = emp?.shift ?? 'Morning';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(emp == null ? 'Add Employee' : 'Edit Employee'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(initialValue: code, decoration: const InputDecoration(labelText: 'Code'), onSaved: (v) => code = v!, validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(initialValue: name, decoration: const InputDecoration(labelText: 'Name'), onSaved: (v) => name = v!, validator: (v) => v!.isEmpty ? 'Required' : null),
                DropdownButtonFormField<String>(initialValue: role, items: ['Operator', 'Supervisor', 'QC Inspector', 'Engineer'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => role = v!, decoration: const InputDecoration(labelText: 'Role')),
                DropdownButtonFormField<String>(initialValue: shift, items: ['Morning', 'Afternoon', 'Night'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => shift = v!, decoration: const InputDecoration(labelText: 'Shift')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              Navigator.pop(context);
              final e = Employee(id: emp?.id, employeeCode: code, name: name, role: role, shift: shift);
              emp == null ? await _repo.addEmployee(e) : await _repo.updateEmployee(e);
              _loadAll();
            }
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _showLineForm([ProductionLine? line]) async {
    final formKey = GlobalKey<FormState>();
    String code = line?.lineCode ?? '';
    String name = line?.name ?? '';
    String dept = line?.department ?? '';
    String status = line?.status ?? 'Active';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(line == null ? 'Add Line' : 'Edit Line'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(initialValue: code, decoration: const InputDecoration(labelText: 'Code'), onSaved: (v) => code = v!, validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(initialValue: name, decoration: const InputDecoration(labelText: 'Name'), onSaved: (v) => name = v!, validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(initialValue: dept, decoration: const InputDecoration(labelText: 'Department'), onSaved: (v) => dept = v!, validator: (v) => v!.isEmpty ? 'Required' : null),
                DropdownButtonFormField<String>(initialValue: status, items: ['Active', 'Inactive', 'Maintenance'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => status = v!, decoration: const InputDecoration(labelText: 'Status')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              Navigator.pop(context);
              final l = ProductionLine(id: line?.id, lineCode: code, name: name, department: dept, status: status);
              line == null ? await _repo.addProductionLine(l) : await _repo.updateProductionLine(l);
              _loadAll();
            }
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _showModelForm([ModelItem? model]) async {
    final formKey = GlobalKey<FormState>();
    String code = model?.modelCode ?? '';
    String name = model?.name ?? '';
    int target = model?.targetRate ?? 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(model == null ? 'Add Model' : 'Edit Model'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(initialValue: code, decoration: const InputDecoration(labelText: 'Code'), onSaved: (v) => code = v!, validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(initialValue: name, decoration: const InputDecoration(labelText: 'Name'), onSaved: (v) => name = v!, validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(initialValue: target.toString(), decoration: const InputDecoration(labelText: 'Target Rate'), keyboardType: TextInputType.number, onSaved: (v) => target = int.parse(v!), validator: (v) => int.tryParse(v!) == null ? 'Invalid' : null),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              Navigator.pop(context);
              final m = ModelItem(id: model?.id, modelCode: code, name: name, targetRate: target);
              model == null ? await _repo.addModel(m) : await _repo.updateModel(m);
              _loadAll();
            }
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _showParameterForm([QualityParameter? p]) async {
    final formKey = GlobalKey<FormState>();
    String code = p?.paramCode ?? '';
    String name = p?.name ?? '';
    String category = p?.category ?? '';
    String expected = p?.expectedValue ?? '';
    String unit = p?.unit ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(p == null ? 'Add Parameter' : 'Edit Parameter'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(initialValue: code, decoration: const InputDecoration(labelText: 'Code'), onSaved: (v) => code = v!, validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(initialValue: name, decoration: const InputDecoration(labelText: 'Name'), onSaved: (v) => name = v!, validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(initialValue: category, decoration: const InputDecoration(labelText: 'Category'), onSaved: (v) => category = v!, validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(initialValue: expected, decoration: const InputDecoration(labelText: 'Expected Value'), onSaved: (v) => expected = v!),
                TextFormField(initialValue: unit, decoration: const InputDecoration(labelText: 'Unit'), onSaved: (v) => unit = v!),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              Navigator.pop(context);
              final newP = QualityParameter(id: p?.id, paramCode: code, name: name, category: category, expectedValue: expected, unit: unit);
              p == null ? await _repo.addParameter(newP) : await _repo.updateParameter(newP);
              _loadAll();
            }
          }, child: const Text('Save')),
        ],
      ),
    );
  }
}
