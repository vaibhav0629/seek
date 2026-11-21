/// Olahraga yang punya fitur scoring. Ubah di sini saja kalau berubah.
const List<String> kScoringSports = ['basketball', 'basket', 'padel'];

bool isScoringSupported(String sport) =>
    kScoringSports.contains(sport.trim().toLowerCase());

bool isPadel(String sport) => sport.trim().toLowerCase() == 'padel';
