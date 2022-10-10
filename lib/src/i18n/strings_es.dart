part of 'date_picker_i18n.dart';

/// Spanish (ES)
class _StringsEs extends _StringsI18n {
  const _StringsEs();

  @override
  String getCancelText() {
    return "Cancelar";
  }

  @override
  String getDoneText() {
    return "Aceptar";
  }

  @override
  List<String> getMonths() {
    return [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre"
    ];
  }

  @override
  List<String> getWeeksFull() {
    return [
      "Lunes",
      "Martes",
      "Miercoles",
      "Jueves",
      "Viernes",
      "Sabado",
      "Domingo",
    ];
  }

  @override
  List<String> getWeeksShort() {
    return [
      "Lun",
      "Mar",
      "Mie",
      "Jue",
      "Vie",
      "Sab",
      "Dom",
    ];
  }

  @override
  List<String> getMonthsShort() {
    return [
      "Ene",
      "Feb",
      "Mar",
      "Abr",
      "May",
      "Jun",
      "Jul",
      "Ago",
      "Sep",
      "Oct",
      "Nov",
      "Dic",
    ];
  }
}
