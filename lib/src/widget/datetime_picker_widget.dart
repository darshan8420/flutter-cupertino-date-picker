import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../date_picker.dart';
import '../date_picker_constants.dart';
import '../date_picker_theme.dart';
import '../date_time_formatter.dart';
import '../i18n/date_picker_i18n.dart';
import 'date_picker_title_widget.dart';

/// DateTimePicker widget. Can display date and time picker.
///
/// @author dylan wu
/// @since 2019-05-10
class DateTimePickerWidget extends StatefulWidget {
  DateTimePickerWidget({
    Key? key,
    this.minDateTime,
    this.maxDateTime,
    this.initDateTime,
    this.dateFormat: DATETIME_PICKER_TIME_FORMAT,
    this.locale: DATETIME_PICKER_LOCALE_DEFAULT,
    this.pickerTheme: DateTimePickerTheme.Default,
    this.minuteDivider = 1,
    this.onCancel,
    this.onChange,
    this.onConfirm,
  }) : super(key: key) {
    DateTime minTime = minDateTime ?? DateTime.parse(DATE_PICKER_MIN_DATETIME);
    DateTime maxTime = maxDateTime ?? DateTime.parse(DATE_PICKER_MAX_DATETIME);
    assert(minTime.compareTo(maxTime) < 0);
  }

  final DateTime? minDateTime, maxDateTime, initDateTime;
  final String dateFormat;
  final DateTimePickerLocale locale;
  final DateTimePickerTheme pickerTheme;
  final DateVoidCallback? onCancel;
  final DateValueCallback? onChange, onConfirm;
  final int minuteDivider;

  @override
  State<StatefulWidget> createState() => _DateTimePickerWidgetState(
        this.minDateTime ?? DateTime.parse(DATE_PICKER_MIN_DATETIME),
        this.maxDateTime ?? DateTime.parse(DATE_PICKER_MAX_DATETIME),
        this.initDateTime ?? DateTime.now(),
        this.minuteDivider,
      );
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  late DateTime _minTime, _maxTime;
  late int _currentDay, _currentHour, _currentMinute, _currentSecond;
  late int _minuteDivider;
  late List<int> _dayRange, _hourRange, _minuteRange, _secondRange;
  late FixedExtentScrollController _dayScrollCtrl,
      _hourScrollCtrl,
      _minuteScrollCtrl,
      _secondScrollCtrl;

  late Map<String, FixedExtentScrollController> _scrollCtrlMap;
  late Map<String, List<int>> _valueRangeMap;

  bool _isChangeTimeRange = false;

  final DateTime _baselineDate = DateTime(1900, 1, 1);

