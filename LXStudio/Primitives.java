// Primitives
import static processing.core.PApplet.*;
import heronarts.lx.model.*;
import heronarts.lx.transform.*;
import heronarts.lx.color.*;

// Point
class PrimitivePoint {
  public LXVector mPosition = new LXVector(0, 0, 0);
  public int      mColor    = LXColor.WHITE;
  public float    mFalloff  = 0;

  PrimitivePoint() {}
  PrimitivePoint(LXVector iPosition, float iFalloff, int iColor) {
    mPosition = new LXVector(iPosition);
    mColor    = iColor;
    mFalloff  = iFalloff;
  }

  public int getColor(LXPoint iPoint) {
    float distance = Math.distance(iPoint, mPosition);
    if(distance > mFalloff) {
      return 0;
    }

    return LXColor.scaleBrightness(mColor, 1 - (distance / mFalloff));
  }
}

// Sphere
class PrimitiveSphere extends PrimitivePoint {
  public float mRadius = 25.0f;

  PrimitiveSphere() {}
  PrimitiveSphere(LXVector iPosition, float iRadius, float iFalloff, int iColor) {
    super(iPosition, iFalloff, iColor);
    mRadius = iRadius;
  }

  public int getColor(LXPoint iPoint) {
    float distance = Math.distance(iPoint, mPosition);
    if(distance > mRadius + mFalloff) {
      return 0;
    }

    if(distance < mRadius) {
      return mColor;
    }

    return LXColor.scaleBrightness(mColor, 1 - ((distance - mRadius) / mFalloff));
  }
}

// AABB
class PrimitiveAABB extends PrimitivePoint {
  public LXVector mRadius = new LXVector(25.0f, 25.0f, 25.0f);

  PrimitiveAABB() {}
  PrimitiveAABB(LXVector iPosition, LXVector iRadius, float iFalloff, int iColor) {
    super(iPosition, iFalloff, iColor);
    mRadius = iRadius;
  }

  public int getColor(LXPoint iPoint) {
    float distanceX = Math.distance(mPosition.x, iPoint.x);
    float distanceY = Math.distance(mPosition.y, iPoint.y);
    float distanceZ = Math.distance(mPosition.z, iPoint.z);

    // Outside
    if(distanceX > (mRadius.x + mFalloff) ||
       distanceY > (mRadius.y + mFalloff) ||
       distanceZ > (mRadius.z + mFalloff)) {
      return 0;
    }

    // Inside AABB
    if((distanceX < mRadius.x && distanceY < mRadius.y && distanceZ < mRadius.z)
      || mFalloff < Math.EPSILON) {
      return mColor;
    }

    // Inside Falloff
    LXVector minPoint = new LXVector(
      mPosition.x - mRadius.x,
      mPosition.y - mRadius.y,
      mPosition.z - mRadius.z
    );
    LXVector maxPoint = new LXVector(
      mPosition.x + mRadius.x,
      mPosition.y + mRadius.y,
      mPosition.z + mRadius.z
    );
    LXVector nearestPoint = new LXVector(
      min(max(mPosition.x, minPoint.x), maxPoint.x),
      min(max(mPosition.y, minPoint.y), maxPoint.y),
      min(max(mPosition.z, minPoint.z), maxPoint.z)
    );

    // Note This renders weird because it does single source application of light
    return LXColor.scaleBrightness(LXColor.RED, 1 - (Math.distance(iPoint, nearestPoint) / mFalloff));
  }
}
