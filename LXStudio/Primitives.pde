// Primatives

public class PrimativeLight extends LXModel {
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

    float distance = Math.distance(iPoint, mPosition.point);
    if(distance < mFalloff) {
      return 0;
    }

    return LXColor.lerp(mColor, 0, distance / mFalloff);
  }
}
