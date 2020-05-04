import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:moengine/src/engine/module/engine_module.dart';

/// 资源管理基础类
///
/// 负责游戏的资源管理
abstract class ResourceModule extends EngineModule {
  /// 获取图片方法
  ///
  /// 如果图片没有在缓存里,则调用图片加载方法
  Image getImage(String path, ResourceMode mode);

  /// 图片加载
  ///
  /// 加载指定路径图片,加载成功则放入缓存并返回图片对象
  Future<Null> loadImage(String path, ResourceMode mode);

  /// 移除指定图片
  bool removeImage(String path);

  /// 清除所有图片
  void clearImage();
}

/// 资源位置
enum ResourceMode {
  assets,
  storage,
}

/// 默认资源管理模块
class DefaultResourceModule extends ResourceModule {
  /// 图片缓存
  final Map<String, Image> _imageCache = Map();

  /// 正在加载的图片列表
  final Map<String, int> _loadingFile = Map();

  @override
  void clearImage() {
    List<Image> images = List<Image>.from(_imageCache.values);
    _imageCache.clear();
    // 单独销毁图片
    images.forEach((Image image) {
      image?.dispose();
    });
  }

  @override
  Image getImage(String path, ResourceMode mode) {
    if (path == null) {
      return null;
    }
    path = path.trim();
    Image image = _imageCache[path];
    // 如果没有找到图片则加载图片
    // 在接下来的操作里面有可能获取到
    if (image == null) {
      loadImage(path, mode);
    }
    return image;
  }

  @override
  Future<Null> loadImage(String path, ResourceMode mode) async {
    if (path == null) {
      return;
    }
    path = path.trim();
    // 图片正在加载中就不进行加载操作
    if (_loadingFile[path] != null) {
      return;
    }
    // 开始加载图片
    _loadingFile[path] = 0;

    Image image = await _loadImage(path, mode);

    // 图片加载完成从加载中列表移除
    _loadingFile.remove(path);
    _imageCache[path] = image;
  }

  @override
  bool removeImage(String path) {
    if (path == null) {
      return true;
    }
    path = path.trim();
    Image image = _imageCache[path];
    if (image == null) {
      return true;
    }
    _imageCache.remove(path);
    image.dispose();
    return true;
  }

  /// 图片加载
  Future<Image> _loadImage(String path, ResourceMode mode) async {
    if (path == null) {
      return null;
    }
    path = path.trim();
    Uint8List byteData;
    switch (mode) {
      case ResourceMode.assets:
        byteData = (await rootBundle.load(path))?.buffer?.asUint8List();
        break;
      case ResourceMode.storage:
        File file = File(path);
        if (!(await file.exists())) {
          return null;
        }
        byteData = await file.readAsBytes();
        break;
    }
    if (byteData == null) {
      return null;
    }
    Codec codec = await instantiateImageCodec(byteData);
    FrameInfo frameInfo = await codec.getNextFrame();
    Image image = frameInfo.image;
    return image;
  }
}
