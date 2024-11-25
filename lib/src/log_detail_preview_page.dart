import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sublime_log/src/sublime_log.dart';

import 'widgets/widgets.dart';

class LogDetailPreviewParams {
  LogDetailPreviewParams({
    required this.log,
  });

  final String log;
}

class LogDetailPreviewPage extends StatefulWidget {
  const LogDetailPreviewPage({
    required this.params,
    super.key,
  });

  final LogDetailPreviewParams params;

  @override
  State<LogDetailPreviewPage> createState() => _LogDetailPreviewPageState();
}

class _LogDetailPreviewPageState extends State<LogDetailPreviewPage> {
  final ScrollController _scrollController = ScrollController();
  late Future<String> _getLogDetail;

  @override
  void initState() {
    _getLogDetail = SublimeLog.getLogDetail(widget.params.log);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Expanded(
                  child: Text(
                    widget.params.log,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.28,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildShareButton(),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: Container(
              color: Color(0xFFF9F9FB),
              child: DraggableScrollbar(
                controller: _scrollController,
                scrollThumbSize: Size(
                  24.0,
                  36.0,
                ),
                scrollBarOffset: Size(
                  20.0,
                  20.0 + MediaQuery.of(context).padding.bottom,
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      top: 12.0,
                      right: 20.0,
                      bottom: 12.0,
                    ),
                    child: FutureBuilder(
                      future: _getLogDetail,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return CircularProgressIndicator();
                        } else {
                          if (snapshot.hasError) {
                            // show error
                            return SizedBox.shrink();
                          }

                          final String logs = snapshot.data ?? '';

                          return Text(logs);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildShareButton() {
    return InkWell(
      onTap: _onPressShare,
      child: _buildButtonContainer(
        child: Row(
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: Icon(
                Icons.share_outlined,
                size: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPressShare() async {
    final logFile = await SublimeLog.getLogFileByName(widget.params.log);
    final date = widget.params.log.split('_')[1].split('.')[0];
    if (logFile != null) {
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles([XFile(logFile.path)],
          text: 'Logs on date $date',
          subject: 'Logs on date $date',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
  }
}
