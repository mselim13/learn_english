/// Türkçe ay adları ile tarih metni (örn. 16 Mart 2026).
String formatMembershipDateTurkish(DateTime d) {
  const months = <String>[
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
