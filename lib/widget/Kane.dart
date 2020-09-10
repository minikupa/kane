import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:kane/model/KaneType.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class Kane extends StatefulWidget {
  final KaneType kaneType;
  final int index;
  final Function deleteKane;

  Kane({Key key, @required this.kaneType, @required this.index, @required this.deleteKane}) : super(key: key);

  @override
  KaneState createState() => KaneState();
}

class KaneState extends State<Kane> {
  Matrix4 _matrix = Matrix4.identity();
  int _noseCount = 0, _noseSize = 0;
  bool _isHover = false, _isNoseHover = false, _isPlaying = false;
  KaneType _kaneType;
  List<GlobalKey<ImageSequenceAnimatorState>> animatorKeyList = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey()
  ];

  AudioCache _cache = AudioCache();
  AudioPlayer _player;

  @override
  void initState() {
    _kaneType = widget.kaneType ?? KaneType.Kane;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Widget kane;
    switch (_kaneType) {
      case KaneType.Kane:
        kane = _kaneAnimation("kane", 8, 15, animatorKeyList[0], true);
        break;
      case KaneType.Ricardo:
        kane = _kaneAnimation("ricardo", 212, 15, animatorKeyList[1], false);
        break;
      case KaneType.SexyKane:
        kane = _kaneAnimation("sexyKane", 9, 15, animatorKeyList[2], true);
        break;
      case KaneType.MoemoeKane:
        kane = _kaneAnimation("moemoe", 137, 24, animatorKeyList[3], false);
        break;
      default:
        kane = _kaneAnimation("hanwha", 203, 24, animatorKeyList[4], false);
    }

    return MatrixGestureDetector(
      shouldRotate: false,
      onMatrixUpdate: (m, tm, sm, rm) {
        setState(() {
          _matrix = m;
        });
      },
      child: Transform(
        transform: _matrix,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                child: Container(
                  height: ScreenUtil().setHeight(800),
                  child: kane,
                ),
              ),
            ),
            _isHover
                ? Align(
                    child: InkWell(
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      margin: const EdgeInsets.only(bottom: 32.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, border: Border.all()),
                      child: Icon(
                        Icons.delete,
                      ),
                    ),
                    onTap: () => widget.deleteKane(widget.index),
                  ))
                : Container(),
            _kaneType == KaneType.Kane && !_isPlaying
                ? Positioned(
                    top: ScreenUtil().setHeight(918),
                    left: ScreenUtil().setWidth(1),
                    right: ScreenUtil().setWidth(1),
                    child: InkWell(
                      child: _isNoseHover
                          ? ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.grey[400], BlendMode.modulate),
                              child: Image.asset(
                                "assets/kane/kane/nose.webp",
                                width: ScreenUtil().setHeight(40 + _noseSize),
                                height: ScreenUtil().setHeight(40 + _noseSize),
                                fit: BoxFit.contain,
                              ))
                          : Image.asset(
                              "assets/kane/kane/nose.webp",
                              width: ScreenUtil().setHeight(40 + _noseSize),
                              height: ScreenUtil().setHeight(40 + _noseSize),
                              fit: BoxFit.contain,
                            ),
                      onTap: () {
                        _noseSize += 3;
                        if (_noseSize < 33) {
                          if (++_noseCount >= Random().nextInt(5) + 3) {
                            _noseCount = 0;
                            _cache.play('music/igonan.m4a');
                          } else {
                            _cache.play('music/bbolong.mp3');
                          }
                        }
                        setState(() {
                          _isNoseHover = false;
                          if (_noseSize >= 33) {
                            _noseSize = 0;
                            _cache.play('music/pop.mp3');
                          }
                        });
                      },
                      onTapDown: (_) => setState(() => _isNoseHover = true),
                      onTapCancel: () => setState(() => _isNoseHover = false),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _kaneAnimation(String name, double frameCount, double fps,
      GlobalKey<ImageSequenceAnimatorState> key, bool rewind) {
    bool first = true;
    return InkWell(
      child: ImageSequenceAnimator(
        "assets/kane/$name",
        "$name",
        0,
        frameCount.toString().length - 2,
        "webp",
        frameCount,
        key: key,
        fps: fps,
        isAutoPlay: false,
        color: null,
        onFinishPlaying: (animator) {
          if (rewind && first) {
            key.currentState.rewind();
            first = false;
          } else {
            setState(() {
              _isPlaying = false;
              first = true;
            });
            key.currentState.reset();
          }
        },
      ),
      onTap: () async {
        if (!_isPlaying) {
          setState(() {
            _isPlaying = true;
          });
          _player = await _cache.play('music/$name.mp3');
          key.currentState.play();
        } else {
          setState(() {
            _isPlaying = false;
            first = true;
          });
          _player.stop();
          key.currentState.reset();
        }
      },
      onLongPress: () {
        setState(() => _isHover = true);
        Future.delayed(
            Duration(milliseconds: 1500), () {
              if(mounted) {
                setState(() => _isHover = false);
              }
        });
      } ,
    );
  }
}
