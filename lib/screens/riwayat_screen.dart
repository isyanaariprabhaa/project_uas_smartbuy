import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/item_belanja.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  List<ItemBelanja> _riwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    final allItems = await DatabaseHelper.instance.getAllItems();
    if (mounted) {
      setState(() {
        _riwayat =
            allItems.where((item) => item.status == "Sudah Dibeli").toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadRiwayat();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 12.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Belanja"),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: theme.primaryColor),
              )
              : RefreshIndicator(
                color: theme.primaryColor,
                onRefresh: _refreshData,
                child:
                    _riwayat.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: isSmallScreen ? 48 : 64,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              Text(
                                "Belum ada riwayat pembelian",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 6 : 8),
                              Text(
                                "Produk yang sudah dibeli akan muncul di sini",
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white60 : Colors.black45,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.fromLTRB(padding, padding, padding, 80),
                          itemCount: _riwayat.length,
                          itemBuilder: (context, index) {
                            final item = _riwayat[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: isDark ? Colors.grey[800] : Colors.white,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  // Add detail view functionality
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withOpacity(
                                            0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          color: theme.primaryColor,
                                          size: isSmallScreen ? 24 : 28,
                                        ),
                                      ),
                                      SizedBox(width: isSmallScreen ? 12 : 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.nama,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isSmallScreen ? 14 : 16,
                                                color:
                                                    isDark
                                                        ? Colors.white
                                                        : Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: isSmallScreen ? 3 : 4),
                                            Text(
                                              "Rp ${item.harga}",
                                              style: TextStyle(
                                                color: theme.primaryColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: isSmallScreen ? 13 : 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            item.tanggal,
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 10 : 12,
                                              color:
                                                  isDark
                                                      ? Colors.white60
                                                      : Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: isSmallScreen ? 3 : 4),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color:
                                                isDark
                                                    ? Colors.white60
                                                    : Colors.black54,
                                            size: isSmallScreen ? 16 : 20,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
    );
  }
}
