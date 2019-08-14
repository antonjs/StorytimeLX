@LXCategory("Form")
public static class LightAABB extends LXPattern {
  public final CompoundParameter iPositionX = new CompoundParameter("PosX", GridModel3D.SIZE * GridModel3D.SPACING * 0.5f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final CompoundParameter iPositionY = new CompoundParameter("PosY", GridModel3D.SIZE * GridModel3D.SPACING * 0.5f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final CompoundParameter iPositionZ = new CompoundParameter("PosZ", GridModel3D.SIZE * GridModel3D.SPACING * 0.5f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final ColorParameter    iColor     = new ColorParameter("Color", LXColor.WHITE);
  public final CompoundParameter iRadiusX   = new CompoundParameter("RadX", GridModel3D.SIZE * GridModel3D.SPACING * 0.25f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final CompoundParameter iRadiusY   = new CompoundParameter("RadY", GridModel3D.SIZE * GridModel3D.SPACING * 0.25f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final CompoundParameter iRadiusZ   = new CompoundParameter("RadZ", GridModel3D.SIZE * GridModel3D.SPACING * 0.25f, GridModel3D.SIZE * GridModel3D.SPACING);
  public final CompoundParameter iFalloff   = new CompoundParameter("Falloff", GridModel3D.SIZE * GridModel3D.SPACING * 0.25f, GridModel3D.SIZE * GridModel3D.SPACING);

  private PrimitiveAABB mLight = new PrimitiveAABB();

  public LightAABB(LX lx) {
    super(lx);
    addParameter("PosX",    this.iPositionX);
    addParameter("PosY",    this.iPositionY);
    addParameter("PosZ",    this.iPositionZ);
    addParameter("Color",   this.iColor);
    addParameter("RadX",    this.iRadiusX);
    addParameter("RadY",    this.iRadiusY);
    addParameter("RadZ",    this.iRadiusZ);
    addParameter("Falloff", this.iFalloff);
  }

  // Time is in milliseconds
  public void run(double deltaTime) {
    // Update
    mLight.mPosition.x = iPositionX.getValuef();
    mLight.mPosition.y = iPositionY.getValuef();
    mLight.mPosition.z = iPositionZ.getValuef();
    mLight.mColor      = iColor.getColor();
    mLight.mRadius.x   = iRadiusX.getValuef();
    mLight.mRadius.y   = iRadiusY.getValuef();
    mLight.mRadius.z   = iRadiusZ.getValuef();
    mLight.mFalloff    = iFalloff.getValuef();

    // Render
    for (LXPoint point : model.points) {
      colors[point.index] = mLight.getColor(point);
    }
  }
}
