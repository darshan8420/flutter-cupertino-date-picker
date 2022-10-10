part of 'date_picker_i18n.dart';

/// Croatian (HR)
class _StringsHr extends _StringsI18n {
  const _StringsHr();

  @override
  String getCancelText() {
    return 'Otkaži';
  }

  @override
  String getDoneText() {
    return 'Završi';
  }

  @override
  List<String> getMonths() {
    return [
      "Siječanj",
      "Veljača",
      "Ožujak",
      "Travanj",
      "Svibanj",
      "Lipanj",
      "Srpanj",
      "Kolovoz",
      "Rujan",
      "Listopad",
      "Studeni",
      "Prosinac",
    ];
  }

  @override
  List<String> getMonthsShort() {
    return [
      "Sij",
      "Velj",
      "Ožu",
      "Tra",
      "Svi",
      "Lip",
      "Srp",
      "Kol",
      "Ruj",
      "Lis",
      "Stu",
      "Pro",
    ];
  }

  @override
  List<String> getWeeksFull() {
    return [
      "Ponedjeljak",
      "Utorak",
      "Srijeda",
      "Četvrtak",
      "Petak",
      "Subota",
      "Nedjelja",
    ];
  }

  @override
  List<String> getWeeksShort() {
    return [
      "Pon",
      "Uto",
      "Sri",
      "Čet",
      "Pet",
      "Sub",
      "Ned",
    ];
  }
}
