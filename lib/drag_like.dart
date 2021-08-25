import 'package:flutter/material.dart';

class DragLike extends StatefulWidget {
  final Widget child;
  final Widget secondChild;
  final double screenWidth;
  final double outValue;
  final double dragSpeed;
  final ValueChanged<String?> onOutComplete;
  final VoidCallback onScaleComplete;
  final ValueChanged<Map> onChangeDragDistance;
  final VoidCallback onPointerUp;
  DragLike(
      {Key ? key,
      required this.child,
      required this.secondChild,
      required this.screenWidth,
      required this.outValue,
      required this.dragSpeed,
      required this.onOutComplete,
      required this.onScaleComplete,
      required this.onChangeDragDistance,
      required this.onPointerUp})
      : assert(outValue <= 1 && outValue > 0),
        assert(dragSpeed > 0),
        super(key: key);

  @override
  _DragLikeState createState() => _DragLikeState();
}

class _DragLikeState extends State<DragLike> with TickerProviderStateMixin {
  // 滑动不到指定位置返回时的动画
  Animation ? animation;
  // 第二个页面动画到前面
  Animation ? scaleAnimation;
  // 按下时的X坐标，以此判断是左滑还是右滑
  double onPressDx = 0;
  // 拖拽时，上一瞬间x轴的位置
  double lastPositionX = 0;
  // 屏幕宽度
  double get screenWidth => widget.screenWidth;
  // 旋转角度
  // double angle = 0;
  final ValueNotifier<double> angle = ValueNotifier(0);
  // 旋转时，x轴的偏移量
  double offsetX = 0;
  // 拖拽时，两个瞬间之间，x轴的差值
  double distanceBetweenTwo = 0;
  // 拖拽发生的时间
  DateTime dragTime = DateTime(0);
  // 第二层的缩放值，0-0.1，因为已设置初始值为0.9
  // double secondScale = 0;
  final ValueNotifier<double> secondScale = ValueNotifier(0);
  // 拖拽距离比0.0-1
  double dragDistance = 0;
  // 滑动流畅值，默认3.8，越小越快
  double dragGvalue = 5;
  // 第二层缩放速度，默认4，越小越快
  double secondScaleSd = 2.3;

  @override
  void initState() {
    super.initState();
  }

  // 更新偏移和缩放量
  void updatePosition(positionX) {
    // print("positionX = " + positionX.toString());
    // print("lastPositionX = " + lastPositionX.toString());
    double offset = positionX - onPressDx;
    // print("offset = " + offset.toString());

    dragTime = DateTime.now();

    distanceBetweenTwo = positionX - lastPositionX;
    // print("distanceBetweenTwo = " + distanceBetweenTwo.toString());
    lastPositionX = positionX;

    double offsetAbs = offset.abs();
    // print("offsetAbs = " + offsetAbs.toString());
    double angleTemp =
        double.parse((offset / screenWidth / dragGvalue).toStringAsFixed(3));
    if (angle.value != angleTemp) {
      angle.value = angleTemp;
      secondScale.value = (offsetAbs / screenWidth / dragGvalue) / secondScaleSd;
      if (secondScale.value >= 0.1) secondScale.value = 0.1;
      dragDistance = offsetAbs / screenWidth;
      // print("dragDistance = " + dragDistance.toString());

      if (offset < 0) {
        offsetX = -80;
      } else {
        offsetX = 80;
      }

      double distance = offset / screenWidth;
      double distanceProgress = distance / widget.outValue;
      widget.onChangeDragDistance({
        'distance': distance,
        'distanceProgress': distanceProgress.abs(),
      });
      // setState(() {});
    }
  }

  // 上层以及第二层返回动画执行
  runBackAnimate() {
    AnimationController controller;
    controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    this.animation = Tween<double>(begin: angle.value, end: 0).animate(controller)
      ..addListener(() {
        angle.value = this.animation!.value;
        secondScale.value = angle.value.abs() / secondScaleSd;
        if (secondScale.value <= 0) secondScale.value = 0;

        dragDistance = 0;
        if (controller.isCompleted) {
          controller.dispose();
        }
        // setState(() {});
      });
    controller.forward(from: 0);
  }

  void runOutAnimate(int type) {
    AnimationController controller;
    controller = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    // direction: 判断卡片飞出方向的依据
    double direction = distanceBetweenTwo;
    if (type == 1) direction = angle.value;
    this.animation =
        Tween<double>(begin: angle.value, end: direction > 0 ? 0.5 : -0.5)
            .animate(controller)
              ..addListener(() {
                angle.value = this.animation!.value;

                dragDistance = 0;
                if (controller.isCompleted) {
                  controller.dispose();
                }
                // setState(() {});
              });
    controller.forward(from: 0);
  }

  void runInScaleAnimate() async {
    AnimationController controller;
    controller = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    this.scaleAnimation =
        Tween<double>(begin: secondScale.value, end: 0.1).animate(controller)
          ..addListener(() async {
            secondScale.value = this.scaleAnimation!.value;
            if (controller.isCompleted) {
              widget.onScaleComplete();
              controller.dispose();
              // 缩放完成以后，将上一层的widget还原到起始位置，不要动画，业务方需要将上层widget的数据替换
              angle.value = 0;
            }
            // setState(() {});
          });
    controller.forward(from: 0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: secondScale,
              builder: (BuildContext context,double value,Widget ? child){
                return Transform.scale(
                  scale: 0.9 + secondScale.value,
                  child: child,
                );
              },
              child: widget.secondChild,
            ),
            GestureDetector(
              onPanDown: (DragDownDetails value) {
                lastPositionX = onPressDx = value.globalPosition.dx;
              },
              onHorizontalDragUpdate: (DragUpdateDetails value){
                updatePosition(value.globalPosition.dx);
              },
              onHorizontalDragEnd: (DragEndDetails details){
                // 滑动速度
                var dragSpeed = details.velocity.pixelsPerSecond.dx.abs();
                if (dragDistance > widget.outValue || dragSpeed >= widget.dragSpeed) {
                    widget.onOutComplete(offsetX > 0 ? 'right' : 'left');
                  if (dragDistance > widget.outValue) {
                    //以angle是否达到出界angle判断
                    runOutAnimate(1); 
                    // print(offsetX > 0 ? 'right' : 'left');
                    // print("type: outValue");
                  } else {
                    //以两个瞬间滑动的方向来判断
                    runOutAnimate(-1); 
                    // print(distanceBetweenTwo > 0 ? 'right' : 'left');
                    // print("type: speed direction");
                  }
                  runInScaleAnimate();
                } else {
                  runBackAnimate();
                }
                // 手指抬起时，回调给上层
                widget.onPointerUp();

              },
              child: ValueListenableBuilder(
                valueListenable: angle,
                builder: (BuildContext context,double value,Widget ? child){
                  return Transform.rotate(
                    angle: value,
                    origin: Offset(value + offsetX, 1500),
                    alignment: Alignment.lerp(Alignment.center, Alignment.bottomCenter, 1),
                    child: child,
                  );
                },
                child: widget.child,
              ),
            )
        ],
      )
    );
  }
}
