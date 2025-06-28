import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/database_helper.dart';
import '../models/item_belanja.dart';
import 'package:intl/intl.dart';

class StatistikScreen extends StatefulWidget {
  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  int totalDibeli = 0;
  int totalHarga = 0;
  bool isLoading = true;
  List<ItemBelanja> purchasedItems = [];

  @override
  void initState() {
    super.initState();
    loadStatistik();
  }

  Future<void> loadStatistik() async {
    try {
      final data = await DatabaseHelper.instance.getAllItems();
      purchasedItems =
          data.where((item) => item.status == "Sudah Dibeli").toList();

      if (mounted) {
        setState(() {
          totalDibeli = purchasedItems.length;
          totalHarga = purchasedItems.fold(0, (sum, item) => sum + item.harga);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading statistics: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await loadStatistik();
  }

  String formatCurrency(int amount) {
    try {
      return NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(amount);
    } catch (e) {
      return 'Rp $amount';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik Belanja"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryColor,
        child:
            isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: primaryColor),
                      SizedBox(height: 16),
                      Text(
                        "Memuat statistik...",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      Text(
                        "📊 Ringkasan Belanja",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isSmallScreen = constraints.maxWidth < 600;
                          
                          if (isSmallScreen) {
                            // Layout vertikal untuk layar kecil
                            return Column(
                              children: [
                                _buildStatCard(
                                  context,
                                  icon: Icons.shopping_bag_rounded,
                                  title: "Total Barang",
                                  value: "$totalDibeli",
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 16),
                                _buildStatCard(
                                  context,
                                  icon: Icons.attach_money_rounded,
                                  title: "Total Pengeluaran",
                                  value: formatCurrency(totalHarga),
                                  color: Colors.green,
                                ),
                              ],
                            );
                          } else {
                            // Layout horizontal untuk layar besar
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    icon: Icons.shopping_bag_rounded,
                                    title: "Total Barang",
                                    value: "$totalDibeli",
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    icon: Icons.attach_money_rounded,
                                    title: "Total Pengeluaran",
                                    value: formatCurrency(totalHarga),
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 32),

                      // Bar Chart
                      Text(
                        "📈 Tren Pengeluaran",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 250,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: totalHarga > 0 
                          ? BarChartWidget(
                              total: totalHarga,
                              isDark: isDark,
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bar_chart_rounded,
                                    size: 48,
                                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Belum ada data pengeluaran",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ),
                      const SizedBox(height: 32),

                      // Recent Purchases
                      Text(
                        "🛒 Pembelian Terakhir",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildRecentPurchases(context),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecentPurchases(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Sort by date (most recent first) and take top 3
    final sortedItems = List<ItemBelanja>.from(purchasedItems);
    sortedItems.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    
    final recentItems = sortedItems.length > 3
        ? sortedItems.sublist(0, 3)
        : sortedItems;

    if (recentItems.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Belum ada riwayat pembelian",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
      ];
    }

    return [
      Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            ...recentItems.map(
              (item) => ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                ),
                title: Text(
                  item.nama,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  "${formatCurrency(item.harga)} • ${item.tanggal}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

class BarChartWidget extends StatelessWidget {
  final int total;
  final bool isDark;

  const BarChartWidget({required this.total, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Prevent division by zero
    final maxY = total > 0 ? (total * 1.2).toDouble() : 100.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: maxY,
        minY: 0,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: total.toDouble(),
                width: 40,
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Colors.tealAccent : primaryColor,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: isDark ? Colors.white12 : Colors.grey[200],
                ),
              ),
            ],
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    NumberFormat.compactCurrency(
                      locale: 'id',
                      symbol: 'Rp',
                      decimalDigits: 0,
                    ).format(value),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget:
                  (value, meta) => Text(
                    "Total Pengeluaran",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: isDark ? Colors.white10 : Colors.grey[200],
                strokeWidth: 1,
              ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white24 : Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
