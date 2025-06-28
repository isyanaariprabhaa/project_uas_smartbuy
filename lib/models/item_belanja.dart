class ItemBelanja {
  final int? id;
  final String nama;
  final int harga;
  final String status;
  final String tanggal;
  final String? foto;
  ItemBelanja({
    this.id,
    required this.nama,
    required this.harga,
    required this.status,
    required this.tanggal,
    this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'status': status,
      'tanggal': tanggal,
      'foto': foto,
    };
  }

  factory ItemBelanja.fromMap(Map<String, dynamic> map) {
    return ItemBelanja(
      id: map['id'],
      nama: map['nama'],
      harga: map['harga'],
      status: map['status'],
      tanggal: map['tanggal'],
      foto: map['foto'],
    );
  }
}
