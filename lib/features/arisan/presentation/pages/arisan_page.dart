import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../shared/widgets/inputs/search_bar_card.dart';
import '../../../jamaah/data/jamaah_local_database.dart';
import '../../../jamaah/data/jamaah_member.dart';
import '../../data/arisan.dart';
import '../../data/arisan_local_database.dart';
import 'arisan_form_page.dart';

class ArisanPage extends StatefulWidget {
  const ArisanPage({super.key});

  @override
  State<ArisanPage> createState() => _ArisanPageState();
}

class _ArisanPageState extends State<ArisanPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Arisan> _arisans = <Arisan>[];
  List<JamaahMember> _members = <JamaahMember>[];
  bool _loading = true;
  bool _showWinner = false;
  ArisanParticipant? _winner;

  List<Arisan> get filteredArisans {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _arisans;
    return _arisans.where((Arisan item) {
      return item.name.toLowerCase().contains(query) ||
          (item.agendaTitle?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });

    final arisans = await ArisanLocalDatabase.instance.getAllArisans();
    final members = await JamaahLocalDatabase.instance.getAllMembers();

    if (!mounted) return;
    setState(() {
      _arisans = arisans;
      _members = members;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView(
          padding: const EdgeInsets.all(14),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Manage Arisan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_arisans.length} grup arisan',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _openCreateForm,
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SearchBarCard(
              placeholder: 'Cari arisan...',
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              trailing: _searchController.text.isEmpty
                  ? const SizedBox.shrink()
                  : InkWell(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (filteredArisans.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppColors.radiusLg),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Column(
                  children: <Widget>[
                    Icon(
                      Icons.celebration_outlined,
                      size: 40,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada arisan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Buat arisan baru untuk memulai.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredArisans.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildArisanItem(item, index);
              }),
            const SizedBox(height: 80),
          ],
        ),
        if (_showWinner && _winner != null)
          IgnorePointer(
            ignoring: !_showWinner,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showWinner = false;
                });
              },
              child: Container(
                color: const Color(0x99000000),
                alignment: Alignment.center,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.92, end: 1),
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Container(
                    width: 260,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppColors.radiusXl),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x4D000000),
                          blurRadius: 40,
                          offset: Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primary,
                          child: Text('🎉', style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Pemenang Undian!',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _winner!.memberName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppColors.radiusMd,
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _showWinner = false;
                            });
                          },
                          child: const Text('Selesai'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildArisanItem(Arisan item, int index) {
    final paid = item.currentRound;
    final total = item.totalRounds;
    final remaining = total - paid;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openDetail(item),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Putaran ke-$paid dari $total',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item.amountFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 6,
                  color: AppColors.primary,
                  backgroundColor: AppColors.border,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$paid sudah bayar',
                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
              Text(
                '$remaining belum',
                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _kocokArisan(item),
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.shuffle_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kocok Arisan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateForm() async {
    final result = await Navigator.of(
      context,
    ).push<Arisan>(buildVentriRoute<Arisan>(ArisanFormPage(members: _members)));
    if (result == null) return;
    await _loadData();
  }

  Future<void> _openDetail(Arisan arisan) async {
    await Navigator.of(context).push<Object?>(
      buildVentriRoute<Object?>(
        ArisanDetailPage(arisan: arisan, members: _members),
      ),
    );
    await _loadData();
  }

  Future<void> _kocokArisan(Arisan arisan) async {
    final participants = await ArisanLocalDatabase.instance.getParticipants(
      arisan.id!,
    );
    final unpaid = participants
        .where((p) => !p.hasPaid && p.wonRound == 0)
        .toList();

    if (unpaid.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada anggota yang bisa diundi'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final random = Random();
    final winner = unpaid[random.nextInt(unpaid.length)];

    setState(() {
      _winner = winner;
      _showWinner = true;
    });
  }
}

class ArisanDetailPage extends StatefulWidget {
  const ArisanDetailPage({
    super.key,
    required this.arisan,
    required this.members,
  });

  final Arisan arisan;
  final List<JamaahMember> members;

  @override
  State<ArisanDetailPage> createState() => _ArisanDetailPageState();
}

class _ArisanDetailPageState extends State<ArisanDetailPage> {
  late Arisan _arisan;
  List<ArisanParticipant> _participants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _arisan = widget.arisan;
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    final participants = await ArisanLocalDatabase.instance.getParticipants(
      _arisan.id!,
    );
    if (!mounted) return;
    setState(() {
      _participants = participants;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_arisan.name),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editArisan,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[AppColors.primary, Color(0xFF5A8B68)],
                    ),
                    borderRadius: BorderRadius.circular(AppColors.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _arisan.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _arisan.amountFormatted,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: _arisan.progress,
                          minHeight: 8,
                          color: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Putaran ke-${_arisan.currentRound} dari ${_arisan.totalRounds}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                      if (_arisan.agendaTitle != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.event,
                              size: 12,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Agenda: ${_arisan.agendaTitle}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Anggota',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addParticipant,
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Tambah'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_participants.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppColors.radiusMd),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Center(
                      child: Text(
                        'Belum ada anggota',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                else
                  ...(_participants.map(_buildParticipantItem)),
              ],
            ),
    );
  }

  Widget _buildParticipantItem(ArisanParticipant participant) {
    final isWinner = participant.wonRound > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isWinner ? AppColors.primaryBg : AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          border: Border.all(
            color: isWinner ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 18,
              backgroundColor: isWinner ? AppColors.primary : AppColors.card,
              child: Text(
                participant.memberName
                    .split(' ')
                    .map((n) => n.isNotEmpty ? n[0] : '')
                    .take(2)
                    .join(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isWinner ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    participant.memberName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isWinner)
                    Text(
                      'Menang put. ${participant.wonRound}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: participant.hasPaid
                    ? AppColors.success
                    : AppColors.warning,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                participant.hasPaid ? 'Lunas' : 'Belum',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (value) {
                if (value == 'toggle') {
                  _togglePayment(participant);
                } else if (value == 'remove') {
                  _removeParticipant(participant);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    participant.hasPaid ? 'Tandai Belum Bayar' : 'Tandai Lunas',
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text(
                    'Hapus',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editArisan() async {
    final result = await Navigator.of(context).push<Arisan>(
      buildVentriRoute<Arisan>(
        ArisanFormPage(arisan: _arisan, members: widget.members),
      ),
    );
    if (result != null) {
      setState(() {
        _arisan = result;
      });
    }
  }

  Future<void> _addParticipant() async {
    final availableMembers = widget.members.where((m) {
      return !_participants.any((p) => p.memberId == m.id);
    }).toList();

    if (availableMembers.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua anggota sudah terdaftar'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<JamaahMember>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _MemberSelectionSheet(members: availableMembers),
    );

    if (selected != null) {
      await ArisanLocalDatabase.instance.addParticipant(
        ArisanParticipant(
          arisanId: _arisan.id!,
          memberId: selected.id!,
          memberName: selected.name,
          hasPaid: false,
          wonRound: 0,
        ),
      );
      await _loadParticipants();
    }
  }

  Future<void> _togglePayment(ArisanParticipant participant) async {
    await ArisanLocalDatabase.instance.updateParticipant(
      participant.copyWith(
        hasPaid: !participant.hasPaid,
        paidAt: !participant.hasPaid ? DateTime.now() : null,
      ),
    );
    await _loadParticipants();
  }

  Future<void> _removeParticipant(ArisanParticipant participant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusXl),
        ),
        title: const Text('Hapus Anggota'),
        content: Text('Hapus ${participant.memberName} dari arisan?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && participant.id != null) {
      await ArisanLocalDatabase.instance.removeParticipant(participant.id!);
      await _loadParticipants();
    }
  }
}

class _MemberSelectionSheet extends StatefulWidget {
  const _MemberSelectionSheet({required this.members});

  final List<JamaahMember> members;

  @override
  State<_MemberSelectionSheet> createState() => _MemberSelectionSheetState();
}

class _MemberSelectionSheetState extends State<_MemberSelectionSheet> {
  List<JamaahMember> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.members;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Pilih Anggota',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Cari anggota...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  _filtered = widget.members;
                } else {
                  _filtered = widget.members.where((m) {
                    return m.name.toLowerCase().contains(value.toLowerCase());
                  }).toList();
                }
              });
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final member = _filtered[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryBg,
                    child: Text(
                      member.initials,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(member.name),
                  subtitle: Text(member.detail),
                  onTap: () => Navigator.of(context).pop(member),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
