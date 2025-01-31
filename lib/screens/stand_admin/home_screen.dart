import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stand_stats_provider.dart';
import '../../services/stand_admin/stand_service.dart';
import '../../widgets/stand_admin/stats.dart';

class StandStatsPage extends StatelessWidget {
  const StandStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StandStatsProvider(
        Provider.of<StandService>(context, listen: false),
      )..loadStats(),
      child: const StandStatsView(),
    );
  }
}

class StandStatsView extends StatelessWidget {
  const StandStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Stand Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: () => context.read<StandStatsProvider>().refresh(),
          ),
        ],
      ),
      body: Consumer<StandStatsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: provider.refresh,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final stats = provider.stats!;

          return RefreshIndicator(
            onRefresh: provider.loadStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandStatsComponents.buildOverviewCards(stats),
                  const SizedBox(height: 20),
                  StandStatsComponents.buildMonthlyIncomeChart(stats),
                  const SizedBox(height: 20),
                  StandStatsComponents.buildTopSellingMenus(stats),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
