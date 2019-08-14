@LXCategory("Form")
public static class LightPoint extends LXPattern {
  public final CompoundParameter iPositionX = new CompoundParameter("X", GridModel3D.SIZE * GridModel3D.SPACING * 0.5f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final CompoundParameter iPositionY = new CompoundParameter("Y", GridModel3D.SIZE * GridModel3D.SPACING * 0.5f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final CompoundParameter iPositionZ = new CompoundParameter("Z", GridModel3D.SIZE * GridModel3D.SPACING * 0.5f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final ColorParameter    iColor     = new ColorParameter("Color", LXColor.WHITE);
  public final CompoundParameter iFalloff   = new CompoundParameter("Falloff", GridModel3D.SIZE * GridModel3D.SPACING * 0.25f, GridModel3D.SIZE * GridModel3D.SPACING);

  private PrimitivePoint mLight = new PrimitivePoint();

  public LightPoint(LX lx) {
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
    mLight.mFalloff    = iFalloff.getValuef();

    // Render
    for (LXPoint point : model.points) {
      colors[point.index] = mLight.getColor(point);
    }
  }
}
