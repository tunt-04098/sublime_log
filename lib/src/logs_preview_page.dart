import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'log_detail_preview_page.dart';
import 'sublime_log.dart';
import 'widgets/widgets.dart';

class LogsPreviewParams {
  LogsPreviewParams({
    required this.quotes,
  });

  final List<String> quotes;
}

class LogsPreviewPage extends StatefulWidget {
  const LogsPreviewPage({
    super.key,
    this.params,
  });

  final LogsPreviewParams? params;

  @override
  State<LogsPreviewPage> createState() => _LogsPreviewPageState();
}

class _LogsPreviewPageState extends State<LogsPreviewPage> {
  late Future<List<String>> _getAllLogs;

  @override
  void initState() {
    _getAllLogs = SublimeLog.getAllLogFiles();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hints = widget.params?.quotes ?? [];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBackButton(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildRemoveButton(),
                      SizedBox(width: 8.0),
                      _buildRefreshButton(),
                    ],
                  )
                ],
              ),
            ),
            _buildHints(hints),
            SizedBox(height: 16.0),
            Expanded(
              child: Container(
                color: Color(0xFFF9F9FB),
                child: FutureBuilder(
                  future: _getAllLogs,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return CircularProgressIndicator();
                    } else {
                      if (snapshot.hasError) {
                        // show error
                        return Column(
                          children: [],
                        );
                      }

                      final List<String> logs = snapshot.data ?? [];
                      logs.sort((a, b) => b.compareTo(a));

                      return ListView.separated(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 16.0,
                          top: 16.0,
                          right: 16.0,
                          bottom: 16.0 + MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return InkWell(
                            onTap: () => _onPressLog(log),
                            child: ItemLog(
                              label: log,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 12.0,
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonContainer({required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xFFF2F2F4),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: child,
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: _buildButtonContainer(
        child: Row(
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                size: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return InkWell(
      onTap: _onPressRefresh,
      child: _buildButtonContainer(
        child: Row(
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: Icon(
                Icons.refresh_outlined,
                size: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return InkWell(
      onTap: _onPressRemove,
      child: _buildButtonContainer(
        child: Row(
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: Icon(
                Icons.delete_outline,
                size: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHints(List<String> hints) {
    return hints.isNotEmpty
        ? Column(
            children: [
              SizedBox(height: 15.0),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  hints[Random().nextInt(hints.length)],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.red,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.28,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        : SizedBox.shrink();
  }

  void _onPressRemove() async {
    await SublimeLog.removeAllLogFiles();
    setState(() {
      _getAllLogs = SublimeLog.getAllLogFiles();
    });
  }

  void _onPressRefresh() async {
    setState(() {
      _getAllLogs = SublimeLog.getAllLogFiles();
    });
  }

  void _onPressLog(String log) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => ChoiceToShare(
        onShareExternal: () {
          Navigator.of(context).pop();
          _onShareVia(log);
        },
        onViewDetails: () {
          Navigator.of(context).pop();
          _onViewDetails(log);
        },
      ),
    );
  }

  void _onShareVia(String log) async {
    final logFile = await SublimeLog.getLogFileByName(log);
    final date = log.split('_')[1].split('.')[0];
    if (logFile != null) {
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles([XFile(logFile.path)],
          text: 'Logs on date $date',
          subject: 'Logs on date $date',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
  }

  void _onViewDetails(String log) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        return LogDetailPreviewPage(
          params: LogDetailPreviewParams(
            log: log,
          ),
        );
      },
    );
  }
}
