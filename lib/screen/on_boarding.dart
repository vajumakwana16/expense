import '../utils/webservice.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> with TickerProviderStateMixin {
  PageController? _controller;
  int currentPage = 0;
  bool lastPage = false;
  AnimationController? animationController;
  Animation<double>? _scaleAnimation;
  late final AnimationController _acontroller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: currentPage,
    );
    _acontroller = AnimationController(vsync: this);
    animationController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _scaleAnimation = Tween(begin: 0.6, end: 1.0).animate(animationController!);
  }

  @override
  void dispose() {
    _controller!.dispose();
    _acontroller.dispose();
    animationController!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              Colors.cyan.shade100,
              Colors.cyan,
            ],
            tileMode: TileMode.repeated,
            begin: Alignment.topRight,
            stops: const [0.0, 1.0],
            end: Alignment.center),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PageView.builder(
              itemCount: pageList.length,
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                  if (currentPage == pageList.length - 1) {
                    lastPage = true;
                    animationController!.forward();
                  } else {
                    lastPage = false;
                    animationController!.reset();
                  }
                });
              },
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _controller!,
                  builder: (context, child) {
                    var page = pageList[index];
                    var delta;
                    var y = 1.0;

                    if (_controller!.position.haveDimensions) {
                      delta = (_controller!.page)! - index;
                      y = 1.0 - delta.abs().clamp(0.0, 1.0)!;
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          height: 400,
                          child: Center(
                            child: Lottie.asset(page.imageUrl,
                                controller: _acontroller,
                                onLoaded: (composition) {
                              _acontroller
                                ..duration = composition.duration
                                ..forward();

                              _acontroller.repeat();
                            }),
                          ),
                        ),
                        // Container(
                        //   margin: const EdgeInsets.only(left: 12.0),
                        //   height: 100.0,
                        //   child: Stack(
                        //     children: const <Widget>[
                        //       Opacity(opacity: .39, child: Text("hello")),
                        //       Padding(
                        //           padding:
                        //               EdgeInsets.only(top: 18.0, left: 22.0),
                        //           child: Text("hello")),
                        //     ],
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 34.0, top: 12.0, right: 8),
                          child: Transform(
                            transform:
                                Matrix4.translationValues(0, 50.0 * (1 - y), 0),
                            child: Center(
                              child: Text(
                                page.body,
                                style: const TextStyle(
                                    fontSize: 25.0, color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
            Positioned(
              left: 30.0,
              bottom: 55.0,
              child: SizedBox(
                  width: 160.0,
                  child: PageIndicator(currentPage, pageList.length)),
            ),
            Positioned(
              right: 30.0,
              bottom: 60.0,
              child: ScaleTransition(
                scale: _scaleAnimation!,
                child: lastPage
                    ? IconButton(
                        icon: const Icon(
                          Icons.arrow_circle_right_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                        onPressed: () async {
                          await Webservice.pref!.setBool('is_first', true);
                          print("object");
                          print(Webservice.pref?.getBool('is_first'));
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      )
                    : Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

var pageList = [
  PageModel(
      imageUrl: "assets/raw/onboarding1.json",
      title: "Expenses",
      body: "List out yuor Expenses",
      titleGradient: gradients[0]),
  PageModel(
      imageUrl: "assets/raw/onboarding2.json",
      title: "Income",
      body: "Analyz your income and expenses.",
      titleGradient: gradients[2]),
  PageModel(
      imageUrl: "assets/raw/no_transaction.json",
      title: "Getting Started",
      body: "Getting Started",
      titleGradient: gradients[3]),
];

List<List<Color>> gradients = [
  [const Color(0xFF00E676), const Color(0xFF736EFE)],
  [const Color(0xFF9708CC), const Color(0xFF43CBFF)],
  [const Color(0xFFE2859F), const Color(0xFFFCCF31)],
  [const Color(0xFF43CBFF), const Color(0xFF736EFE)],
];

class PageModel {
  var imageUrl;
  var title;
  var body;
  List<Color>? titleGradient = [];
  PageModel({this.imageUrl, this.title, this.body, this.titleGradient});
}

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int pageCount;
  const PageIndicator(this.currentIndex, this.pageCount, {Key? key})
      : super(key: key);

  _indicator(bool isActive) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          height: 4.0,
          decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.blueGrey,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0.0, 2.0),
                    blurRadius: 2.0)
              ]),
        ),
      ),
    );
  }

  _buildPageIndicators() {
    List<Widget> indicatorList = [];
    for (int i = 0; i < pageCount; i++) {
      indicatorList
          .add(i == currentIndex ? _indicator(true) : _indicator(false));
    }
    return indicatorList;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _buildPageIndicators(),
    );
  }
}
