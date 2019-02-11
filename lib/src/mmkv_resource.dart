import 'dart:async';
import 'package:flutter_mmkv/flutter_mmkv.dart';
import 'package:async_resource/async_resource.dart';

/// Store value using [Mmkv].
abstract class MmkvResource<T> extends LocalResource<T> {
  MmkvResource(String key, {this.saveLastModified: false}) : super(path: key);

  final bool saveLastModified;

  String get _key => path;

  @override
  Future<bool> get exists async => (await value) != null;

  @override
  Future fetchContents() => value;

  @override
  Future<DateTime> get lastModified async {
    if (saveLastModified) {
      return DateTime.fromMillisecondsSinceEpoch(
          await FlutterMmkv.decodeInt(modifiedKey));
    }
    return null;
  }

  Future<T> get value;

  String get modifiedKey => '${_key}_modified';

  void _handleLastModified(contents, bool written) {
    if (saveLastModified && written) {
      if (contents == null)
        FlutterMmkv.removeValueForKey(modifiedKey);
      else
        FlutterMmkv.encodeInt(
            modifiedKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<bool> _write(contents);

  @override
  Future<T> write(contents) async {
    var writeResult = await _write(contents);
    _handleLastModified(contents, writeResult);
    return super.write(contents);
  }

  @override
  Future<void> delete() async {
    await FlutterMmkv.removeValueForKey(_key);
    return super.delete();
  }
}

/// A String [Mmkv] entry.
class StringMmkvResource extends MmkvResource<String> {
  StringMmkvResource(String key, {bool saveLastModified: false})
      : super(key, saveLastModified: saveLastModified);

  @override
  Future<String> get value async => FlutterMmkv.decodeString(_key);

  @override
  Future<bool> _write(contents) async {
    FlutterMmkv.encodeString(_key, contents);
    return true;
  }
}

/// A boolean [Mmkv] entry.
class BoolMmkvResource extends MmkvResource<bool> {
  BoolMmkvResource(String key, {bool saveLastModified: false})
      : super(key, saveLastModified: saveLastModified);

  @override
  Future<bool> get value async => FlutterMmkv.decodeBool(_key);

  @override
  Future<bool> _write(contents) async {
    FlutterMmkv.encodeBool(_key, contents);
    return true;
  }
}

/// An integer [Mmkv] entry.
class IntMmkvResource extends MmkvResource<int> {
  IntMmkvResource(String key, {bool saveLastModified: false})
      : super(key, saveLastModified: saveLastModified);

  @override
  Future<int> get value async => FlutterMmkv.decodeInt(_key);

  @override
  Future<bool> _write(contents) async {
    FlutterMmkv.encodeInt(_key, contents);
    return true;
  }
}

/// A double [Mmkv] entry.
class DoubleMmkvResource extends MmkvResource<double> {
  DoubleMmkvResource(String key, {bool saveLastModified: false})
      : super(key, saveLastModified: saveLastModified);

  @override
  Future<double> get value async => FlutterMmkv.decodeDouble(_key);

  @override
  Future<bool> _write(contents) async {
    FlutterMmkv.encodeDouble(_key, contents);
    return true;
  }
}
