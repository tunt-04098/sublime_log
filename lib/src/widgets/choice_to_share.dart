import 'package:flutter/material.dart';

class ChoiceToShare extends StatelessWidget {
  const ChoiceToShare({
    required this.onShareExternal,
    required this.onViewDetails,
    super.key,
  });

  final VoidCallback onShareExternal;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16.0,
        ),
        InkWell(
          onTap: onShareExternal,
          child: _buildButtonContainer(
            child: Text(
              'Share via...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.28,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 8.0),
        InkWell(
          onTap: onViewDetails,
          child: _buildButtonContainer(
            child: Text(
              'View details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.28,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          height: 16.0 + MediaQuery.of(context).padding.bottom,
        ),
      ],
    );
  }

  Widget _buildButtonContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
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
}
