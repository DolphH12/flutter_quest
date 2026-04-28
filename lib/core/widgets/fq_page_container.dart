import 'package:flutter/material.dart';

import '../responsive/breakpoints.dart';

class FQPageContainer extends StatelessWidget {
  const FQPageContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: FQBreakpoints.contentMaxWidth(context),
          ),
          child: Padding(
            padding: FQBreakpoints.pagePadding(context),
            child: child,
          ),
        ),
      ),
    );
  }
}
