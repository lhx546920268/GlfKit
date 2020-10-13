class FileUtils {

  ///格式化文件大小
  ///size 字节
  static String formatFileSize(int size) {
    if (size > 1024) {
      int kb = size ~/ 1024;
      if (kb > 1024) {
        int mb = kb ~/ 1024;
        if (mb > 1024) {
          int gb = mb ~/ 1024;
          if (gb > 1024) {
            return '${(gb / 1024).toStringAsFixed(2)}T';
          } else {
            return '${(mb / 1024).toStringAsFixed(2)}G';
          }
        } else {
          return '${(kb / 1024).toStringAsFixed(2)}M';
        }
      } else {
        return '${kb}K';
      }
    } else {
      return '${size}B';
    }
  }
}
