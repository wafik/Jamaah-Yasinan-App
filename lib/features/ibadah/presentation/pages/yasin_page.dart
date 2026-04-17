import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/buttons/circle_icon_button.dart';
import '../../data/ibadah_asset_models.dart';
import '../../data/ibadah_asset_repository.dart';
import '../widgets/auto_scroll_button.dart';

class YasinPage extends StatefulWidget {
  const YasinPage({
    super.key,
    this.title = 'Surat Yasin',
    this.assetPath = 'assets/json/surat/yasin.json',
  });

  final String title;
  final String assetPath;

  @override
  State<YasinPage> createState() => _YasinPageState();
}

class _YasinPageState extends State<YasinPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;
  Timer? _timer;

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
        title: Text(widget.title),
      ),
      body: FutureBuilder<SurahAsset>(
        future: IbadahAssetRepository.instance.loadSurahSource(
          widget.assetPath,
        ),
        builder: (BuildContext context, AsyncSnapshot<SurahAsset> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Gagal memuat surat',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          final surah = snapshot.data!;

          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: surah.ayahs.length + 1,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(color: AppColors.border),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Column(
                        children: <Widget>[
                          Text(
                            surah.name,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 26,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 24,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${surah.latinName} • ${surah.ayahCount} ayat • ${surah.revelation}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      );
                    }

                    final ayat = surah.ayahs[index - 1];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${ayat.number}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          ayat.arabic,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 2,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppColors.borderLight),
                            ),
                          ),
                          child: Text(
                            ayat.translation,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.7,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
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
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    AutoScrollButton(
                      isActive: _isScrolling,
                      onTap: _toggleScrolling,
                    ),
                    Row(
                      children: <Widget>[
                        const Text(
                          'A',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 48,
                          child:
                              _scrollController.hasClients &&
                                  _scrollController.position.maxScrollExtent > 0
                              ? LinearProgressIndicator(
                                  value:
                                      (_scrollController.offset /
                                              _scrollController
                                                  .position
                                                  .maxScrollExtent)
                                          .clamp(0.0, 1.0),
                                  minHeight: 3,
                                  color: AppColors.primary,
                                  backgroundColor: AppColors.border,
                                )
                              : const LinearProgressIndicator(
                                  value: 0,
                                  minHeight: 3,
                                  color: AppColors.primary,
                                  backgroundColor: AppColors.border,
                                ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'A',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
