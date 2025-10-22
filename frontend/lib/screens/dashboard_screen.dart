import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/widgets/etl_modal.dart';
import 'package:provider/provider.dart';
import '../providers/page_provider.dart';
import './tabs/tab_ranking_top.dart';
import './tabs/tab_trending.dart';
import './tabs/tab_page_detail.dart';
import './tabs/tab_etl_admin.dart';

const List<TabItem> tabItems = [
  TabItem(title: 'Ranking TOP', icon: FontAwesomeIcons.chartLine),
  TabItem(title: 'Tendencias', icon: FontAwesomeIcons.fire),
  TabItem(title: 'Detalle', icon: FontAwesomeIcons.magnifyingGlass),
  TabItem(title: 'ETL', icon: FontAwesomeIcons.database),
];

class TabItem {
  final String title;
  final IconData icon;
  const TabItem({required this.title, required this.icon});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabItems.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _moveToEtlTab() {
    _tabController.animateTo(3);
  }

  void _moveToRankingTab() {
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final pageProvider = context.watch<PageProvider>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WikiMetrics',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Monitorea y gestiona tu canalización de datos.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 36),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEDF1F7), width: 1.0), 
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: false,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                labelColor: Theme.of(context).colorScheme.primary,
                                unselectedLabelColor: const Color(0xFF94A3B8), 

                                tabs: tabItems
                                    .map(
                                      (item) => Tab(
                                        icon: Icon(item.icon, size: 18),
                                        text: item.title,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.72,
                              padding: const EdgeInsets.all(24.0),
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  const RankingTopTab(),
                                  const TrendingTab(),
                                  const PageDetailTab(),
                                  EtlAdminTab(onEtlCompleted: _moveToRankingTab),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        if (pageProvider.shouldShowEtlModal)
          Positioned.fill(
            child: EtlForcedModal(
              onEtlStart: _moveToEtlTab,
            ),
          ),
      ],
    );
  }
}
