import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final faqs = [
      {
        'q': 'Bagaimana cara menambah barang ke wishlist?',
        'a': 'Tekan tombol tambah (+) di halaman wishlist, isi data barang, lalu simpan.'
      },
      {
        'q': 'Bagaimana cara mengganti password?',
        'a': 'Buka menu Profil > Keamanan, lalu isi form ganti password.'
      },
      {
        'q': 'Bagaimana jika lupa password?',
        'a': 'Gunakan fitur "Lupa Password" di halaman login.'
      },
      {
        'q': 'Bagaimana mengaktifkan mode gelap?',
        'a': 'Buka menu Profil > Pengaturan, lalu aktifkan Mode Gelap.'
      },
      {
        'q': 'Bagaimana menghubungi pengembang?',
        'a': 'Email ke support@smartbuy.com atau cek menu Tentang Aplikasi.'
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Bantuan & FAQ'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: faqs.length,
        separatorBuilder: (_, __) => SizedBox(height: 16),
        itemBuilder: (context, i) {
          final faq = faqs[i];
          return Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(14),
            color: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(faq['q']!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(faq['a']!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 