  _DateTimePickerWidgetState(
    DateTime? minTime,
    DateTime? maxTime,
    DateTime? initTime,
    int minuteDivider,
  ) {
    // check minTime value
    if (minTime == null) {
      minTime = DateTime.parse(DATE_PICKER_MIN_DATETIME);
    }
    // check maxTime value
    if (maxTime == null) {
      maxTime = DateTime.parse(DATE_PICKER_MAX_DATETIME);
    }
    // check initTime value
    if (initTime == null) {
      initTime = DateTime.now();
    }
    // limit initTime value
    if (initTime.compareTo(minTime) < 0) {
      initTime = minTime;
    }
    if (initTime.compareTo(maxTime) > 0) {
      initTime = maxTime;
    }

    this._minTime = minTime;
    this._maxTime = maxTime;
    this._currentHour = initTime.hour;
    this._currentMinute = initTime.minute;
    this._currentSecond = initTime.second;

    this._minuteDivider = minuteDivider;

    // limit the range of date
    this._dayRange = _calcDayRange();
    int currentDate = initTime.difference(_baselineDate).inDays;
    this._currentDay = min(max(_dayRange.first, currentDate), _dayRange.last);

    // limit the range of hour
    this._hourRange = _calcHourRange();
    this._currentHour =
        min(max(_hourRange.first, _currentHour), _hourRange.last);

    // limit the range of minute
    this._minuteRange = _calcMinuteRange();
    this._currentMinute =
        min(max(_minuteRange.first, _currentMinute), _minuteRange.last);

    // limit the range of second
    this._secondRange = _calcSecondRange();
    this._currentSecond =
        min(max(_secondRange.first, _currentSecond), _secondRange.last);

    // create scroll controller
    _dayScrollCtrl =
        FixedExtentScrollController(initialItem: _currentDay - _dayRange.first);
    _hourScrollCtrl = FixedExtentScrollController(
        initialItem: _currentHour - _hourRange.first);
    _minuteScrollCtrl = FixedExtentScrollController(
        initialItem: (_currentMinute - _minuteRange.first) ~/ _minuteDivider);
    _secondScrollCtrl = FixedExtentScrollController(
        initialItem: _currentSecond - _secondRange.first);

    _scrollCtrlMap = {
      'H': _hourScrollCtrl,
      'm': _minuteScrollCtrl,
      's': _secondScrollCtrl
    };
    _valueRangeMap = {'H': _hourRange, 'm': _minuteRange, 's': _secondRange};
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Material(
          color: Colors.transparent, child: _renderPickerView(context)),
    );
  }

  /// render time picker widgets
  Widget _renderPickerView(BuildContext context) {
    Widget pickerWidget = _renderDatePickerWidget();

    // display the title widget
    if (widget.pickerTheme.title != null || widget.pickerTheme.showTitle) {
      Widget titleWidget = DatePickerTitleWidget(
        pickerTheme: widget.pickerTheme,
        locale: widget.locale,
        onCancel: () => _onPressedCancel(),
        onConfirm: () => _onPressedConfirm(),
      );
      return Column(children: <Widget>[titleWidget, pickerWidget]);
    }
    return pickerWidget;
  }

  /// pressed cancel widget
  void _onPressedCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
    Navigator.pop(context);
  }

  /// pressed confirm widget
  void _onPressedConfirm() {
    if (widget.onConfirm != null) {
      DateTime day = _baselineDate.add(Duration(days: _currentDay));
      DateTime dateTime = DateTime(day.year, day.month, day.day, _currentHour,
          _currentMinute, _currentSecond);
      widget.onConfirm!(dateTime, _calcSelectIndexList());
    }
    Navigator.pop(context);
  }

  /// notify selected datetime changed
  void _onSelectedChange() {
    if (widget.onChange != null) {
      DateTime day = _baselineDate.add(Duration(days: _currentDay));
      DateTime dateTime = DateTime(day.year, day.month, day.day, _currentHour,
          _currentMinute, _currentSecond);
      widget.onChange!(dateTime, _calcSelectIndexList());
    }
  }

  /// find scroll controller by specified format
  FixedExtentScrollController _findScrollCtrl(String format) {
    return _scrollCtrlMap[format] ?? _dayScrollCtrl;
  }

  /// find item value range by specified format
  List<int> _findPickerItemRange(String format) {
    return _valueRangeMap[format] ?? _dayRange;
  }

  /// render the picker widget of year、month and day
  Widget _renderDatePickerWidget() {
    List<Widget> pickers = <Widget>[];
    List<String> formatArr = DateTimeFormatter.splitDateFormat(
        widget.dateFormat,
        mode: DateTimePickerMode.datetime);
    int count = formatArr.length;
    int dayFlex = count > 3 ? count - 1 : count;

    // render day picker column
    String dayFormat = formatArr.removeAt(0);
    Widget dayPickerColumn = _renderDatePickerColumnComponent(
      scrollCtrl: _dayScrollCtrl,
      valueRange: _dayRange,
      format: dayFormat,
      valueChanged: (value) {
        _changeDaySelection(value);
      },
      flex: dayFlex,
      itemBuilder: (BuildContext context, int index) =>
          _renderDayPickerItemComponent(_dayRange.first + index, dayFormat),
    );
    pickers.add(dayPickerColumn);

    // render time picker column
    formatArr.forEach((format) {
      List<int> valueRange = _findPickerItemRange(format);

      Widget pickerColumn = _renderDatePickerColumnComponent(
        scrollCtrl: _findScrollCtrl(format),
        valueRange: valueRange,
        format: format,
        flex: 1,
        minuteDivider: widget.minuteDivider,
        valueChanged: (value) {
          if (format.contains('H')) {
            _changeHourSelection(value);
          } else if (format.contains('m')) {
            _changeMinuteSelection(value);
          } else if (format.contains('s')) {
            _changeSecondSelection(value);
          }
        },
      );
      pickers.add(pickerColumn);
    });
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: pickers);
  }

  Widget _renderDatePickerColumnComponent({
    required FixedExtentScrollController scrollCtrl,
    required List<int> valueRange,
    required String format,
    required ValueChanged<int> valueChanged,
    int minuteDivider = 1,
    int flex = 1,
    IndexedWidgetBuilder? itemBuilder,
  }) {
    IndexedWidgetBuilder builder = itemBuilder != null
        ? itemBuilder
        : (context, index) {
            int value = valueRange.first + index;

            if (format.contains('m')) {
              value = minuteDivider * index;
            }

            return _renderDatePickerItemComponent(value, format);
          };

    Widget columnWidget = Container(
      padding: EdgeInsets.all(8.0),
      width: double.infinity,
      height: widget.pickerTheme.pickerHeight,
      decoration: BoxDecoration(color: widget.pickerTheme.backgroundColor),
      child: CupertinoPicker.builder(
        backgroundColor: widget.pickerTheme.backgroundColor,
        scrollController: scrollCtrl,
        itemExtent: widget.pickerTheme.itemHeight,
        onSelectedItemChanged: valueChanged,
        childCount: format.contains('m')
            ? _calculateMinuteChildCount(valueRange, minuteDivider)
            : valueRange.last - valueRange.first + 1,
        itemBuilder: builder,
      ),
    );
    return Expanded(
      flex: flex,
      child: columnWidget,
    );
  }

  _calculateMinuteChildCount(List<int> valueRange, int divider) {
    if (divider == 0) {
      debugPrint("Cant devide by 0");
      return (valueRange.last - valueRange.first + 1);
    }

    return (valueRange.last - valueRange.first + 1) ~/ divider;
  }

  /// render day picker item
  Widget _renderDayPickerItemComponent(int value, String format) {
    DateTime dateTime = _baselineDate.add(Duration(days: value));
    return Container(
      height: widget.pickerTheme.itemHeight,
      alignment: Alignment.center,
      child: Text(
        DateTimeFormatter.formatDate(dateTime, format, widget.locale),
        style:
            widget.pickerTheme.itemTextStyle ?? DATETIME_PICKER_ITEM_TEXT_STYLE,
      ),
    );
  }

  /// render hour、minute、second picker item
  Widget _renderDatePickerItemComponent(int value, String format) {
    return Container(
      height: widget.pickerTheme.itemHeight,
      alignment: Alignment.center,
      child: Text(
        DateTimeFormatter.formatDateTime(value, format, widget.locale),
        style: widget.pickerTheme.itemTextStyle,
      ),
    );
  }

  /// change the selection of day picker
  void _changeDaySelection(int days) {
    int value = _dayRange.first + days;
    if (_currentDay != value) {
      _currentDay = value;
      _changeTimeRange();
      _onSelectedChange();
    }
  }

  /// change the selection of hour picker
  void _changeHourSelection(int index) {
    int value = _hourRange.first + index;
    if (_currentHour != value) {
      _currentHour = value;
      _changeTimeRange();
      _onSelectedChange();
    }
  }

  /// change the selection of minute picker
  void _changeMinuteSelection(int index) {
    // TODO: copied from time_picker_widget - this looks like it would break date ranges but not taking into account _minuteRange.first
    int value = index * _minuteDivider;
//    int value = _minuteRange.first + index;
    if (_currentMinute != value) {
      _currentMinute = value;
      _changeTimeRange();
      _onSelectedChange();
    }
  }

  /// change the selection of second picker
  void _changeSecondSelection(int index) {
    int value = _secondRange.first + index;
    if (_currentSecond != value) {
      _currentSecond = value;
      _onSelectedChange();
    }
  }

  /// change range of minute and second
  void _changeTimeRange() {
    if (_isChangeTimeRange) {
      return;
    }
    _isChangeTimeRange = true;

    List<int> hourRange = _calcHourRange();
    bool hourRangeChanged = _hourRange.first != hourRange.first ||
        _hourRange.last != hourRange.last;
    if (hourRangeChanged) {
      // selected day changed
      _currentHour = max(min(_currentHour, hourRange.last), hourRange.first);
    }

    List<int> minuteRange = _calcMinuteRange();
    bool minuteRangeChanged = _minuteRange.first != minuteRange.first ||
        _minuteRange.last != minuteRange.last;
    if (minuteRangeChanged) {
      // selected hour changed
      _currentMinute =
          max(min(_currentMinute, minuteRange.last), minuteRange.first);
    }

    List<int> secondRange = _calcSecondRange();
    bool secondRangeChanged = _secondRange.first != secondRange.first ||
        _secondRange.last != secondRange.last;
    if (secondRangeChanged) {
      // second range changed, need limit the value of selected second
      _currentSecond =
          max(min(_currentSecond, secondRange.last), secondRange.first);
    }

    setState(() {
      _hourRange = hourRange;
      _minuteRange = minuteRange;
      _secondRange = secondRange;

      _valueRangeMap['H'] = hourRange;
      _valueRangeMap['m'] = minuteRange;
      _valueRangeMap['s'] = secondRange;
    });

    if (hourRangeChanged) {
      // CupertinoPicker refresh data not working (https://github.com/flutter/flutter/issues/22999)
      int currHour = _currentHour;
      _hourScrollCtrl.jumpToItem(hourRange.last - hourRange.first);
      if (currHour < hourRange.last) {
        _hourScrollCtrl.jumpToItem(currHour - hourRange.first);
      }
    }

    if (minuteRangeChanged) {
      // CupertinoPicker refresh data not working (https://github.com/flutter/flutter/issues/22999)
      int currMinute = _currentMinute;
      _minuteScrollCtrl
          .jumpToItem((minuteRange.last - minuteRange.first) ~/ _minuteDivider);
      if (currMinute < minuteRange.last) {
        _minuteScrollCtrl.jumpToItem(currMinute - minuteRange.first);
      }
    }

    if (secondRangeChanged) {
      // CupertinoPicker refresh data not working (https://github.com/flutter/flutter/issues/22999)
      int currSecond = _currentSecond;
      _secondScrollCtrl.jumpToItem(secondRange.last - secondRange.first);
      if (currSecond < secondRange.last) {
        _secondScrollCtrl.jumpToItem(currSecond - secondRange.first);
      }
    }

    _isChangeTimeRange = false;
  }

  /// calculate selected index list
  List<int> _calcSelectIndexList() {
    int hourIndex = _currentHour - _hourRange.first;
    int minuteIndex = _currentMinute - _minuteRange.first;
    int secondIndex = _currentSecond - _secondRange.first;
    return [hourIndex, minuteIndex, secondIndex];
  }

  /// calculate the range of day
  List<int> _calcDayRange() {
    int minDays = _minTime.difference(_baselineDate).inDays;
    int maxDays = _maxTime.difference(_baselineDate).inDays;
    return [minDays, maxDays];
  }

  /// calculate the range of hour
  List<int> _calcHourRange() {
    int minHour = 0, maxHour = 23;
    if (_currentDay == _dayRange.first) {
      minHour = _minTime.hour;
    }
    if (_currentDay == _dayRange.last) {
      maxHour = _maxTime.hour;
    }
    return [minHour, maxHour];
  }

  /// calculate the range of minute
  List<int> _calcMinuteRange({currHour}) {
    int minMinute = 0, maxMinute = 59;
    if (currHour == null) {
      currHour = _currentHour;
    }

    if (_currentDay == _dayRange.first && currHour == _minTime.hour) {
      // selected minimum day、hour, limit minute range
      minMinute = _minTime.minute;
    }
    if (_currentDay == _dayRange.last && currHour == _maxTime.hour) {
      // selected maximum day、hour, limit minute range
      maxMinute = _maxTime.minute;
    }
    return [minMinute, maxMinute];
  }

  /// calculate the range of second
  List<int> _calcSecondRange({currHour, currMinute}) {
    int minSecond = 0, maxSecond = 59;

    if (currHour == null) {
      currHour = _currentHour;
    }
    if (currMinute == null) {
      currMinute = _currentMinute;
    }

    if (_currentDay == _dayRange.first &&
        currHour == _minTime.hour &&
        currMinute == _minTime.minute) {
      // selected minimum hour and minute, limit second range
      minSecond = _minTime.second;
    }
    if (_currentDay == _dayRange.last &&
        currHour == _maxTime.hour &&
        currMinute == _maxTime.minute) {
      // selected maximum hour and minute, limit second range
      maxSecond = _maxTime.second;
    }
    return [minSecond, maxSecond];
  }
}
