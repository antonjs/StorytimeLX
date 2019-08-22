// Primitives
import static processing.core.PApplet.*;
import heronarts.lx.model.*;
import heronarts.lx.transform.*;
import heronarts.lx.color.*;

// Point
// @todo PVector??
class Point {
  public float x = 0.0f;
  public float y = 0.0f;
  public float z = 0.0f;

  Point(){}
  Point(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public boolean collision(LXPoint that) {
    return (sq(this.x - that.x) + sq(this.y - that.y) + sq(this.z - that.z)) <= sq(Physics.EPSILON);
  }
  public boolean collision(Point that) {
    return (sq(this.x - that.x) + sq(this.y - that.y) + sq(this.z - that.z)) <= sq(Physics.EPSILON);
  }
}

// Sphere
class Sphere extends Point {
  public float radius = 25.0f;

  Sphere(){}
  Sphere(float x, float y, float z, float radius) {
    super(x, y, z);
    this.radius = radius;
  }

  public boolean collision(LXPoint that) {
    return (sq(this.x - that.x) + sq(this.y - that.y) + sq(this.z - that.z)) <= sq(this.radius);
  }
  public boolean collision(Point that) {
    return (sq(this.x - that.x) + sq(this.y - that.y) + sq(this.z - that.z)) <= sq(this.radius);
  }
  public boolean collision(Sphere that) {
    return (sq(this.x - that.x) + sq(this.y - that.y) + sq(this.z - that.z)) <= sq(this.radius + that.radius);
  }
}

// AABB
class AABB extends Point {
  public float rx = 25.0f;
  public float ry = 25.0f;
  public float rz = 25.0f;

  AABB(){}
  AABB(float x, float y, float z, float rx, float ry, float rz) {
    super(x, y, z);
    this.rx = rx;
    this.ry = ry;
    this.rz = rz;
  }
  AABB(LXPoint[] points) {
    float minX, minY, minZ, maxX, maxY, maxZ;

    minX = maxX = points[0].x;
    minY = maxY = points[0].y;
    minZ = maxZ = points[0].z;

    for (LXPoint point : points) {
      minX = min(minX, point.x);
      minY = min(minY, point.y);
      minZ = min(minZ, point.z);

      maxX = max(minX, point.x);
      maxY = max(maxY, point.y);
      maxZ = max(maxZ, point.z);
    }

    this.x = (minX + maxX) * 0.5f;
    this.y = (minY + maxY) * 0.5f;
    this.z = (minZ + maxZ) * 0.5f;

    this.rx = (maxX - minX) * 0.5f;
    this.ry = (maxY - minY) * 0.5f;
    this.rz = (maxZ - minZ) * 0.5f;
  }

  public boolean collision(LXPoint that) {
    return (
      sq(this.x - that.x) <= sq(this.rx) &&
      sq(this.y - that.y) <= sq(this.ry) &&
      sq(this.z - that.z) <= sq(this.rz)
    );
  }

  public boolean collision(Point that) {
    return (
      sq(this.x - that.x) <= sq(this.rx) &&
      sq(this.y - that.y) <= sq(this.ry) &&
      sq(this.z - that.z) <= sq(this.rz)
    );
  }
  public boolean collision(Sphere that) {
    return (
      sq(this.x - that.x) <= sq(this.rx + that.radius) &&
      sq(this.y - that.y) <= sq(this.ry + that.radius) &&
      sq(this.z - that.z) <= sq(this.rz + that.radius)
    );
  }
  public boolean collision(AABB that) {
    return (
      sq(this.x - that.x) <= sq(this.rx + that.rx) &&
      sq(this.y - that.y) <= sq(this.ry + that.ry) &&
      sq(this.z - that.z) <= sq(this.rz + that.rz)
    );
  }

  public Point Min(){
    return new Point(this.x - this.rx, this.y - this.ry, this.z - this.rz);
  }

  public Point Max(){
    return new Point(this.x + this.rx, this.y + this.ry, this.z + this.rz);
  }
}
