import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cards/ventri_card.dart';
import '../../data/dzikir.dart';
import '../../data/dzikir_local_database.dart';

class DzikirCounterPage extends StatefulWidget {
  const DzikirCounterPage({super.key});

  @override
  State<DzikirCounterPage> createState() => _DzikirCounterPageState();
}

class _DzikirCounterPageState extends State<DzikirCounterPage> {
  @override
  Widget build(BuildContext context) {
    return const _DzikirListView();
  }
}

class _DzikirListView extends StatefulWidget {
  const _DzikirListView();

  @override
  State<_DzikirListView> createState() => _DzikirListViewState();
}

class _DzikirListViewState extends State<_DzikirListView> {
  List<Dzikir> _dzikirList = [];
  bool _isLoading = true;

  static final List<Map<String, dynamic>> _dzikirTypes = [
    {'name': 'Subhanallah', 'target': 33, 'icon': Icons.check_circle_outline},
    {'name': 'Alhmadulillah', 'target': 33, 'icon': Icons.thumb_up_outlined},
    {'name': 'Allahu Akbar', 'target': 33, 'icon': Icons.celebration_outlined},
    {
      'name': 'Laa ilaaha illallah',
      'target': 100,
      'icon': Icons.remove_red_eye_outlined,
    },
    {
      'name': 'Astaghfirullah',
      'target': 70,
      'icon': Icons.sentiment_satisfied_outlined,
    },
    {'name': 'Yaa Robb', 'target': 100, 'icon': Icons.record_voice_over},
  ];

  @override
  void initState() {
    super.initState();
    _loadDzikirList();
  }

  Future<void> _loadDzikirList() async {
    final list = await DzikirLocalDatabase.instance.getAllDzikir();
    if (!mounted) return;
    setState(() {
      _dzikirList = list;
      _isLoading = false;
    });
  }

  Future<void> _startDzikir(String name, int target) async {
    final newDzikir = Dzikir(
      targetCount: target,
      currentCount: 0,
      name: name,
      createdAt: DateTime.now(),
    );
    final id = await DzikirLocalDatabase.instance.insertDzikir(newDzikir);
    if (!mounted) return;

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                _DzikirCounterView(dzikir: newDzikir.copyWith(id: id)),
          ),
        )
        .then((_) => _loadDzikirList());
  }

  void _showAddDialog() {
    String selectedName = _dzikirTypes[0]['name'];
    int selectedTarget = _dzikirTypes[0]['target'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pilih Dzikir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jenis Dzikir'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: _dzikirTypes.map((item) {
                  return DropdownMenuItem(
                    value: item['name'] as String,
                    child: Text(item['name'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final type = _dzikirTypes.firstWhere(
                      (t) => t['name'] == value,
                    );
                    setDialogState(() {
                      selectedName = value;
                      selectedTarget = type['target'] as int;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Target'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: selectedTarget,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 33, child: Text('33x')),
                  DropdownMenuItem(value: 66, child: Text('66x')),
                  DropdownMenuItem(value: 99, child: Text('99x')),
                  DropdownMenuItem(value: 100, child: Text('100x')),
                  DropdownMenuItem(value: 200, child: Text('200x')),
                  DropdownMenuItem(value: 300, child: Text('300x')),
                  DropdownMenuItem(value: 500, child: Text('500x')),
                  DropdownMenuItem(value: 1000, child: Text('1000x')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      selectedTarget = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startDzikir(selectedName, selectedTarget);
              },
              child: const Text('Mulai'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dzikir'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _dzikirList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada dzikir',
                    style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + untuk memulai',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dzikirList.length,
              itemBuilder: (context, index) {
                final dzikir = _dzikirList[index];
                final isComplete = dzikir.isComplete;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VentriCard(
                    onTap: isComplete
                        ? null
                        : () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        _DzikirCounterView(dzikir: dzikir),
                                  ),
                                )
                                .then((_) => _loadDzikirList());
                          },
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isComplete
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppColors.radiusMd,
                            ),
                          ),
                          child: Icon(
                            isComplete
                                ? Icons.check_circle
                                : Icons.play_arrow_rounded,
                            color: isComplete
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dzikir.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${dzikir.currentCount} / ${dzikir.targetCount}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isComplete)
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Selesai',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _DzikirCounterView extends StatefulWidget {
  const _DzikirCounterView({required this.dzikir});

  final Dzikir dzikir;

  @override
  State<_DzikirCounterView> createState() => _DzikirCounterViewState();
}

class _DzikirCounterViewState extends State<_DzikirCounterView> {
  late int _currentCount;
  late int _targetCount;
  late String _dzikirName;
  late int? _dzikirId;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.dzikir.currentCount;
    _targetCount = widget.dzikir.targetCount;
    _dzikirName = widget.dzikir.name;
    _dzikirId = widget.dzikir.id;
  }

  Future<void> _increment() async {
    if (_isComplete) return;

    HapticFeedback.mediumImpact();
    await DzikirLocalDatabase.instance.incrementCount(_dzikirId!);

    final newCount = _currentCount + 1;
    setState(() {
      _currentCount = newCount;
      _isComplete = newCount >= _targetCount;
    });

    if (_isComplete) {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_dzikirName), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  _dzikirName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Target: $_targetCount',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _increment,
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_currentCount',
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: _isComplete
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isComplete ? 'MashAllah!' : 'Tap untuk menghitung',
                      style: TextStyle(
                        fontSize: 16,
                        color: _isComplete
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _isComplete
                ? ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Selesai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
          ),
        ],
      ),
    );
  }
}
