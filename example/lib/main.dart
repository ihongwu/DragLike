import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:drag_like/drag_like.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List data = [
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fn.sinaimg.cn%2Fsinacn20%2F170%2Fw1024h1546%2F20180318%2Fa00d-fyshfur3814572.jpg&refer=http%3A%2F%2Fn.sinaimg.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1613903060&t=651082a2ee0be03315c114381adaea8dhttps://gimg2.baidu.com/image_search/src=http%3A%2F%2Fn.sinaimg.cn%2Fsinacn20%2F170%2Fw1024h1546%2F20180318%2Fa00d-fyshfur3814572.jpg&refer=http%3A%2F%2Fn.sinaimg.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1613903060&t=651082a2ee0be03315c114381adaea8d',
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fn1.itc.cn%2Fimg8%2Fwb%2Frecom%2F2016%2F05%2F19%2F146364216575228138.JPEG&refer=http%3A%2F%2Fn1.itc.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1614001788&t=3727c8bd4ef9b45d3749fa42a6f28081',
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201302%2F17%2F20130217172444_rKtvc.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1614001866&t=a54e01b85f08ceaff5511f8def64ef38',
    'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1220965489,466788603&fm=26&gp=0.jpg',
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fp4.qhimg.com%2Ft01613ae824dd1edf73.jpg&refer=http%3A%2F%2Fp4.qhimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1614001866&t=4eee5185802274b50430200acd6fcbec',
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic.jj20.com%2Fup%2Fallimg%2Fmn01%2F022319225536%2F1Z223225536-4.jpg&refer=http%3A%2F%2Fpic.jj20.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1614001866&t=dc5b44cf1f3581c1a787d1e4673ebc57',
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F2017-12-11%2F5a2e3dc01ae8c.jpg&refer=http%3A%2F%2Fpic1.win4000.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1614001866&t=f2eaf54e9c947e66a4ac87ccc4faa8dc',
    'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fphoto.meifajie.com%2Fpictures%2F2018-05%2F180507_152555_31502.jpg&refer=http%3A%2F%2Fphoto.meifajie.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1614001866&t=7ffe32272026d19d863d4566ba675f31',
  ];

  List imagelist = [];

  void loaddata() async {
    await Future.delayed(Duration(milliseconds: 2000));
    imagelist.addAll(data);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loaddata();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DragLike'),
        ),
        body: Center(
          child: Container(
              width: double.infinity,
              height: double.infinity,
              margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              child: Stack(
                children: [
                  DragLike(
                    child: imagelist.length <= 0
                        ? Text('加载中...')
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: TestDrag(src: imagelist[0])),
                    secondChild: imagelist.length <= 1
                        ? Container()
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: TestDrag(src: imagelist[1])),
                    screenWidth: 375,
                    outValue: 0.4,
                    dragSpeedRatio: 80,
                    onChangeDragDistance: (distance) {
                      /// {distance: 0.17511112467447917, distanceProgress: 0.2918518744574653}
                      print(distance.toString());
                    },
                    onOutComplete: (type) {
                      /// left or right
                      print(type);
                    },
                    onScaleComplete: () {
                      imagelist.remove(imagelist[0]);
                      if (imagelist.length == 0) {
                        loaddata();
                      }
                      setState(() {});
                    },
                    onPointerUp: () {},
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class TestDrag extends StatelessWidget {
  final String src;
  const TestDrag({Key ? key,required this.src}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey,
      child: Image.network(
        src,
        fit: BoxFit.cover,
      ),
    );
  }
}
