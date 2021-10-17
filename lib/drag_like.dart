import 'package:flutter/material.dart';

class DragLike extends StatefulWidget {
  final Widget child;
  final Widget secondChild;
  final double screenWidth;
  final double outValue;
  final double dragSpeed;
  final Duration ? duration;
  final ValueChanged<String?> onOutComplete;
  final VoidCallback onScaleComplete;
  final ValueChanged<Map> onChangeDragDistance;
  final VoidCallback onPointerUp;
  final DragController ? dragController;
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
      required this.onPointerUp, 
      this.dragController, 
      this.duration})
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
  final ValueNotifier<double> secondScale = ValueNotifier(0);
  // 拖拽距离比0.0-1
  double dragDistance = 0;
  // 滑动流畅值，默认3.8，越小越快
  double dragGvalue = 5;
  // 第二层缩放速度，默认4，越小越快
  double secondScaleSd = 2.3;
  // 动画是否执行完成，执行完成后，控制器执行滑动才有效
  bool scaleComplete = true;

  @override
  void initState() {
    super.initState();
    widget.dragController?.controlerInit(this);
  }

  // 更新偏移和缩放量
  void updatePosition(positionX,{iscontroller = false}) {
    // print("positionX = " + positionX.toString());
    // print("lastPositionX = " + lastPositionX.toString());
    double offset = positionX - onPressDx;
    // print("offset = " + offset.toString());

    dragTime = DateTime.now();

    distanceBetweenTwo = positionX - lastPositionX;
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
      if(!iscontroller) {
        widget.onChangeDragDistance({
          'distance': distance,
          'distanceProgress': distanceProgress.abs(),
        });
      }
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

  void runOutAnimate(int type,{iscontroller = false,String completeTag=''}) {
    scaleComplete = false;
    // 回调给上层
    widget.onOutComplete(type == 1 ? (completeTag == '' ? 'right' : completeTag) : (completeTag == '' ? 'left' : completeTag));

    AnimationController controller;
    controller = AnimationController(
        duration: widget.duration == null ? const Duration(milliseconds: 350) : widget.duration, vsync: this);
    // 如果是控制器直接控制滑动，旋转角度直接从0开始
    if(iscontroller) angle.value = 0;
    this.animation = Tween<double>(begin: angle.value, end: type == 1 ? 0.5 : -0.5)
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
    if(iscontroller) {
      secondScale.value = 0.0;
    }
  }

  void runInScaleAnimate() async {
    AnimationController controller;
    controller = AnimationController(
        duration: widget.duration == null ? const Duration(milliseconds: 350) : widget.duration, vsync: this);
    this.scaleAnimation =
        Tween<double>(begin: secondScale.value, end: 0.1).animate(controller)
          ..addListener(() async {
            secondScale.value = this.scaleAnimation!.value;
            if (controller.isCompleted) {
              widget.onScaleComplete();
              scaleComplete = true;
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

                  if(distanceBetweenTwo > 0) {
                    // right
                    runOutAnimate(1);
                  } else {
                    // left
                    runOutAnimate(-1); 
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


class DragController {
  _DragLikeState ?  _widgetState;
  void controlerInit(_DragLikeState _widgetState){
    this._widgetState = _widgetState;
  }


  // 通过控制器左滑出以后，默认回调给上层left，这里可以根据业务自定义把left修改为custom_left等等
  void toLeft({String completeTag = ''}) {
    if(_widgetState!.scaleComplete) {
      _widgetState!.updatePosition(0.0,iscontroller: true);
      _widgetState!.runOutAnimate(-1,iscontroller: true,completeTag: completeTag);
      _widgetState!.runInScaleAnimate();
    }
  }

  // 通过控制器右滑出以后，默认回调给上层right，这里可以根据业务自定义把right修改为custom_right等等
  void toRight({String completeTag = ''}) {
    if(_widgetState!.scaleComplete) {
      _widgetState!.updatePosition(0.0,iscontroller:true);
      _widgetState!.runOutAnimate(1,iscontroller: true,completeTag:completeTag);
      _widgetState!.runInScaleAnimate();
    }
  }

}
