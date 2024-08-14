import 'package:fl_lib/fl_lib.dart';

class AbsolutePath {
  String _path;
  final _prePath = <String>[];

  AbsolutePath(this._path);

  String get path => _path;

  /// Update path, not set path
  set path(String newPath) {
    _prePath.add(_path);
    if (newPath == '..') {
      _path = _path.substring(0, _path.lastIndexOf('/'));
      if (_path == '') {
        _path = '/';
      }
      return;
    }
    if (newPath.startsWith('/')) {
      _path = newPath;
      return;
    }
    _path = _path.joinPath(newPath, seperator: '/');
  }

  bool undo() {
    if (_prePath.isEmpty) {
      return false;
    }
    _path = _prePath.removeLast();
    return true;
  }
}
