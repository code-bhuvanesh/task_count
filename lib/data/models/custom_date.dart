import 'package:equatable/equatable.dart';

class CustomDate extends Equatable  {
  final DateTime? date;

  late bool isCurrentDate;

  CustomDate({this.date}) {
    var curDate = DateTime.now();
    var today = DateTime(curDate.year, curDate.month, curDate.day);
    isCurrentDate = date == null ? false : date! == today;
  }

  get day => date?.day ?? 0;

  @override
  List<Object> get props => [date ?? DateTime.now()];
}
