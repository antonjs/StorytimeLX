import java.util.Arrays;

@LXCategory("Form")
public static class HippyTrap extends LXPattern {
  int PARTICLE_MAX = 100;

  public final ColorParameter    iColor = new ColorParameter("Color", LXColor.WHITE);
  public final CompoundParameter iSize  = new CompoundParameter("Falloff", GridModel3D.SIZE * GridModel3D.SPACING * 0.25f, GridModel3D.SIZE * GridModel3D.SPACING);

  private AABB frustum;
  private ArrayList<ParticleStar> particles = new ArrayList<ParticleStar>();
  private int[] buffer;
  private float backgroundColorBase = 0.0f;
  private float colorBase = 0.0f;

  public HippyTrap(LX lx) {
    super(lx);

    addParameter("Color",   this.iColor);
    addParameter("Falloff", this.iSize);

    this.frustum = new AABB(model.points);
    this.buffer  = new int[model.points.length];

    run(5000);
  }

  // Time is in milliseconds
  public void run(double deltaTime) {
    // println("Particles: " + particles.size());

    // Reset Buffer
    Arrays.fill(this.buffer,
      (int)   LXColor.hsa(
        (float) backgroundColorBase,
        (float) 80.0f,
        (float) 80.0f
      )
    );
    backgroundColorBase = (float)(backgroundColorBase + deltaTime * 0.01) % 360;

    // Emitter
    while(particles.size() < PARTICLE_MAX) {
      float radius = (float) Math.random() * iSize.getValuef();

      this.particles.add(new ParticleStar(
        (float) Math.random() * (frustum.rx + radius) * 2 + frustum.Min().x,
        (float) frustum.Min().y - radius,
        (float) Math.random() * (frustum.rz + radius) * 2 + frustum.Min().z,
        radius,
        (int)   LXColor.hsa(
          (float) colorBase,
          (float) Math.random() * 100,
          (float) Math.random() * 100
        ),
        (float) 0.0f,
        (float) Math.random() * 0.05f,
        (float) 0.0f
      ));

      colorBase = (float)(colorBase + Math.random() * -0.05) % 360;
    }

    for (int i = particles.size() - 1; i >= 0; i--) {
      ParticleStar particle = particles.get(i);

      // Garbage Collection
      if (particle.radius <= Physics.EPSILON ||
        !frustum.collision(particle)) {
        particles.remove(i);
        continue;
      }

      // Update
      particle.update(deltaTime);
      // particle.radius = particle.radius - (float)(particle.radius * 0.25 * deltaTime / 1000);

      // Render
      for (LXPoint point : model.points) {
        if (particle.collision(point)) {
          buffer[point.index] = LXColor.screen(buffer[point.index], particle.getColor(point));
        }
      }
    }

    // Flush Buffer
    for (LXPoint point : model.points) {
      colors[point.index] = buffer[point.index];
    }
  }
}
