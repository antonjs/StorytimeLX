@LXCategory("Form")
public static class LightSphere extends LXPattern {
  public final CompoundParameter iPositionX = new CompoundParameter("X", GridModel3D.SIZE * GridModel3D.SPACING * 0.5f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final CompoundParameter iPositionY = new CompoundParameter("Y", GridModel3D.SIZE * GridModel3D.SPACING * 0.5f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final CompoundParameter iPositionZ = new CompoundParameter("Z", GridModel3D.SIZE * GridModel3D.SPACING * 0.5f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final ColorParameter    iColor     = new ColorParameter("Color", LXColor.WHITE);
  public final CompoundParameter iRadius    = new CompoundParameter("Radius", GridModel3D.SIZE * GridModel3D.SPACING * 0.25f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final CompoundParameter iFalloff   = new CompoundParameter("Falloff", GridModel3D.SIZE * GridModel3D.SPACING * 0.25f, GridModel3D.SIZE * GridModel3D.SPACING);

  private PrimitiveSphere mLight = new PrimitiveSphere();

  public LightSphere(LX lx) {
    super(lx);
    addParameter("X",       this.iPositionX);
    addParameter("Y",       this.iPositionY);
    addParameter("Z",       this.iPositionZ);
    addParameter("Color",   this.iColor);
    addParameter("Falloff", this.iFalloff);
  }

  // Time is in milliseconds
  public void run(double deltaTime) {
    // Update
    mLight.mPosition.x = iPositionX.getValuef();
    mLight.mPosition.y = iPositionY.getValuef();
    mLight.mPosition.z = iPositionZ.getValuef();
    mLight.mColor      = iColor.getColor();
    mLight.mRadius     = iRadius.getValuef();
    mLight.mFalloff    = iFalloff.getValuef();

    // Render
    for (LXPoint point : model.points) {
      colors[point.index] = mLight.getColor(point);
    }
  }
}
