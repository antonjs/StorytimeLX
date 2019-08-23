// Lights
import static processing.core.PApplet.*;
import heronarts.lx.model.*;
import heronarts.lx.transform.*;
import heronarts.lx.color.*;

// Sphere
class LightPoint extends Sphere {
  public int color = LXColor.WHITE;

  LightPoint() {}
  LightPoint(float x, float y, float z, float radius, int color) {
    super(x, y, z, radius);
    this.color = color;
  }

  public int getColor(LXPoint point) {
    float distance = Physics.sqDistance(this, point);

    return LXColor.scaleBrightness(color, 1 - (distance / sq(radius)));
  }
}
