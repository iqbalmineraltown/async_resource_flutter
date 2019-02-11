import 'dart:async' show Future;
import 'package:async_resource/async_resource.dart';
import 'dart:convert';

import 'package:mmkv/mmkv.dart';
export 'package:async_resource/async_resource.dart';

/// Resource for asyncResource with MMKV
class MMKVResource<T> extends LocalResource<T> {
  MMKVResource(this.key, this.path, {Parser<T> parser})
      : super(path: path, parser: parser);

  final String key;
  final String path;

  Future<Mmkv> get _instance async => await Mmkv.defaultInstance();

  @override
  Future<bool> get exists async {
    var mmkv = await _instance;
    return await mmkv.containsKey(key);
  }

  Future<Map<String, dynamic>> get _read async {
    var mmkv = await _instance;
    if (!await exists) {
      return null;
    }
    var value = await mmkv.getString(key);
    return jsonDecode(value);
  }

  @override
  Future<DateTime> get lastModified async {
    var contentPlusTime = await _read;
    return DateTime.parse(contentPlusTime['lastModified']);
  }

  @override
  Future fetchContents() async {
    var contentPlusTime = await _read;
    return contentPlusTime['contents'];
  }

  @override
  Future<T> write(contents) async {
    var mmkv = await _instance;

    String lastModified = DateTime.now().toIso8601String();
    Map contentPlusTime = {'lastModified': lastModified, 'contents': contents};

    mmkv.putString(key, jsonEncode(contentPlusTime));
    return super.write(contents);
  }

  @override
  Future<void> delete() async {
    var mmkv = await _instance;
    await mmkv.remove(key);
    super.delete();
  }
}
