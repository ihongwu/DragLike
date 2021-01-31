import 'package:flutter/material.dart';
class DragLike extends StatefulWidget {

  final Widget child;
  final Widget secondChild;
  final double screenWidth;
  final double outValue;
  final ValueChanged<String> onOutComplete;
  final VoidCallback onScaleComplete;
  final ValueChanged<Map> onChangeDragDistance;
  final VoidCallback onPointerUp;
  DragLike({
    Key key,
    @required this.child,
    @required this.secondChild,
    @required this.screenWidth,
    @required this.outValue,
    this.onOutComplete,
    this.onScaleComplete,
    this.onChangeDragDistance, 
    this.onPointerUp
    }) : assert(child != null) , 
         assert(secondChild != null),
         assert(screenWidth != null),
         assert(outValue != null && outValue<=1 && outValue > 0),
         super(key: key);

  @override
  _DragLikeState createState() => _DragLikeState();
}

class _DragLikeState extends State<DragLike> with TickerProviderStateMixin{

  // 滑动不到指定位置返回时的动画
  Animation animation;
  // 第二个页面动画到前面
  Animation scaleAnimation;
  // 按下时的X坐标，以此判断是左滑还是右滑
  double prevDx = 0;
  // 屏幕宽度
  double get screenWidth => widget.screenWidth;
  
  // 旋转角度
  double angle=0;
  // 旋转时，x轴的偏移量
  double offsetX = 0;
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
  void updatePosition(positionX){
    double offset = positionX - prevDx;
    double offsetAbs = offset.abs();
    double angleTemp = double.parse((offset/screenWidth/dragGvalue).toStringAsFixed(3));
    if (angle != angleTemp) {
      angle = angleTemp;
      secondScale = (offsetAbs/screenWidth/dragGvalue) / secondScaleSd;
      if(secondScale >= 0.1) secondScale = 0.1;
      dragDistance = offsetAbs/screenWidth;
      if(offset<0) {
        offsetX = -80;
      } else {
        offsetX = 80;
      }
      if (widget.onChangeDragDistance != null) {
        double distance = offset/screenWidth;
        double distanceProgress = distance / widget.outValue;
        widget.onChangeDragDistance({'distance':distance,'distanceProgress':distanceProgress.abs()});
      }
      setState(() {});
    }
  }

  // 上层以及第二层返回动画执行
  runBackAnimate(){
    AnimationController controller;
    controller =  AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    this.animation = Tween<double>(begin: angle, end: 0).animate(controller)..addListener((){
      angle = this.animation.value;
      secondScale = angle.abs() / secondScaleSd;
      if(secondScale <=0) secondScale = 0;
      prevDx = 0;
      dragDistance = 0;
      if (controller.isCompleted) {
        controller = null;
      }
      setState(() {});
    });
    controller.forward(from: 0);
  }

  void runOutAnimate(){
    AnimationController controller;
    controller =  AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
    this.animation = Tween<double>(begin: angle, end: angle > 0 ? 0.5 : -0.5).animate(controller)..addListener((){
      angle = this.animation.value;
      prevDx = 0;
      dragDistance = 0;
      if (controller.isCompleted) {
        controller = null;
      }
      setState(() {});
    });
    controller.forward(from: 0);
  }

  void runInScaleAnimate() async{
    AnimationController controller;
    controller =  AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
    this.scaleAnimation = Tween<double>(begin:secondScale,end:0.1).animate(controller)..addListener(() async{
      secondScale = this.scaleAnimation.value;
      if(controller.isCompleted) {
        if (widget.onScaleComplete!=null) {
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
             onPointerDown:(value){
              prevDx = value.position.dx;
             },
             onPointerMove: (value){
              updatePosition(value.position.dx);
             },
             onPointerUp: (value) async{
               if(dragDistance > widget.outValue) {
                 if (widget.onOutComplete != null) {
                   widget.onOutComplete(offsetX > 0 ? 'right' : 'left');
                 }
                 runOutAnimate();
                 runInScaleAnimate();
               } else {
                 runBackAnimate();
               }
               // 手指抬起时，回调给上层
               widget.onPointerUp();
             },
             child: Transform.rotate(
              angle: angle,
              origin: Offset(angle+offsetX,1500),
              alignment: Alignment.lerp(Alignment.center, Alignment.bottomCenter, 1),
              child: widget.child,
            ),
           )
         ],
       )
    );
  }
}