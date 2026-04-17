import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/buttons/circle_icon_button.dart';
import '../../data/ibadah_asset_models.dart';
import '../../data/ibadah_asset_repository.dart';
import '../widgets/auto_scroll_button.dart';

class TahlilPage extends StatefulWidget {
  const TahlilPage({super.key});

  @override
  State<TahlilPage> createState() => _TahlilPageState();
}

class _TahlilPageState extends State<TahlilPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;
  Timer? _timer;
  TahlilAsset? _tahlil;

  @override
  void initState() {
    super.initState();
    _loadTahlil();
  }

  Future<void> _loadTahlil() async {
    final tahlil = await IbadahAssetRepository.instance.loadTahlil();
    if (mounted) {
      setState(() => _tahlil = tahlil);
    }
  }

  void _toggleScrolling() {
    if (_isScrolling) {
      _timer?.cancel();
      setState(() => _isScrolling = false);
    } else {
      setState(() => _isScrolling = true);
      _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (!_scrollController.hasClients) return;
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        if (currentScroll >= maxScroll) {
          _timer?.cancel();
          setState(() => _isScrolling = false);
          return;
        }
        _scrollController.jumpTo(currentScroll + 1.0);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        leadingWidth: 56,
        title: const Text('Tahlil'),
      ),
      body: _tahlil == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _tahlil!.konten.length,
                    itemBuilder: (BuildContext context, int sectionIndex) {
                      final section = _tahlil!.konten[sectionIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (sectionIndex > 0)
                            const Divider(color: AppColors.border),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              section.bagian,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          ...section.data.asMap().entries.map((entry) {
                            final itemIndex = entry.key;
                            final item = entry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  width: 28,
                                  height: 28,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${sectionIndex + 1}.${itemIndex + 1}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item.arab,
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    height: 1.8,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.latin,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(top: 8),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: AppColors.borderLight,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          item.terjemah,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                      if (item.ulang > 1)
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBg,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '×${item.ulang}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      AutoScrollButton(
                        isActive: _isScrolling,
                        onTap: _toggleScrolling,
                      ),
                      Text(
                        '${_tahlil!.allItems.length} Bacaan',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
