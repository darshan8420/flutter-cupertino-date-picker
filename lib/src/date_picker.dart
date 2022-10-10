import 'package:flutter/material.dart';

import 'date_picker_constants.dart';
import 'date_picker_theme.dart';
import 'date_time_formatter.dart';
import 'i18n/date_picker_i18n.dart';
import 'widget/date_picker_widget.dart';
import 'widget/datetime_picker_widget.dart';
import 'widget/time_picker_widget.dart';

enum DateTimePickerMode {
  /// Display DatePicker
  date,

  /// Display TimePicker
  time,

  /// Display DateTimePicker
  datetime,
}

///
/// author: Dylan Wu
/// since: 2018/06/21
class DatePicker {
  /// Display date picker in bottom sheet.
  ///
  /// context: [BuildContext]
  /// minDateTime: [DateTime] minimum date time
  /// maxDateTime: [DateTime] maximum date time
  /// initialDateTime: [DateTime] initial date time for selected
  /// dateFormat: [String] date format pattern
  /// locale: [DateTimePickerLocale] internationalization
  /// pickerMode: [DateTimePickerMode] display mode: date(DatePicker)、time(TimePicker)、datetime(DateTimePicker)
  /// pickerTheme: [DateTimePickerTheme] the theme of date time picker
  /// onCancel: [DateVoidCallback] pressed title cancel widget event
  /// onClose: [DateVoidCallback] date picker closed event
  /// onChange: [DateValueCallback] selected date time changed event
  /// onConfirm: [DateValueCallback] pressed title confirm widget event
  static void showDatePicker(
    BuildContext context, {
    DateTime? minDateTime,
    DateTime? maxDateTime,
    DateTime? initialDateTime,
    required String dateFormat,
    DateTimePickerLocale locale: DATETIME_PICKER_LOCALE_DEFAULT,
    DateTimePickerMode pickerMode: DateTimePickerMode.date,
    DateTimePickerTheme pickerTheme: DateTimePickerTheme.Default,
    DateVoidCallback? onCancel,
    DateVoidCallback? onClose,
    DateValueCallback? onChange,
    DateValueCallback? onConfirm,
    int minuteDivider = 1,
    bool onMonthChangeStartWithFirstDate = false,
  }) {
    // Set value of date format
    if (dateFormat.length > 0) {
      // Check whether date format is legal or not
      if (DateTimeFormatter.isDayFormat(dateFormat)) {
        if (pickerMode == DateTimePickerMode.time) {
          pickerMode = DateTimeFormatter.isTimeFormat(dateFormat)
              ? DateTimePickerMode.datetime
              : DateTimePickerMode.date;
        }
      } else {
        if (pickerMode == DateTimePickerMode.date ||
            pickerMode == DateTimePickerMode.datetime) {
          pickerMode = DateTimePickerMode.time;
        }
      }
    } else {
      dateFormat = DateTimeFormatter.generateDateFormat(pickerMode);
    }

    Navigator.push(
      context,
      new _DatePickerRoute(
        onMonthChangeStartWithFirstDate: onMonthChangeStartWithFirstDate,
        minDateTime: minDateTime ?? DateTime.parse(DATE_PICKER_MIN_DATETIME),
        maxDateTime: maxDateTime ?? DateTime.parse(DATE_PICKER_MAX_DATETIME),
        initialDateTime: initialDateTime ?? DateTime.now(),
        dateFormat: dateFormat,
        locale: locale,
        pickerMode: pickerMode,
        pickerTheme: pickerTheme,
        onCancel: onCancel,
        onChange: onChange,
        onConfirm: onConfirm,
        theme: Theme.of(context),
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        minuteDivider: minuteDivider,
      ),
    ).whenComplete(onClose ?? () {});
  }
}

class _DatePickerRoute<T> extends PopupRoute<T> {
  _DatePickerRoute({
    required this.onMonthChangeStartWithFirstDate,
    required this.minDateTime,
    required this.maxDateTime,
    required this.initialDateTime,
    required this.dateFormat,
    required this.locale,
    required this.pickerMode,
    required this.pickerTheme,
    this.onCancel,
    this.onChange,
    this.onConfirm,
    required this.theme,
    required this.barrierLabel,
    required this.minuteDivider,
    RouteSettings? settings,
  }) : super(settings: settings);

  final DateTime minDateTime, maxDateTime, initialDateTime;
  final String dateFormat;
  final DateTimePickerLocale locale;
  final DateTimePickerMode pickerMode;
  final DateTimePickerTheme pickerTheme;
  final VoidCallback? onCancel;
  final DateValueCallback? onChange;
  final DateValueCallback? onConfirm;
  final int minuteDivider;
  final bool onMonthChangeStartWithFirstDate;

  final ThemeData theme;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);

    return BottomSheet.createAnimationController(navigator!.overlay!);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    double height = pickerTheme.pickerHeight;
    if (pickerTheme.title != null || pickerTheme.showTitle) {
      height += pickerTheme.titleHeight;
    }

    Widget bottomSheet = new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _DatePickerComponent(route: this, pickerHeight: height),
    );

    bottomSheet = new Theme(data: theme, child: bottomSheet);
    return bottomSheet;
  }
}

class _DatePickerComponent extends StatelessWidget {
  final _DatePickerRoute route;
  final double _pickerHeight;

  _DatePickerComponent({required this.route, required pickerHeight})
      : this._pickerHeight = pickerHeight;

  @override
  Widget build(BuildContext context) {
    Widget pickerWidget;
    switch (route.pickerMode) {
      case DateTimePickerMode.date:
        pickerWidget = DatePickerWidget(
          onMonthChangeStartWithFirstDate:
              route.onMonthChangeStartWithFirstDate,
          minDateTime: route.minDateTime,
          maxDateTime: route.maxDateTime,
          initialDateTime: route.initialDateTime,
          dateFormat: route.dateFormat,
          locale: route.locale,
          pickerTheme: route.pickerTheme,
          onCancel: route.onCancel,
          onChange: route.onChange,
          onConfirm: route.onConfirm,
        );
        break;
      case DateTimePickerMode.time:
        pickerWidget = TimePickerWidget(
          minDateTime: route.minDateTime,
          maxDateTime: route.maxDateTime,
          initDateTime: route.initialDateTime,
          dateFormat: route.dateFormat,
          locale: route.locale,
          pickerTheme: route.pickerTheme,
          onCancel: route.onCancel,
          onChange: route.onChange,
          onConfirm: route.onConfirm,
          minuteDivider: route.minuteDivider,
        );
        break;
      case DateTimePickerMode.datetime:
        pickerWidget = DateTimePickerWidget(
          minDateTime: route.minDateTime,
          maxDateTime: route.maxDateTime,
          initDateTime: route.initialDateTime,
          dateFormat: route.dateFormat,
          locale: route.locale,
          pickerTheme: route.pickerTheme,
          onCancel: route.onCancel ?? () {},
          onChange: route.onChange ?? (dateTime, List<int> index) {},
          onConfirm: route.onConfirm ?? (dateTime, List<int> index) {},
          minuteDivider: route.minuteDivider,
        );
        break;
    }
    return GestureDetector(
      child: AnimatedBuilder(
        animation: route.animation ?? kAlwaysDismissedAnimation,
        builder: (BuildContext context, Widget? child) {
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPickerLayout(
                route.animation?.value ?? 0.0,
                contentHeight: _pickerHeight,
              ),
            ),
          );
        },
        child: pickerWidget,
      ),
    );
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(this.progress, {required this.contentHeight});

  final double progress;
  final double contentHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return new BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: contentHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return new Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
