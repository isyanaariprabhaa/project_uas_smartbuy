import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class TipsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tips = const [
    {
      "judul": "Buat Daftar Belanja",
      "deskripsi": "Tulis semua barang yang ingin dibeli agar tidak impulsif.",
      "icon": Icons.list_alt_rounded,
    },
    {
      "judul": "Tentukan Anggaran",
      "deskripsi": "Buat batas pengeluaran sebelum belanja dan patuhi itu.",
      "icon": Icons.account_balance_wallet_rounded,
    },
    {
      "judul": "Bandingkan Harga",
      "deskripsi": "Cek beberapa toko untuk mendapatkan harga terbaik.",
      "icon": Icons.compare_rounded,
    },
    {
      "judul": "Hindari Belanja Saat Lapar",
      "deskripsi": "Kondisi lapar bisa membuat belanja jadi boros.",
      "icon": Icons.fastfood_rounded,
    },
    {
      "judul": "Manfaatkan Promo",
      "deskripsi":
          "Gunakan diskon atau voucher tapi jangan tergoda beli yang tak dibutuhkan.",
      "icon": Icons.local_offer_rounded,
    },
  ];

  const TipsScreen({Key? key}) : super(key: key);

  void _showDetail(BuildContext context, Map<String, dynamic> tip) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(tip["icon"] as IconData, color: theme.primaryColor),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                tip["judul"] as String,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          tip["deskripsi"] as String,
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              final text = '${tip["judul"]}: ${tip["deskripsi"]}';
              Share.share(text);
            },
            icon: Icon(Icons.share_rounded, color: theme.primaryColor),
            label: Text("Bagikan", style: TextStyle(color: theme.primaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup", style: TextStyle(color: theme.primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tips Hemat"),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(padding),
        physics: const BouncingScrollPhysics(),
        itemCount: tips.length,
        separatorBuilder: (context, index) => SizedBox(height: isSmallScreen ? 12 : 16),
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(16),
            color: isDark ? Colors.grey[800] : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showDetail(context, tip),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tip["icon"] as IconData,
                        color: theme.primaryColor,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip["judul"] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: isSmallScreen ? 15 : 16,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Text(
                            tip["deskripsi"] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: isSmallScreen ? 13 : 14,
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Share all tips
          final allTipsText = tips.map((tip) => 
            '${tip["judul"]}: ${tip["deskripsi"]}'
          ).join('\n\n');
          
          final shareText = '💡 Tips Hemat Belanja dari SmartBuy:\n\n$allTipsText\n\nDownload SmartBuy untuk mengelola wishlist dan anggaran belanja Anda!';
          
          Share.share(shareText, subject: 'Tips Hemat Belanja');
        },
        backgroundColor: theme.primaryColor,
        child: Icon(
          Icons.share_rounded, 
          color: Colors.white,
          size: isSmallScreen ? 20 : 24,
        ),
      ),
    );
  }
}
