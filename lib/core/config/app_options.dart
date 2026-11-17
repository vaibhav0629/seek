/// Fixed choices used in the register form
class AppOptions {
  static const List<String> cities = [
    'Jakarta',
    'Bogor',
    'Depok',
    'Tangerang',
    'Bekasi',
    'Denpasar',
    'Bandung',
  ];

  static const List<String> scoringSports = ['Padel', 'Basketball'];

  static bool supportsScoring(String sport) =>
      scoringSports.any((s) => s.toLowerCase() == sport.toLowerCase());

  static const List<String> sports = [
    'Padel',
    'Basketball',
    'Running',
    'Pilates',
    'Mahjong',
  ];

  static const List<String> skillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Pro',
  ];
}
