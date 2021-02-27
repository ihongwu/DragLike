import 'package:flutter/material.dart';

class DragLike extends StatefulWidget {
  final Widget child;
  final Widget secondChild;
  final double screenWidth;
  final double outValue;
  final double dragSpeedRatio;
  final ValueChanged<String> onOutComplete;
  final VoidCallback onScaleComplete;
  final ValueChanged<Map> onChangeDragDistance;
  final VoidCallback onPointerUp;
  DragLike(
      {Key key,
      @required this.child,
      @required this.secondChild,
      @required this.screenWidth,
      @required this.outValue,
      @required this.dragSpeedRatio,
      this.onOutComplete,
      this.onScaleComplete,
      this.onChangeDragDistance,
      this.onPointerUp})
      : assert(child != null),
        assert(secondChild != null),
        assert(screenWidth != null),
        assert(outValue != null && outValue <= 1 && outValue > 0),
        assert(dragSpeedRatio != null && dragSpeedRatio > 0),
        super(key: key);

  @override
  _DragLikeState createState() => _DragLikeState();
}

class _DragLikeState extends State<DragLike> with TickerProviderStateMixin {
  // 滑动不到指定位置返回时的动画
  Animation animation;
  // 第二个页面动画到前面
  Animation scaleAnimation;
  // 按下时的X坐标，以此判断是左滑还是右滑
  double onPressDx = 0;
  // 拖拽时，上一瞬间x轴的位置
  double lastPositionX = 0;
  // 屏幕宽度
  double get screenWidth => widget.screenWidth;
  // 旋转角度
  double angle = 0;
  // 旋转时，x轴的偏移量
  double offsetX = 0;
  // 拖拽时，两个瞬间之间，x轴的差值
  double distanceBetweenTwo = 0;
  // 拖拽发生的时间
  DateTime dragTime;
  // 第二层的缩放值，0-0.1，因为已设置初始值为0.9
  double secondScale = 0;
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
    if (angle != angleTemp) {
      angle = angleTemp;
      secondScale = (offsetAbs / screenWidth / dragGvalue) / secondScaleSd;
      if (secondScale >= 0.1) secondScale = 0.1;
      dragDistance = offsetAbs / screenWidth;
      // print("dragDistance = " + dragDistance.toString());

      if (offset < 0) {
        offsetX = -80;
      } else {
        offsetX = 80;
      }

      if (widget.onChangeDragDistance != null) {
        double distance = offset / screenWidth;
        double distanceProgress = distance / widget.outValue;
        widget.onChangeDragDistance({
          'distance': distance,
          'distanceProgress': distanceProgress.abs(),
        });
      }
      setState(() {});
    }
  }

  // 上层以及第二层返回动画执行
  runBackAnimate() {
    AnimationController controller;
    controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    this.animation = Tween<double>(begin: angle, end: 0).animate(controller)
      ..addListener(() {
        angle = this.animation.value;
        secondScale = angle.abs() / secondScaleSd;
        if (secondScale <= 0) secondScale = 0;

        dragDistance = 0;
        if (controller.isCompleted) {
          controller = null;
        }
        setState(() {});
      });
    controller.forward(from: 0);
  }

  void runOutAnimate(int type) {
    AnimationController controller;
    controller = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    // direction: 判断卡片飞出方向的依据
    double direction = distanceBetweenTwo;
    if (type == 1) direction = angle;
    this.animation =
        Tween<double>(begin: angle, end: direction > 0 ? 0.5 : -0.5)
            .animate(controller)
              ..addListener(() {
                angle = this.animation.value;

                dragDistance = 0;
                if (controller.isCompleted) {
                  controller = null;
                }
                setState(() {});
              });
    controller.forward(from: 0);
  }

  void runInScaleAnimate() async {
    AnimationController controller;
    controller = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    this.scaleAnimation =
        Tween<double>(begin: secondScale, end: 0.1).animate(controller)
          ..addListener(() async {
            secondScale = this.scaleAnimation.value;
            if (controller.isCompleted) {
              if (widget.onScaleComplete != null) {
                widget.onScaleComplete();
                controller = null;
              }
              // 缩放完成以后，将上一层的widget还原到起始位置，不要动画，业务方需要将上层widget的数据替换
              angle = 0;
            }
            setState(() {});
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
        Transform.scale(
          scale: 0.9 + secondScale,
          child: widget.secondChild,
        ),
        Listener(
          onPointerDown: (value) {
            onPressDx = value.position.dx;
            lastPositionX = onPressDx;
            // print("--------------------------------");
          },
          onPointerMove: (value) {
            updatePosition(value.position.dx);
          },
          onPointerUp: (value) async {
            int timeOffset = DateTime.now().difference(dragTime).inMicroseconds;
            //滑动速率 = 两个瞬间的距离 / 两个瞬间的时间差
            // print("timeOffset = " + timeOffset.toString());
            if (timeOffset < 5000)
              timeOffset = 7500;
            else if (timeOffset < 8000) timeOffset = 10000;
            double dragSpeed = (distanceBetweenTwo / timeOffset * 1e5).abs();

            // print("distanceBetweenTwo = " + distanceBetweenTwo.toString());
            // print("dragSpeed = " + dragSpeed.toString());
            if (dragDistance > widget.outValue || dragSpeed >= widget.dragSpeedRatio) {
              if (widget.onOutComplete != null) {
                  widget.onOutComplete(offsetX > 0 ? 'right' : 'left');
              }
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
            if (widget.onPointerUp != null) {
              widget.onPointerUp();
            }
          },
          child: Transform.rotate(
            angle: angle,
            origin: Offset(angle + offsetX, 1500),
            alignment:
                Alignment.lerp(Alignment.center, Alignment.bottomCenter, 1),
            child: widget.child,
          ),
        )
      ],
    ));
  }
}
