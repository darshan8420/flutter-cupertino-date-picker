part of 'date_picker_i18n.dart';

/// Serbia (sr) Cyrillic
class _StringsSrCyrillic extends _StringsI18n {
  const _StringsSrCyrillic();

  @override
  String getCancelText() {
    return 'Откажи';
  }

  @override
  String getDoneText() {
    return 'Изабери';
  }

  @override
  List<String> getMonths() {
    return [
      "Јануар",
      "Фебруар",
      "Март",
      "Април",
      "Мај",
      "Јун",
      "Јул",
      "Август",
      "Септембар",
      "Октобар",
      "Новембар",
      "Децембар"
    ];
  }

  @override
  List<String> getMonthsShort() {
    return [
      "Јан",
      "Феб",
      "Мар",
      "Апр",
      "Мај",
      "Јун",
      "Јул",
      "Авг",
      "Сеп",
      "Окт",
      "Нов",
      "Дец"
    ];
  }

  @override
  List<String> getWeeksFull() {
    return [
      "Понедељак",
      "Уторак",
      "Среда",
      "Четвртак",
      "Петак",
      "Субота",
      "Недеља",
    ];
  }

  @override
  List<String> getWeeksShort() {
    return [
      "Пон",
      "Уто",
      "Сре",
      "Чет",
      "Пет",
      "Суб",
      "Нед",
    ];
  }
}
