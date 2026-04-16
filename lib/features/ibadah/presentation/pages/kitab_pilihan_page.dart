import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../shared/widgets/cards/ventri_card.dart';
import '../../data/ibadah_asset_models.dart';
import '../../data/ibadah_asset_repository.dart';
import 'kitab_detail_page.dart';

class KitabPilihanPage extends StatelessWidget {
  const KitabPilihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitab Pilihan')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Kitab dimuat dari aset JSON lokal',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: FutureBuilder<KitabAsset>(
              future: IbadahAssetRepository.instance.loadArbain(),
              builder:
                  (BuildContext context, AsyncSnapshot<KitabAsset> snapshot) {
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
                          'Gagal memuat kitab pilihan: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          'Gagal memuat kitab pilihan',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      );
                    }

                    final kitab = snapshot.data!;

                    return ListView(
                      padding: const EdgeInsets.all(14),
                      children: <Widget>[
                        VentriCard(
                          onTap: () => Navigator.of(context).push(
                            buildVentriRoute<void>(
                              KitabDetailPage(kitab: kitab),
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
                                  '📖',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      kitab.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      kitab.listSubtitle,
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
                                child: const Text(
                                  'JSON',
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
                      ],
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }
}
