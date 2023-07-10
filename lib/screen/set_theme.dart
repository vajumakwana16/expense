import 'package:flutter/material.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(const Settheme());
}

class Settheme extends StatelessWidget {
  const Settheme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: OnBoarding(),
        ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello, World!', style: Theme.of(context).textTheme.bodyMedium);
  }
}

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => new _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> with TickerProviderStateMixin {
  PageController? _controller;
  int currentPage = 0;
  bool lastPage = false;
  AnimationController? animationController;
  // Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: currentPage,
    );
    animationController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    // _scaleAnimation = Tween(begin: 0.6, end: 1.0).animate(animationController!);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradients[currentPage],
            tileMode: TileMode.repeated,
            begin: Alignment.topRight,
            stops: const [0.0, 1.0],
            end: Alignment.bottomCenter),
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
                  print(lastPage);
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
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 34.0, top: 12.0, right: 8),
                          child: Transform(
                            transform:
                                Matrix4.translationValues(0, 50.0 * (1 - y), 0),
                            child: GestureDetector(
                              // onTap: () => setTheme(color),
                              // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => onBoarding())),
                              child: Center(
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: page.titleGradient![0],
                                  ),
                                ),
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
              child: Center(
                child: SizedBox(
                    width: 160.0,
                    child: PageIndicator(currentPage, pageList.length)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

var pageList = [
  PageModel(titleGradient: gradients[0]),
  PageModel(titleGradient: gradients[1]),
  PageModel(titleGradient: gradients[2]),
  PageModel(titleGradient: gradients[3]),
];

List<List<Color>> gradients = [
  [const Color(0xFF00E676), const Color(0xFF736EFE)],
  [const Color(0xFF9708CC), const Color(0xFF43CBFF)],
  [const Color(0xFFE2859F), const Color(0xFFFCCF31)],
  [const Color(0xFF43CBFF), const Color(0xFF736EFE)],
];

class PageModel {
  List<Color>? titleGradient = [];
  PageModel({this.titleGradient});
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
    return new Row(
      children: _buildPageIndicators(),
    );
  }
}
