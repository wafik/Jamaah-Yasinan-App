import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../shared/widgets/cards/ventri_card.dart';
import '../../data/ibadah_asset_models.dart';
import '../../data/ibadah_asset_repository.dart';
import 'surah_detail_page.dart';

class SuratPilihanPage extends StatelessWidget {
  const SuratPilihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Surat Pilihan')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Kumpulan surat dimuat dari aset JSON lokal',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SurahAsset>>(
              future: IbadahAssetRepository.instance.loadSuratPilihan(),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<SurahAsset>> snapshot,
                  ) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Gagal memuat surat pilihan: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          'Gagal memuat surat pilihan',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      );
                    }

                    final items = snapshot.data!;

                    return ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = items[index];
                        final highlight =
                            item.latinName.toLowerCase() == 'al-mulk';

                        return VentriCard(
                          margin: const EdgeInsets.only(bottom: 10),
                          highlight: highlight,
                          onTap: () => Navigator.of(context).push(
                            buildVentriRoute<void>(
                              SurahDetailPage(surah: item),
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBg,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  '🫅',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      item.latinName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.listSubtitle,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.revelation,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }
}
