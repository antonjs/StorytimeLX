// Teach a computer to math, and you never have to math again

import static processing.core.PApplet.*;
import heronarts.lx.model.*;
import heronarts.lx.transform.*;

// Unrolled for SPEED
final class Math {
  final static float EPSILON = 0.0001f;

  public static float distance(float x1, float x2) {
    return abs(x1 - x2);
  }

  public static float distance(float x1, float y1, float x2, float y2) {
    return sqrt(sq(x1 - x2) + sq(y1 - y2));
  }

  public static float distance(float x1, float y1, float z1, float x2, float y2, float z2) {
    return sqrt(sq(x1 - x2) + sq(y1 - y2) + sq(z1 - z2));
  }

  // magnitude
  public static float distance(LXPoint a, LXPoint b) {
    return sqrt(sq(a.x - b.x) + sq(a.y - b.y) + sq(a.z - b.z));
  }

  public static float distance(LXPoint a, LXVector b) {
    return sqrt(sq(a.x - b.x) + sq(a.y - b.y) + sq(a.z - b.z));
  }

  public static LXVector vector(LXPoint a, LXPoint b) {
    return new LXVector(b.x - a.x, b.y - a.y, b.z - a.z);
  };
}
