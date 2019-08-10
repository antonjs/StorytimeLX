// Primitives
import static processing.core.PApplet.*;
import heronarts.lx.model.*;
import heronarts.lx.transform.*;
import heronarts.lx.color.*;

// Point
class PrimitivePoint {
  public LXVector mPosition = new LXVector(0, 0, 0);
  public int      mColor    = LXColor.WHITE;
  public float    mFalloff  = 50.0f;

  PrimitivePoint() {
  }

  PrimitivePoint(LXVector iPosition, int iColor, float iFalloff) {
    mPosition = new LXVector(iPosition);
    mColor    = iColor;
    mFalloff  = iFalloff;
  }

  public int getColor(LXPoint iPoint) {
    if(mColor == 0 || mFalloff == 0) {
      return 0;
    }

    float distance = Math.distance(iPoint, mPosition);
    if(distance > mFalloff) {
      return 0;
    }

    return LXColor.scaleBrightness(mColor, 1 - (distance / mFalloff));
  }
}

// Sphere
class PrimitiveSphere extends PrimitivePoint {
  public float mRadius = 50.0f;

  PrimitiveSphere() {
  }

  PrimitiveSphere(LXVector iPosition, int iColor, float iRadius, float iFalloff) {
    super(iPosition, iColor, iFalloff);
    mRadius = iRadius;
  }

  public int getColor(LXPoint iPoint) {
    if(mColor == 0 || mFalloff == 0) {
      return 0;
    }

    float distance = Math.distance(iPoint, mPosition);
    if(distance > mFalloff + mRadius) {
      return 0;
    }

    if(distance < mRadius) {
      return mColor;
    }

    return LXColor.scaleBrightness(mColor, 1 - ((distance - mRadius) / mFalloff));
  }
}
