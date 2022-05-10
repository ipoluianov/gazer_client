
import 'dart:ui';


enum CalcPreferredScaleType {
  contain,
  fill,
  cover
}

class CalcPreferredScaleResult {
  Offset offset;
  double scaleX;
  double scaleY;
  CalcPreferredScaleResult(this.offset, this.scaleX, this.scaleY);
}

CalcPreferredScaleResult calcPreferredScale(Size target, Size source, CalcPreferredScaleType type) {
  CalcPreferredScaleResult result = CalcPreferredScaleResult(Offset.zero, 0, 0);

  double iK = 0;
  double iKo = 0;
  if (source.height != 0) {
    iK = source.width / source.height;
  }
  if (target.height != 0) {
    iKo = target.width / target.height;
  }

  double scale = 0;

  if (type == CalcPreferredScaleType.contain) {
    if (iK > iKo) {
      if (source.width != 0) {
        scale = target.width / source.width;
      }
    } else {
      if (source.height != 0) {
        scale = target.height / source.height;
      }
    }
    result.scaleX = scale;
    result.scaleY = scale;
    double fullWidthOfView = source.width * scale;
    double fullHeightOfView = source.height * scale;
    result.offset = Offset(target.width / 2 - fullWidthOfView / 2, target.height / 2 - fullHeightOfView / 2);

  }

  if (type == CalcPreferredScaleType.cover) {
    if (iK < iKo) {
      if (source.width != 0) {
        scale = target.width / source.width;
      }
    } else {
      if (source.height != 0) {
        scale = target.height / source.height;
      }
    }

    result.scaleX = scale;
    result.scaleY = scale;
    double fullWidthOfView = source.width * scale;
    double fullHeightOfView = source.height * scale;
    result.offset = Offset(target.width / 2 - fullWidthOfView / 2, target.height / 2 - fullHeightOfView / 2);
  }

  if (type == CalcPreferredScaleType.fill) {
    result.scaleX = target.width / source.width;
    result.scaleY = target.height / source.height;
    result.offset = const Offset(0, 0);
  }

  return result;
}
