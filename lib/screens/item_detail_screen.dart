import 'package:flutter/material.dart';
import '../models/item_belanja.dart';
import '../db/database_helper.dart';
import 'add_item_screen.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // For currency formatting
import '../utils/notification_helper.dart';

class ItemDetailScreen extends StatelessWidget {
  final ItemBelanja item;

  const ItemDetailScreen({required this.item, super.key});

  Future<void> _tandaiSudahDibeli(BuildContext context) async {
    final updated = ItemBelanja(
      id: item.id,
      nama: item.nama,
      harga: item.harga,
      status: 'Sudah Dibeli',
      tanggal: item.tanggal,
      foto: item.foto,
    );
    await DatabaseHelper.instance.updateItem(updated);
    NotificationHelper.showSuccessToast(context, "Barang ditandai sebagai 'Sudah Dibeli'");
    Navigator.pop(context, true);
  }

  Future<void> _editBarang(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddItemScreen(item: item)),
    );
    if (result == true) Navigator.pop(context, true);
  }

  Future<void> _hapusBarang(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text("Hapus Barang"),
          ],
        ),
        content: Text("Yakin ingin menghapus barang ini? Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteItem(item.id!);
      NotificationHelper.showSuccessToast(context, "Barang berhasil dihapus");
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Barang"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded),
            onPressed: () => _editBarang(context),
          ),
          IconButton(
            icon: Icon(Icons.delete_rounded),
            onPressed: () => _hapusBarang(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Status Badge
            if (item.foto != null && item.foto!.isNotEmpty)
              Stack(
                children: [
                  Container(
                    height: isSmallScreen ? 200 : 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(item.foto!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: isSmallScreen ? 50 : 60,
                                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Gambar tidak dapat dimuat",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                                      fontSize: isSmallScreen ? 13 : 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: item.status == 'Sudah Dibeli' 
                          ? Colors.green.withOpacity(0.9)
                          : Colors.orange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.status == 'Sudah Dibeli' 
                              ? Icons.check_circle_rounded
                              : Icons.pending_rounded,
                            size: isSmallScreen ? 14 : 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: isSmallScreen ? 4 : 6),
                          Text(
                            item.status,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: isSmallScreen ? 24 : 28),

            // Product Details Card
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Section
                  _buildDetailSection(
                    context,
                    icon: Icons.shopping_bag_rounded,
                    label: "Nama Barang",
                    value: item.nama,
                    isDark: isDark,
                    isSmallScreen: isSmallScreen,
                  ),
                  Divider(height: 32, thickness: 1),

                  // Price Section
                  _buildDetailSection(
                    context,
                    icon: Icons.attach_money_rounded,
                    label: "Harga",
                    value: NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(item.harga),
                    isDark: isDark,
                    isSmallScreen: isSmallScreen,
                    valueColor: primaryColor,
                  ),
                  Divider(height: 32, thickness: 1),

                  // Date Section
                  _buildDetailSection(
                    context,
                    icon: Icons.calendar_today_rounded,
                    label: "Tanggal Ditambahkan",
                    value: DateFormat('dd MMMM yyyy', 'id_ID').format(
                      DateFormat('dd-MM-yyyy').parse(item.tanggal)
                    ),
                    isDark: isDark,
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 28),

            // Action Buttons
            if (item.status != 'Sudah Dibeli')
              Container(
                width: double.infinity,
                height: isSmallScreen ? 50 : 56,
                child: ElevatedButton.icon(
                  onPressed: () => _tandaiSudahDibeli(context),
                  icon: Icon(Icons.check_circle_rounded, size: isSmallScreen ? 20 : 24),
                  label: Text(
                    "Tandai Sudah Dibeli",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Colors.green.withOpacity(0.3),
                  ),
                ),
              ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Secondary Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: isSmallScreen ? 48 : 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _editBarang(context),
                      icon: Icon(Icons.edit_rounded, size: isSmallScreen ? 18 : 20),
                      label: Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: isSmallScreen ? 48 : 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _hapusBarang(context),
                      icon: Icon(Icons.delete_rounded, size: isSmallScreen ? 18 : 20),
                      label: Text(
                        "Hapus",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required bool isSmallScreen,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 18 : 20,
            color: theme.primaryColor,
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                  fontSize: isSmallScreen ? 16 : 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
