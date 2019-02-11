import 'dart:async';
import 'package:mmkv/mmkv.dart';
import 'package:async_resource/async_resource.dart';

/// Store value using [Mmkv].
abstract class MmkvResource<T> extends LocalResource<T> {
  MmkvResource(String key, {this.saveLastModified: false}) : super(path: key);

  final bool saveLastModified;

  String get _key => path;
  Future<Mmkv> get _mmkvInstance => Mmkv.defaultInstance();

  @override
  Future<bool> get exists async => (await value) != null;

  @override
  Future fetchContents() => value;

  @override
  Future<DateTime> get lastModified async {
    if (saveLastModified) {
      return DateTime.fromMillisecondsSinceEpoch(
          await (await _mmkvInstance).getInt(modifiedKey));
    }
    return null;
  }

  Future<T> get value;

  String get modifiedKey => '${_key}_modified';

  void _handleLastModified(Mmkv mmkv, contents, bool written) {
    if (saveLastModified && written) {
      if (contents == null)
        mmkv.remove(modifiedKey);
      else
        mmkv.putInt(modifiedKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<bool> _write(contents);

  @override
  Future<T> write(contents) async {
    final p = await _mmkvInstance;
    var writeResult = await _write(contents);
    _handleLastModified(p, contents, writeResult);
    return super.write(contents);
  }

  @override
  Future<void> delete() async {
    await (await _mmkvInstance).remove(_key);
    return super.delete();
  }
}

/// A String [Mmkv] entry.
class StringMmkvResource extends MmkvResource<String> {
  StringMmkvResource(String key, {bool saveLastModified: false})
      : super(key, saveLastModified: saveLastModified);

  @override
  Future<String> get value async => (await _mmkvInstance).getString(_key);

  @override
  Future<bool> _write(contents) async {
    final p = await _mmkvInstance;
    p.putString(_key, contents);
    return true;
  }
}

/// A boolean [Mmkv] entry.
class BoolMmkvResource extends MmkvResource<bool> {
  BoolMmkvResource(String key, {bool saveLastModified: false})
      : super(key, saveLastModified: saveLastModified);

  @override
  Future<bool> get value async => (await _mmkvInstance).getBoolean(_key);

  @override
  Future<bool> _write(contents) async {
    final p = await _mmkvInstance;
    p.putBoolean(_key, contents);
    return true;
  }
}

/// An integer [Mmkv] entry.
class IntMmkvResource extends MmkvResource<int> {
  IntMmkvResource(String key, {bool saveLastModified: false})
      : super(key, saveLastModified: saveLastModified);

  @override
  Future<int> get value async => (await _mmkvInstance).getInt(_key);

  @override
  Future<bool> _write(contents) async {
    final p = await _mmkvInstance;
    p.putInt(_key, contents);
    return true;
  }
}

/// A double [Mmkv] entry.
class DoubleMmkvResource extends MmkvResource<double> {
  DoubleMmkvResource(String key, {bool saveLastModified: false})
      : super(key, saveLastModified: saveLastModified);

  @override
  Future<double> get value async => (await _mmkvInstance).getDouble(_key);

  @override
  Future<bool> _write(contents) async {
    final p = await _mmkvInstance;
    p.putDouble(_key, contents);
    return true;
  }
}
