import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DigitalClock extends StatefulWidget {
  const DigitalClock({Key? key}) : super(key: key);

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  var _dateTime = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    _updateTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(DateFormat('MMM d HH:mm').format(_dateTime),style: const TextStyle(color: Colors.white70, fontSize: 14.0),);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
          const Duration(minutes: 1) -
              Duration(
                  seconds: _dateTime.second,
                  milliseconds: _dateTime.millisecond),
          _updateTime);
    });
  }
}