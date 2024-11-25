import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'logs_preview_page.dart';

class SublimeLog {
  /// Show logs of the application. [quotes] show quotes to have fun.
  static Future<T?> showLogsPreview<T extends Object?>(BuildContext context,
      {List<String>? quotes}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        return LogsPreviewPage(
          params: LogsPreviewParams(
            quotes: quotes ?? <String>[],
          ),
        );
      },
    );
  }

  /// Save log message
  /// [message] text to log
  /// [stackTrace] log stacktrace
  /// [tag] top label of logged text, default is `Other`
  static void log(
      {required dynamic message,
      StackTrace? stackTrace,
      String tag = 'Other'}) {
    final String logTime = _format(DateTime.now(), 'MM-dd-yyyy HH:mm:ss');
    final logStr = [
      '',
      '--------------- $tag ($logTime) ---------------',
      message,
      ''
    ];
    if (stackTrace != null) {
      logStr.addAll([
        '',
        '--------------- StackTrace ($logTime) ---------------',
        stackTrace.toString(),
        ''
      ]);
    }
    dev.log(logStr.join('\n'));

    // Save logs to file
    _saveLogsToFile(logStr.join('\n'));
  }

  static Future<void> _saveLogsToFile(String logStr) async {
    final file = await _localLogFile;
    await file.writeAsString(logStr, mode: FileMode.append);
  }

  /// Get all logs file of the application.
  static Future<List<String>> getAllLogFiles() async {
    final path = '${(await getApplicationSupportDirectory()).path}/logs';
    final directory = Directory(path);
    final directoryExists = await directory.exists();
    if (!directoryExists) {
      await directory.create(recursive: true);
    }
    return directory
        .listSync()
        .map((event) => event.path.split('/').last)
        .toList();
  }

  static Future<void> removeAllLogFiles() async {
    final path = '${(await getApplicationSupportDirectory()).path}/logs';
    final directory = Directory(path);
    final directoryExists = await directory.exists();
    if (directoryExists) {
      await directory.delete(recursive: true);
    }
  }

  /// Get log detail as text plain by file [name].
  static Future<String> getLogDetail(String name) async {
    final path = '${(await getApplicationSupportDirectory()).path}/logs';
    final file = File('$path/$name');
    if (await file.exists()) {
      return file.readAsString();
    }
    return '';
  }

  /// Get log detail file by file [name].
  static Future<File?> getLogFileByName(String name) async {
    final path = '${(await getApplicationSupportDirectory()).path}/logs';
    final file = File('$path/$name');
    return !(await file.exists()) ? null : file;
  }

  static Future<File> get _localLogFile async {
    final path = '${(await getApplicationSupportDirectory()).path}/logs';
    print('TUNT _localLogFile $path');
    final file =
        File('$path/logs_${_format(DateTime.now(), 'MM-dd-yyyy')}.txt');
    return !(await file.exists()) ? await file.create(recursive: true) : file;
  }

  static String _format(DateTime dateTime, String formatPattern) {
    // MM-dd-yyyy HH:mm:ss
    final formatedStr = formatPattern
        .replaceAll('MM', dateTime.month.toString().padLeft(2, '0'))
        .replaceAll('dd', dateTime.day.toString().padLeft(2, '0'))
        .replaceAll('yyyy', dateTime.year.toString())
        .replaceAll('HH', dateTime.hour.toString().padLeft(2, '0'))
        .replaceAll('mm', dateTime.minute.toString().padLeft(2, '0'))
        .replaceAll('ss', dateTime.second.toString().padLeft(2, '0'));
    return formatedStr;
  }
}
