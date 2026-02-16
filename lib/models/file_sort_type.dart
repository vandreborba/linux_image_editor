enum FileSortType { name, date }

extension FileSortTypeExtension on FileSortType {
  String displayName(bool isPortuguese) {
    switch (this) {
      case FileSortType.name:
        return isPortuguese ? 'Nome' : 'Name';
      case FileSortType.date:
        return isPortuguese ? 'Data' : 'Date';
    }
  }
}
