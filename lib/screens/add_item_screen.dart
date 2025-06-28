import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/item_belanja.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../utils/notification_helper.dart';

class AddItemScreen extends StatefulWidget {
  final ItemBelanja? item;

  const AddItemScreen({this.item, Key? key}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      namaController.text = widget.item!.nama;
      hargaController.text = widget.item!.harga.toString();
      if (widget.item!.foto != null) {
        _image = File(widget.item!.foto!);
      }
    }
  }

  Future<void> _pickImage() async {
    // Tampilkan dialog pilihan sumber gambar
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: const Text('Kamera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.teal),
                title: const Text('Galeri'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return; // User membatalkan pilihan

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _isLoading = true);
      try {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = p.basename(picked.path);
        final savedImage = await File(
          picked.path,
        ).copy('${directory.path}/$fileName');
        setState(() => _image = savedImage);
      } catch (e) {
        NotificationHelper.showErrorToast(context, 'Gagal menyimpan gambar: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _simpanItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final nama = namaController.text.trim();
    final harga = int.tryParse(hargaController.text.trim()) ?? 0;
    final tanggal = DateFormat('dd-MM-yyyy').format(DateTime.now());

    try {
      if (widget.item == null) {
        // INSERT
        await DatabaseHelper.instance.insertItem(
          ItemBelanja(
            nama: nama,
            harga: harga,
            status: "Belum Dibeli",
            tanggal: tanggal,
            foto: _image?.path,
          ),
        );
      } else {
        // UPDATE
        await DatabaseHelper.instance.updateItem(
          ItemBelanja(
            id: widget.item!.id,
            nama: nama,
            harga: harga,
            status: widget.item!.status,
            tanggal: widget.item!.tanggal,
            foto: _image?.path ?? widget.item!.foto,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      NotificationHelper.showErrorToast(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.item != null;
    final primaryColor = theme.primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Barang" : "Tambah Barang"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Barang
              Text(
                "Nama Barang",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: namaController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama barang harus diisi';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Contoh: Sepatu Converse",
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 12 : 14,
                  ),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),

              // Harga Barang
              Text(
                "Harga Barang",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (int.parse(value) <= 0) {
                    return 'Harga harus lebih dari 0';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Contoh: 150000",
                  prefixText: "Rp ",
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 12 : 14,
                  ),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),

              // Foto Barang
              Text(
                "Foto Barang (Opsional)",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: isSmallScreen ? 150 : 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child:
                      _image == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                size: isSmallScreen ? 32 : 40,
                                color:
                                    isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[400],
                              ),
                              SizedBox(height: isSmallScreen ? 6 : 8),
                              Text(
                                "Ketuk untuk mengambil foto",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[500],
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Kamera atau Galeri",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[400],
                                  fontSize: isSmallScreen ? 10 : 12,
                                ),
                              ),
                            ],
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                ),
              ),
              const SizedBox(height: 12),
              if (_image != null)
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.edit_rounded, color: primaryColor),
                  label: Text(
                    "Ganti Foto",
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              SizedBox(height: isSmallScreen ? 24 : 32),

              // Simpan Button
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 45 : 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isEdit
                                    ? Icons.edit_rounded
                                    : Icons.save_rounded,
                                size: isSmallScreen ? 18 : 20,
                              ),
                              SizedBox(width: isSmallScreen ? 6 : 8),
                              Text(
                                isEdit ? "SIMPAN PERUBAHAN" : "TAMBAH BARANG",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


