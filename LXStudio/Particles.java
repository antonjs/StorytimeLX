// Particles
import static processing.core.PApplet.*;
import heronarts.lx.model.*;
import heronarts.lx.transform.*;
import heronarts.lx.color.*;

// Sphere
// class ParticleSphere extends Sphere {
//   PrimitiveSphere() {}
//   PrimitiveSphere(LXVector iPosition, float iRadius, float iFalloff, int iColor) {
//     super(iPosition, iFalloff, iColor);
//     mRadius = iRadius;
//   }
//
//   public int getColor(LXPoint iPoint) {
//     float distance = Physics.distance(iPoint, mPosition);
//     if(distance > mRadius + mFalloff) {
//       return 0;
//     }
//
//     if(distance < mRadius) {
//       return mColor;
//     }
//
//     return LXColor.scaleBrightness(mColor, 1 - ((distance - mRadius) / mFalloff));
//   }
// }
//
// // Particle
// class Particle extends PrimitivePoint {
//   public int      mColorEnd         = LXColor.WHITE;
//   public float    mFalloffEnd       = 10.0f;
//   public LXVector mVelocity         = new LXVector(0, 0, 0);
//   public double   mLifetimeMs       = 0;
//   public double   mCurrentTimeMs    = 0;
//
//   Particle() {}
//   Particle(LXVector iPosition, LXVector iVelocity, double iLifetimeMs, float iFalloffStart, float iFalloffEnd, int iColorStart, int iColorEnd) {
//     super(iPosition, iFalloffStart, iColorStart);
//     mVelocity   = iVelocity;
//     mFalloffEnd = iFalloffEnd;
//     mLifetimeMs = iLifetimeMs;
//     mColorEnd   = iColorEnd;
//   }
//
//   public boolean isAlive() {
//     return (mCurrentTimeMs < mLifetimeMs);
//   }
//
//   public void update(double deltaMs) {
//     mCurrentTimeMs += deltaMs;
//
//     mPosition.x += mVelocity.x * (mCurrentTimeMs / 1000.0);
//     mPosition.y += mVelocity.y * (mCurrentTimeMs / 1000.0);
//     mPosition.z += mVelocity.z * (mCurrentTimeMs / 1000.0);
//   }
//
//   public int getColor(LXPoint iPoint) {
//     float  distance  = Physics.distance(iPoint, mPosition);
//     double timeScale = mCurrentTimeMs / mLifetimeMs;
//     float  adjustedFalloff;
//
//     if(distance > mFalloff) {
//       return 0;
//     }
//
//     return LXColor.scaleBrightness(LXColor.lerp(mColor, mColorEnd, timeScale), 1 - (distance / mFalloff));
//   }
// }
//
// // Emitter
// // class ParticleEmitter {
// //   public LXVector mPosition   = new LXVector(0, 0, 0);
// //   public int      mColorStart = LXColor.WHITE;
// //   public int      mColorEnd   = LXColor.WHITE;
// //   public float    mFalloff    = 10.0f; // Start End
// //
// //   public double mLifetimeMs        = 1000;
// //   public float  mLifetimeVariation = 0.5f;
// //
// //   public LXVector mDirection = LXVector(0, 1, 0);
// //   public float    mVelocity  = 10;
// //   public float    mVelocityVariation = 0.5f;
// //
// //   public Particle[] mParticles = new Particle[100];
// //
// //   public void update(double deltaMs) {
// //     for (Particle particle : mParticles) {
// //       particle.update(deltaMs);
// //     }
// //   }
// //
// //   public int getColor(LXPoint iPoint) {
// //   }
// // }
//
// //////////////////
// // Point
// class PrimitivePoint {
//   public LXVector mPosition = new LXVector(0, 0, 0);
//   public int      mColor    = LXColor.WHITE;
//   public float    mFalloff  = 0;
//
//   PrimitivePoint() {}
//   PrimitivePoint(LXVector iPosition, float iFalloff, int iColor) {
//     mPosition = new LXVector(iPosition);
//     mColor    = iColor;
//     mFalloff  = iFalloff;
//   }
//
//   public int getColor(LXPoint iPoint) {
//     float distance = Physics.distance(iPoint, mPosition);
//     if(distance > mFalloff) {
//       return 0;
//     }
//
//     return LXColor.scaleBrightness(mColor, 1 - (distance / mFalloff));
//   }
// }
//
// // AABB
// class PrimitiveAABB extends PrimitivePoint {
//   public LXVector mRadius = new LXVector(25.0f, 25.0f, 25.0f);
//
//   PrimitiveAABB() {}
//   PrimitiveAABB(LXVector iPosition, LXVector iRadius, float iFalloff, int iColor) {
//     super(iPosition, iFalloff, iColor);
//     mRadius = iRadius;
//   }
//
//   public int getColor(LXPoint iPoint) {
//     float distanceX = Physics.distance(mPosition.x, iPoint.x);
//     float distanceY = Physics.distance(mPosition.y, iPoint.y);
//     float distanceZ = Physics.distance(mPosition.z, iPoint.z);
//
//     // Outside
//     if(distanceX > (mRadius.x + mFalloff) ||
//        distanceY > (mRadius.y + mFalloff) ||
//        distanceZ > (mRadius.z + mFalloff)) {
//       return 0;
//     }
//
//     // Inside AABB
//     if((distanceX < mRadius.x && distanceY < mRadius.y && distanceZ < mRadius.z)
//       || mFalloff < Physics.EPSILON) {
//       return mColor;
//     }
//
//     // Inside Falloff
//     LXVector minPoint = new LXVector(
//       mPosition.x - mRadius.x,
//       mPosition.y - mRadius.y,
//       mPosition.z - mRadius.z
//     );
//     LXVector maxPoint = new LXVector(
//       mPosition.x + mRadius.x,
//       mPosition.y + mRadius.y,
//       mPosition.z + mRadius.z
//     );
//     LXVector nearestPoint = new LXVector(
//       min(max(mPosition.x, minPoint.x), maxPoint.x),
//       min(max(mPosition.y, minPoint.y), maxPoint.y),
//       min(max(mPosition.z, minPoint.z), maxPoint.z)
//     );
//
//     // Note This renders weird because it does single source application of light
//     return LXColor.scaleBrightness(LXColor.RED, 1 - (Physics.distance(iPoint, nearestPoint) / mFalloff));
//   }
// }
