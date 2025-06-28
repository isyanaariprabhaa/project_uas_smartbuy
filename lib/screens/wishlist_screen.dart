import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/item_belanja.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // For currency formatting
import '../utils/notification_helper.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<ItemBelanja> items = [];
  bool isLoading = true;

  Future<void> loadData() async {
    final data = await DatabaseHelper.instance.getAllItems();
    if (mounted) {
      setState(() {
        items = data;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> goToAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddItemScreen()),
    );
    if (result == true) {
      await loadData();
      NotificationHelper.showSuccessToast(context, 'Wishlist berhasil ditambahkan!');
    }
  }

  Widget buildItem(ItemBelanja item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
        vertical: 8, 
        horizontal: isSmallScreen ? 12 : 16
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.grey[800] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
          );
          if (result == true) await loadData();
        },
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          child: Row(
            children: [
              // Product Image
              Container(
                width: isSmallScreen ? 50 : 60,
                height: isSmallScreen ? 50 : 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? Colors.grey[700] : Colors.grey[100],
                ),
                child:
                    item.foto != null && item.foto!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(item.foto!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  size: isSmallScreen ? 20 : 24,
                                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                                ),
                              );
                            },
                          ),
                        )
                        : Center(
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            size: isSmallScreen ? 20 : 24,
                            color: isDark ? Colors.grey[400] : Colors.grey[500],
                          ),
                        ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(
                        locale: 'id',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(item.harga),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.tanggal,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),

              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color:
                      item.status == "Sudah Dibeli"
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.status == "Sudah Dibeli"
                          ? Icons.check_circle_rounded
                          : Icons.pending_rounded,
                      size: isSmallScreen ? 14 : 16,
                      color:
                          item.status == "Sudah Dibeli"
                              ? Colors.green
                              : Colors.orange,
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 6),
                    Text(
                      item.status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            item.status == "Sudah Dibeli"
                                ? Colors.green
                                : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 12.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Belanja"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : items.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: isSmallScreen ? 48 : 64,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    Text(
                      "Belum ada barang di wishlist",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    Text(
                      "Tambahkan barang pertama Anda!",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.fromLTRB(padding, padding, padding, 80),
                itemCount: items.length,
                itemBuilder: (context, index) => buildItem(items[index]),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToAddItem,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        child: Icon(Icons.add, size: isSmallScreen ? 20 : 24),
      ),
    );
  }
}
