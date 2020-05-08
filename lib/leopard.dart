import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:travel/main_page.dart';

class LeapardImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier,AnimationController>(
      builder: (context, notifier,animation, child) {
        return Positioned(
          left: -.85 * notifier.offset,
          height: MediaQuery.of(context).size.width * 0.66,
          child: Transform.scale(
            alignment: Alignment(0.6,0),
            scale: 1-0.1 *animation.value,
                      child: Opacity(
              opacity: 1 - 1 * animation.value,
              child: child),
          ),
        );
      },
      child: IgnorePointer(child: Image.asset('assets/leopard.png')),
    );
  }
}

class LeopardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        The72Text(),
        SizedBox(
          height: 180,
        ),
        TravelDescLabel(),
        SizedBox(
          height: 30,
        ),
        TravelDesc(),
      ],
    );
  }
}

class TravelDescLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Opacity(
            opacity: math.max(0, 1 - 5 * notifier.page), child: child);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 150),
        child: Text('Travel Description',
            style: TextStyle(
                fontSize: 18,
                fontFamily: 'FiraCode',
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class TravelDesc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Opacity(
            opacity: math.max(0, 1 - 5 * notifier.page), child: child);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34.0),
        child: Text(
            'The leopard is distinguished by its  well-camflaged fur , oppurtunistic hunting behaviour , bored diet ,and strength ',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'FiraCode',
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            )),
      ),
    );
  }
}

class The72Text extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Transform.translate(
          offset: Offset(-4 - 0.5 * notifier.offset, 0),
          child: child,
        );
      },
      child: Container(
        alignment: Alignment.topLeft,
        child: Transform.translate(
          offset: Offset(-34, 148),
          child: RotatedBox(
            quarterTurns: 1,
            child: Text(
              '72',
              style: TextStyle(fontSize: 400, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
