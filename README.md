# drag_like
1. Flutter左滑右滑/喜欢、不喜欢的特效插件
2. 支持划出事件回调，通知上层是左边划出还是右边划出
3. 支持滑动进度回调
4. 支持第二层widget缩放完成回调，缩放完成时刷新数据
5. 支持手指抬起回调
6. 支持手速检测，速度超过指定值后，卡片将会划出屏幕（感谢[@DoodleBears](https://github.com/DoodleBears)贡献代码）
7. null safety

### 安装
在工程 pubspec.yaml 中加入 dependencies

```
dependencies:
  drag_like: ^last version
```
## 效果图
<img src="https://raw.githubusercontent.com/ihongwu/DragLike/main/drag_like.gif" width="400">

## 使用方法
```
DragLike(
  child: imagelist.length <=0 ? Text('加载中...') : ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: TestDrag(src:imagelist[0])
  ), 
  secondChild: imagelist.length <= 1 ? Container(): ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child:TestDrag(src:imagelist[1])
  ), 
  screenWidth: 375, 
  outValue: 0.6,
  dragSpeedRatio: 80,
  onChangeDragDistance: (distance){
    /// {distance: 0.17511112467447917, distanceProgress: 0.2918518744574653}
    print(distance.toString());
  },
  onOutComplete: (type){
    /// left or right
    print(type);
  },
  onScaleComplete: (){
    imagelist.remove(imagelist[0]);
    if(imagelist.length == 0) {
      loaddata();
    }
    setState(() {});
  },
  onPointerUp: (){
    
  },
),
```

## 回调方法
### onOutComplete
```
onOutComplete: (type){
	/// left or right
	print(type);
},
```

### onScaleComplete
```
onScaleComplete: (){
	imagelist.remove(imagelist[0]);
	if(imagelist.length == 0) {
		loaddata();
	}
	setState(() {});
},
```

### onChangeDragDistance
1. distance滑动距离，0-1，超过设置的值将会划出widget
2. distanceProgress，根据设置的划出边界值的百分比，0-1+，方便做一些特效，超过1即代表松手就会划出边界
```

onChangeDragDistance: (distance){
	/// {distance: 0.17511112467447917, distanceProgress: 0.2918518744574653}
	print(distance.toString());
},
```
### onPointerUp
```
onPointerUp: (){

},
```

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
