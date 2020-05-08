import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'leopard.dart';
import 'styles.dart';
import 'dart:math' as math;
import 'package:flutter/animation.dart';

class PageOffsetNotifier with ChangeNotifier {
  double _offset = 0;
  double _page = 0;
  PageOffsetNotifier(PageController pageController) {
    pageController.addListener(() {
      _offset = pageController.offset;
      _page = pageController.page;
      notifyListeners();
    });
  }
  double get offset => _offset;
  double get page => _page;
}

class MapAnimationNotifier with ChangeNotifier {
  final AnimationController _animationController;

  MapAnimationNotifier(this._animationController) {
    _animationController.addListener(_onAnimationControllerChanged);
  }

  double get value => _animationController.value;

  void forward() => _animationController.forward();

  void _onAnimationControllerChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationControllerChanged);
    super.dispose();
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  AnimationController _animationController;
  AnimationController _mapAnimationController;
  final PageController _pageController = PageController();
  double get maxHeight => 400.0 + 32.0 + 24;
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _mapAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _mapAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent));
    return ChangeNotifierProvider(
      create: null,
      builder: (_) => PageOffsetNotifier(_pageController),
      child: ListenableProvider.value(
        value: _animationController,
        child: ChangeNotifierProvider(
          create: null,
          builder: (_) => MapAnimationNotifier(_mapAnimationController),
          child: Scaffold(
            body: Stack(
              children: <Widget>[
                MapImage(),
                SafeArea(
                  child: GestureDetector(
                    onVerticalDragUpdate: _handleDragUpdate,
                    onVerticalDragEnd: _handleDragEnd,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        PageView(
                          controller: _pageController,
                          physics: ClampingScrollPhysics(),
                          children: <Widget>[
                            LeopardPage(),
                            VulturePage(),
                          ],
                        ),
                        AppBar(),
                        LeapardImage(),
                        VultureImage(),
                        SharedButton(),
                        PageIndicator(),
                        ArrowButton(),
                        TravelDetailsLabel(),
                        StartCampLabelAndTime(),
                        BaseCampLabelAndTime(),
                        DistanceLabel(),
                        TravelDots(),
                        MapButton(),
                        VerticaltravelDots(),
                        VultureIconLabel(),
                        LeopardIconLabel(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _animationController.value -= details.primaryDelta / maxHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_animationController.isAnimating ||
        _animationController.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / maxHeight;
    if (flingVelocity < 0.0)
      _animationController.fling(velocity: math.max(2.0, -flingVelocity));
    else if (flingVelocity > 0.0)
      _animationController.fling(velocity: math.min(-2.0, -flingVelocity));
    else
      _animationController.fling(
          velocity: _animationController.value < 0.5 ? -2.0 : 2.0);
  }
}

class MapImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MapAnimationNotifier>(
      builder: (context, notifier, child) {
        double scale = 1 + 0.3 * (1 - notifier.value);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(scale, scale)
            ..rotateZ(0.03 * math.pi * (1 - notifier.value)),
          child: Opacity(opacity: notifier.value, child: child),
        );
      },
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset('assets/map.png', fit: BoxFit.fill),
      ),
    );
  }
}

class MapButton extends StatelessWidget {
  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Positioned(
          left: 35 + MediaQuery.of(context).size.width - notifier.offset,
          bottom: 28,
          child: Opacity(
            child: child,
            opacity: math.max(0, 4 * notifier.page - 3),
          ),
        );
      },
      child: FlatButton(
        onPressed: () {
          final notifier = Provider.of<MapAnimationNotifier>(context);
          notifier.value == 0
              ? notifier.forward()
              : notifier._animationController.reverse();
        },
        child: Text('On MAP'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}

class ArrowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationController>(
      builder: (context, animation, child) {
        return Positioned(
            top: 148 + (1 - animation.value) * (400 + 32 - 4),
            right: 24,
            //bottom: 225,
            child: child);
      },
      child: Icon(
        Icons.keyboard_arrow_up,
        color: lighterGrey,
      ),
    );
  }
}

class VultureCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier, AnimationController>(
        builder: (context, notifier, animation, child) {
      double multiplier;
      if (animation.value == 0) {
        multiplier = math.max(0, 4 * notifier.page - 3);
      } else {
        multiplier = math.max(0, 1 - 6 * animation.value);
      }
      //double multiplier = math.max(0, 4 * notifier.page - 3);
      double size = MediaQuery.of(context).size.width * 0.5 * multiplier;
      return Container(
        margin: EdgeInsets.only(bottom: 250),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: lighterGrey,
        ),
        width: size,
        height: size,
      );
    });
  }
}

class SharedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Positioned(
            right: 24 + MediaQuery.of(context).size.width - notifier.offset,
            bottom: 25,
            child: Opacity(
                child: child, opacity: math.max(0, 4 * notifier.page - 3)));
      },
      child: FlatButton(
          onPressed: () {},
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Icon(
            Icons.share,
          ),
        ),
    );
  }
}

class AppBar extends StatefulWidget {
  @override
  _AppBarState createState() => _AppBarState();
}

class _AppBarState extends State<AppBar> with TickerProviderStateMixin {
  Animation animation;
  AnimationController animationController;
  Animation _animation;
  AnimationController _animationController;
  bool mReverse = false;
  bool reverse = false;
  @override
  void initState() {
    super.initState();
    animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));
    animation = Tween<double>(begin: 0, end: 1).animate(animationController);
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
    _animationController.dispose();
  }

  void choiceAction(String choice) {
    print('Working');
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
        child: Row(
          children: <Widget>[
            Text(
              'SY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(
              width: 210,
            ),
            IconButton(
              onPressed: () {
                if (reverse == false) {
                  _animationController.forward();
                } else
                  _animationController.reverse();
                reverse = !reverse;
              },
              icon: AnimatedIcon(
                progress: _animation,
                icon: AnimatedIcons.ellipsis_search,
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () {
                if (mReverse == false) {
                  animationController.forward();
                } else
                  animationController.reverse();
                mReverse = !mReverse;
              },
              icon: AnimatedIcon(
                progress: animation,
                icon: AnimatedIcons.menu_close,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class VultureImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier, AnimationController>(
      builder: (context, notifier, animation, child) {
        return Positioned(
          left:
              1.2 * MediaQuery.of(context).size.width - .85 * notifier._offset,
          child: Transform.scale(
            scale: 1 - 0.3 * animation.value,
            child: Opacity(
              opacity: 1 - 1 * animation.value,
              child: child,
            ),
          ),
        );
      },
      child: IgnorePointer(
          child: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: Image.asset(
          'assets/vulture.png',
          height: MediaQuery.of(context).size.height / 3,
        ),
      )),
    );
  }
}

class PageIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 38.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: notifier.page.round() == 0 ? white : lightGrey,
                  ),
                  width: 6,
                  height: 6,
                ),
                SizedBox(
                  width: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: notifier.page.round() != 0 ? white : lightGrey,
                  ),
                  height: 6,
                  width: 6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VulturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: VultureCircle(),
    );
  }
}

class TravelDetailsLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier, AnimationController>(
      builder: (context, notifier, animation, child) {
        return Positioned(
          top: 148 + (1 - animation.value) * (400 + 32 - 4),
          left: 30 + MediaQuery.of(context).size.width - notifier.offset,
          child: Opacity(
              opacity: math.max(0, 4 * notifier.page - 3), child: child),
        );
      },
      child: Text('Travel Details ',
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'FiraCode',
              fontWeight: FontWeight.bold)),
    );
  }
}

class StartCampLabelAndTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Positioned(
          top: 644,
          right: 275 + MediaQuery.of(context).size.width - notifier.offset,
          child: Opacity(
              opacity: math.max(0, 4 * notifier.page - 3), child: child),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Start Camp',
            style: TextStyle(
                fontSize: 14,
                fontFamily: 'FiraCode',
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            '02:24 PM',
            style: TextStyle(
                fontSize: 14,
                fontFamily: 'FiraCode',
                color: lighterGrey,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class BaseCampLabelAndTime extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier, AnimationController>(
      builder: (context, notifier, animation, child) {
        return Positioned(
          top: 218 + (1 - animation.value) * (400 + 32 - 4),
          left: 265 + MediaQuery.of(context).size.width - notifier.offset,
          child: Opacity(
              opacity: math.max(0, 4 * notifier.page - 3), child: child),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Base Camp',
            style: TextStyle(
                fontSize: 14,
                fontFamily: 'FiraCode',
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            '7:30 AM',
            style: TextStyle(
                fontSize: 14,
                fontFamily: 'FiraCode',
                color: lighterGrey,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class DistanceLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PageOffsetNotifier>(
      builder: (context, notifier, child) {
        return Positioned(
          top: 697,
          bottom: 26 + MediaQuery.of(context).size.width - notifier.offset,
          child: Text(
            '72 Km',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          //   Opacity(
          //     opacity: math.max(0, 4 * notifier.page - 3),
          //   ),
          // Text(
          //   '72 Km',
          //   style: TextStyle(fontSize: 18,
          //   fontWeight: FontWeight.bold),
          // ),
        );
      },
    );
  }
}


class VerticaltravelDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationController>(
      builder: (context, animation, child) {
        if (animation.value < 1 / 6) {
          return Container();
        }
        double starTop = 647;
        double bottom = MediaQuery.of(context).size.height - starTop - 36;
        double top = 318 + (1 - animation.value) * (400 + 32 - 4);
        double endTop = 348;
        double oneThird = (starTop - endTop) / 3;
        return Positioned(
          bottom: bottom,
          top: top - 100,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 2,
                  height: double.infinity,
                  color: white,
                ),
                Positioned(
                  top: top > oneThird + endTop ? 0 : oneThird + endTop - top,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(color: white, width: 3),
                    ),
                    height: 8,
                    width: 8,
                  ),
                ),
                Positioned(
                  top: top > 2 * oneThird + endTop
                      ? 0
                      : 2.5 * oneThird + endTop - top,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(color: white, width: 3),
                    ),
                    height: 8,
                    width: 8,
                  ),
                ),
                Align(
                  alignment: Alignment(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        border: Border.all(color: white)),
                    height: 8,
                    width: 8,
                  ),
                ),
                Align(
                  alignment: Alignment(0, -1),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: white,
                    ),
                    height: 8,
                    width: 8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TravelDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<PageOffsetNotifier, AnimationController>(
      builder: (context, notifier, animation, child) {
        double opacity;
        double spacingFactor;
        if (animation.value == 0) {
          spacingFactor = math.max(0, 4 * notifier.page - 3);
          opacity = spacingFactor;
        } else {
          spacingFactor = math.max(0, 1 - 4 * animation.value);
          opacity = 1;
        }
        return Positioned(
          top: 646,
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 10 * spacingFactor),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lighterGrey,
                    ),
                    height: 4,
                    width: 4,
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10 * spacingFactor),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: lighterGrey),
                    height: 4,
                    width: 4,
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 40 * spacingFactor),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: lighterGrey)),
                    height: 8,
                    width: 8,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 40 * spacingFactor),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: white,
                    ),
                    height: 8,
                    width: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class VultureIconLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationController>(
      builder: (context, animation, child) {
        double starTop = 647;
        double top = 318 + (1 - animation.value) * (400 + 32 - 4);
        double endTop = 318;
        double oneThird = (starTop - endTop) / 3;
        double opacity;
        if (animation.value < 2 / 3)
          opacity = 0;
        else
          opacity = 3 * (animation.value - 2 / 3);
        return Positioned(
          top: endTop + 2 * oneThird - 26 - 26 - 8,
          right: 10 + opacity * 16,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: SmallAnimalIconLabel(
        isVulture: true,
        showLine: true,
      ),
    );
  }
}

class LeopardIconLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AnimationController>(
      builder: (context, animation, child) {
        double starTop = 647;
        double top = 318 + (1 - animation.value) * (400 + 32 - 4);
        double endTop = 318;
        double oneThird = (starTop - endTop) / 3;
        double opacity;
        if (animation.value < 3 / 4)
          opacity = 0;
        else
          opacity = 4 * (animation.value - 3 / 4);
        return Positioned(
          top: endTop - 10,
          left: 10 + opacity * 16,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: SmallAnimalIconLabel(
        isVulture: false,
        showLine: true,
      ),
    );
  }
}

class SmallAnimalIconLabel extends StatelessWidget {
  final bool isVulture;
  final bool showLine;

  const SmallAnimalIconLabel(
      {Key key, @required this.isVulture, @required this.showLine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (showLine && isVulture)
          Container(
            margin: EdgeInsets.only(bottom: 24),
            width: 16,
            height: 1,
            color: white,
          ),
        SizedBox(width: 24),
        Column(
          children: <Widget>[
            Image.asset(
              isVulture ? 'assets/vultures.png' : 'assets/leopards.png',
              width: 38,
              height: 25,
            ),
            SizedBox(height: showLine ? 10 : 0),
            Text(
              isVulture ? 'Vultures' : 'Leopards',
              style: TextStyle(fontSize: showLine ? 14 : 12),
            )
          ],
        ),
        SizedBox(width: 24),
        if (showLine && !isVulture)
          Container(
            margin: EdgeInsets.only(bottom: 8),
            width: 16,
            height: 1,
            color: white,
          ),
      ],
    );
  }
}
