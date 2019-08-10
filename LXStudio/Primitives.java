// Primatives
import static processing.core.PApplet.*;
import heronarts.lx.model.*;
import heronarts.lx.transform.*;
import heronarts.lx.color.*;

class PrimativeLight {
  public LXVector mPosition = new LXVector(0, 0, 0);
  public int      mColor    = 0;
  public float    mFalloff  = 0;

  PrimativeLight() {
  }

  PrimativeLight(LXVector iPosition, int iColor, float iFalloff) {
    mPosition = new LXVector(iPosition);
    mColor    = iColor;
    mFalloff  = iFalloff;
  }

  public int getColor(LXPoint iPoint) {
    if(mColor == 0 || mFalloff == 0) {
      return 0;
    }

    println(mPosition.point);
    float distance = Math.distance(iPoint, mPosition);
    if(distance > mFalloff) {
      return 0;
    }

    return LXColor.lerp(mColor, 0, distance / mFalloff);
  }
}
