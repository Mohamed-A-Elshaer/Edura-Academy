import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class BusyChildWidget extends StatefulWidget {
  final Widget child;
  final Widget loadingWidget;

  const BusyChildWidget({
    super.key,
    required this.child,
    required this.loadingWidget,
  });

  @override
  State<BusyChildWidget> createState() => _BusyChildWidgetState();
}

class _BusyChildWidgetState extends State<BusyChildWidget> {
  bool loading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 1,
          child: AbsorbPointer(
            absorbing: loading,
            child: widget.child,
          ),
        ),
        if (loading)
          Opacity(
            opacity: 1.0,
            child: widget.loadingWidget,
          ),
      ],
    );
  }
}
