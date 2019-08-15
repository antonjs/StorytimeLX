// In this file you can define your own custom patterns

// Here is a fairly basic example pattern that renders a plane that can be moved
// across one of the axes.
@LXCategory("Form")
public static class PlanePattern extends LXPattern {
  
  public enum Axis {
    X, Y, Z
  };
  
  public final EnumParameter<Axis> axis =
    new EnumParameter<Axis>("Axis", Axis.X)
    .setDescription("Which axis the plane is drawn across");
  
  public final CompoundParameter pos = new CompoundParameter("Pos", 0, 1)
    .setDescription("Position of the center of the plane");
  
  public final CompoundParameter wth = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness of the plane");
  
  public PlanePattern(LX lx) {
    super(lx);
    addParameter("axis", this.axis);
    addParameter("pos", this.pos);
    addParameter("width", this.wth);
  }
  
  public void run(double deltaMs) {
    float pos = this.pos.getValuef();
    float falloff = 100 / this.wth.getValuef();
    float n = 0;
    for (LXPoint p : model.points) {
      switch (this.axis.getEnum()) {
      case X: n = p.xn; break;
      case Y: n = p.yn; break;
      case Z: n = p.zn; break;
      }
      colors[p.index] = LXColor.gray(max(0, 100 - falloff*abs(n - pos))); 
    }
  }
}

@LXCategory("Glass")
public class GlassMap extends LXPattern {
  public final DiscreteParameter strip;
  
  public PImage glassImage;
  
  public GlassMap(LX lx) {
    super(lx);
    
    Storytime story = (Storytime)lx.model;
    strip = new DiscreteParameter("Strip", 0, story.lampshade.lampStrips.size())
              .setDescription("Position of the center of the plane");
              
    addParameter("strip", this.strip);
    
    glassImage = loadImage("/Users/anton/Projects/Storytime/Code/StorytimeLX/assets/Template.png");
    glassImage.resize(LONG_SIDE_LED_COUNT, 2 * story.lampshade.lampStrips.size());
  }
  
  public void run(double deltaMs) {
    Lampshade lampshade = ((Storytime)model).lampshade;
    
    //clearColors();
    for (int i = 0; i < lampshade.lampStrips.size(); i++) {
      LampStrip ls = lampshade.lampStrips.get(i);
      
      List<LXPoint> points = ls.getPoints();
      for (int j = 0; j < LONG_SIDE_LED_COUNT; j++) {
        colors[points.get(j).index] = glassImage.get(j,i*2);
      }
    }
  }
}

@LXCategory("Test")
public static class LampStripIterator extends LXPattern {
  public final DiscreteParameter strip;
  
  public LampStripIterator(LX lx) {
    super(lx);
    
    Storytime story = (Storytime)lx.model;
    strip = new DiscreteParameter("Strip", 0, story.lampshade.lampStrips.size())
              .setDescription("Position of the center of the plane");
              
    //LXParameterListener updateGamma = new LXParameterListener() {
    //  @Override
    //  public void onParameterChanged(LXParameter param) {
    //    updateLUT(param.getValuef());
    //  }
    //};
    
    //this.gamma.addListener(updateGamma);
              
    addParameter("strip", this.strip);
  }
  
  public void run(double deltaMs) {
    LampStrip s = ((Storytime)model).lampshade.lampStrips.get(strip.getValuei());
    
    clearColors();
    for (LXPoint p : s.getPoints()) {
      colors[p.index] = LXColor.gray(100);
    }
  }
}

// Effects

// Lampshade mask effect
public static class MaskEffect extends LXEffect {
  public enum CarParts { LAMP, POLE, BOOKS };
  public final EnumParameter<CarParts> part = new EnumParameter("Part", CarParts.LAMP);
  
  public MaskEffect(LX lx) {
    super(lx);
    addParameter(part);
  }
  
  public void run(double deltaMs, double amount) {
    Storytime model = ((Storytime)lx.model);
    
    
    if (part.getEnum() != CarParts.LAMP) {
      for (int i = 0; i < model.lampshade.points.length; i++) colors[model.lampshade.points[i].index] = 0;
    }
    
    if (part.getEnum() != CarParts.POLE) {
      for (int i = 0; i < model.pole.points.length; i++) colors[model.pole.points[i].index] = 0;
    }
    
    if (part.getEnum() != CarParts.BOOKS) {
      for (int i = 0; i < model.topBook.points.length; i++) colors[model.topBook.points[i].index] = 0;
      for (int i = 0; i < model.bottomBook.points.length; i++) colors[model.bottomBook.points[i].index] = 0;
    }
  }
}

// Gamma correction effect
// Shamelessly boosted and modified from the Tree of Tenere LXStudio output code
public static class GammaEffect extends LXEffect {
  public final CompoundParameter gamma = new CompoundParameter("Gamma", 1.8, 1, 4)
    .setDescription("Gamma");

  static final byte[][] GAMMA_LUT = new byte[256][256];
  private final LXParameter brightness; 

  public GammaEffect(LX lx) {
    super(lx);
    this.brightness = lx.engine.output.brightness;
    
    LXParameterListener updateGamma = new LXParameterListener() {
      @Override
      public void onParameterChanged(LXParameter param) {
        updateLUT(param.getValuef());
      }
    };
    
    this.gamma.addListener(updateGamma);
    updateLUT(gamma.getValuef());
    addParameter(gamma);
  }
  
  protected void updateLUT(float val) {
    for (int b = 0; b < 256; ++b) {
      for (int in = 0; in < 256; ++in) {
        GAMMA_LUT[b][in] = (byte) (0xff & (int) Math.round(Math.pow(in * b / 65025.f, val) * 255.f));
      }
    }
  }
  
  public void run(double deltaMs, double amount) {
    final byte[] gamma = GAMMA_LUT[Math.round(255 * this.brightness.getValuef())];
    
    for (int i = 0; i < colors.length; i++) {
      final int c = colors[i];
      
      colors[i] = LXColor.rgb(
        gamma[0xff & (c >> 16)],
        gamma[0xff & (c >> 8)],
        gamma[0xff & c]
      );
    }    
  }

}
