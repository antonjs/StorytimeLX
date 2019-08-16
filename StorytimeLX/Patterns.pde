import java.util.concurrent.ThreadLocalRandom;

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
    
    glassImage = loadImage("/Users/anton/Projects/Storytime/Code/StorytimeLX/assets/Test.png");
    glassImage.resize(LONG_SIDE_LED_COUNT + 1, 2 * story.lampshade.lampStrips.size());
  }
  
  public void run(double deltaMs) {
    Lampshade lampshade = ((Storytime)model).lampshade;
    
    //clearColors();
    for (int i = 0; i < lampshade.lampStrips.size(); i++) {
      LampStrip ls = lampshade.lampStrips.get(i);
      
      for (int j = 0; j < LONG_SIDE_LED_COUNT + 1; j++) {
        colors[j == 0 ? ls.left.get(ls.left.size()-1).index : ls.top.get(j-1).index] = glassImage.get(j,i*2);
        colors[j == 0 ? ls.right.get(ls.right.size()-1).index : ls.bottom.get(j-1).index] = glassImage.get(LONG_SIDE_LED_COUNT + 1 - j, i*2+1); // Bottom is indexed right-to-left
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

@LXCategory("Glass")
public static class VoronoiStainedGlass extends LXPattern {
  LXPoint[][] ledGrid;
  int[] colorPalette;
  boolean running;
  double[][] centers;
  double[][] directions;
  double timeToUpdate;
  int N;

  public enum Mode {
    Reflecting, Periodic; //, Wiggle;
  }
  
  public final BooleanParameter generate = new BooleanParameter("generate", false)
    .setDescription("Run a new Voronoi pattern");
  public final DiscreteParameter numCentroids = new DiscreteParameter("numCentroids", 1, 10)
     .setDescription("Number of centroids in tessellation");
  public final CompoundParameter speed = new CompoundParameter("speed", 0, 30)
     .setDescription("Movement speed");
  public final CompoundParameter pos = new CompoundParameter("pos", 0, 1)
     .setDescription("Centroid position while wiggling");
  public final EnumParameter<Mode> mode =
    new EnumParameter<Mode>("Mode", Mode.Reflecting)
    .setDescription("Boundary condition mode");
  public final DiscreteParameter paletteNum = new DiscreteParameter("paletteNum", 1, 3)
     .setDescription("Color palette number");
    
  private void setupLEDGrid() {
    Storytime storytime = (Storytime)model;
    Lampshade lampshade = storytime.lampshade;
    int numLampStrips = lampshade.lampStrips.size();
    ledGrid = new LXPoint[numLampStrips*2][LONG_SIDE_LED_COUNT-1];
    for (int i = 0; i < numLampStrips; i++) { 
      LampStrip s = lampshade.lampStrips.get(i);
      int k1 = 0;
      int k2 = 0;
      for(int j = 0; j < s.points.length; j++) {
        if (j < LONG_SIDE_LED_COUNT-1) {
          // ledGrid[2*numLampStrips - (2*i+1) - 1][LONG_SIDE_LED_COUNT-2-k1] = s.points[j];
          ledGrid[2*i][k1] = s.points[j];
          k1++;
        } else if (j >= LONG_SIDE_LED_COUNT + SHORT_SIDE_LED_COUNT && j < SHORT_SIDE_LED_COUNT + (LONG_SIDE_LED_COUNT)*2-1) {
          // ledGrid[2*numLampStrips - (2*i) - 1][k2] = s.points[j];
          ledGrid[(2*i+1)][LONG_SIDE_LED_COUNT-k2-2] = s.points[j];
          k2++;
        }
        
      }
    }
  }
  
 private void setColorPalette() {
     colorPalette = new int[10];
     if(this.paletteNum.getValuei() == 1) {
       for(int i = 0; i < 10; i++) {
          colorPalette[i] = LXColor.gray(10+(float)100/9*i); 
       }
     } else if (this.paletteNum.getValuei() == 2) {
       colorPalette[0] = LXColor.rgb(226,246,250);
       colorPalette[1] = LXColor.rgb(92,  206,  249  );
       colorPalette[2] = LXColor.rgb(68,  159,  217  );
       colorPalette[3] = LXColor.rgb(41,  24,  30);  
       colorPalette[4] = LXColor.rgb(88,  48,  85  );
       colorPalette[5] =LXColor.rgb(189,  101,  183); 
       colorPalette[6] =LXColor.rgb(238,  123,  186 );
       colorPalette[7] =LXColor.rgb(177,  147,  139  );
       colorPalette[8] =LXColor.rgb(245,  198,  187  );
       colorPalette[9] = LXColor.rgb(252,  236,  214  );
     }
  }
  
  private void shuffleColors() {
     int[] tempColorPalette = colorPalette.clone();
     ArrayList<Integer> inds = new ArrayList<Integer>();
     for(int i = 0; i < 10; i++)
       inds.add(i);
     java.util.Collections.shuffle(inds);
     for(int i = 0; i < 10; i++) {
        colorPalette[i] = tempColorPalette[inds.get(i)];
     }
  }
  public VoronoiStainedGlass(LX lx) {
    super(lx);
    setupLEDGrid(); // setup ledGrid
    setColorPalette();
    this.generate.setMode(BooleanParameter.Mode.TOGGLE);
    addParameter("generate", this.generate);
    addParameter("numCentroids", this.numCentroids);
    addParameter("speed", this.speed);
    addParameter("mode", this.mode);
    addParameter("paletteNum", this.paletteNum);
    running = true;
    makePattern();
    running = false;
    N = 1;
  }
  private int argmin(double[] arr) {
     double minVal = arr[0];
     int minInd = 0;
     for(int i = 1; i < arr.length; i++) {
        if(arr[i] < minVal) {
          minInd = i;
          minVal = arr[i];
        }
     }
     return minInd;
  }
  
  private void makePattern() {
    //---- Generate a new pattern
    // Pick random centers
    N = this.numCentroids.getValuei();
    System.out.printf("Generating %d new centers\n",N);
    centers = new double[N][2];
    directions = new double[N][2];
    for(int n = 0; n < N; n++) {
       centers[n][0] = ThreadLocalRandom.current().nextInt(0, ledGrid[0].length); // first coordinate = x
       centers[n][1] = ThreadLocalRandom.current().nextInt(0, ledGrid.length); // second coordinate = y
       
       directions[n][0] = ThreadLocalRandom.current().nextDouble(-0.1, 0.1); // first coordinate = x
       directions[n][1] = ThreadLocalRandom.current().nextDouble(-0.1, 0.1); // second coordinate = y
       
       // System.out.printf("%d, %d\n", centers[n][0], centers[n][1]);
    }
    // Reshuffle colors
    setColorPalette();
    shuffleColors();
    // Assign groups
    for(int i = 0; i < ledGrid.length; i++) {
      for(int j = 0; j < ledGrid[i].length; j++) {
          double[] distances = new double[N];
          for(int n = 0; n < N; n++) {
              distances[n] = Math.pow((float)(j-centers[n][0])/ledGrid[0].length,2) + Math.pow((float)(i-centers[n][1])/ledGrid.length,2);
          }
          colors[ledGrid[i][j].index] = colorPalette[argmin(distances)];
      }
    }
  }
  private void updatePattern() {
    // Move centers
    for(int n = 0; n < N; n++) {
       centers[n][0] = centers[n][0] + directions[n][0];
       centers[n][1] = centers[n][1] + directions[n][1];
       if(this.mode.getEnum() == Mode.Reflecting) {
         if (centers[n][0] >= ledGrid[0].length-1) {
           directions[n][0] = -directions[n][0];
           centers[n][0] = ledGrid[0].length-1;
         }
         if (centers[n][0] <= 0) {
           directions[n][0] = -directions[n][0];
           centers[n][0] = 0;
         }
         if (centers[n][1] >= ledGrid.length-1) {
           directions[n][1] = -directions[n][1];
           centers[n][1] = ledGrid.length-1;
         }
         if (centers[n][1] <= 0) {
           directions[n][1] = -directions[n][1];
           centers[n][1] = 0;
         }
       } else if(this.mode.getEnum() == Mode.Periodic) {
         if (centers[n][0] >= ledGrid[0].length-1) {
           centers[n][0] = 0;
         }
         if (centers[n][0] <= 0) {
           centers[n][0] = ledGrid[0].length-1;
         }
         if (centers[n][1] >= ledGrid.length-1) {
           centers[n][1] = 0;
         }
         if (centers[n][1] <= 0) {
           centers[n][1] = ledGrid.length-1;
         }
       }
       // else if(this.mode.getEnum() == Mode.Wiggle) {
         
       //}
    }
    
    // Recalculate pattern
    for(int i = 0; i < ledGrid.length; i++) {
      for(int j = 0; j < ledGrid[i].length; j++) {
          double[] distances = new double[N];
          for(int n = 0; n < N; n++) {
              distances[n] = Math.pow((float)(j-centers[n][0])/ledGrid[0].length,2) + Math.pow((float)(i-centers[n][1])/ledGrid.length,2);
          }
          colors[ledGrid[i][j].index] = colorPalette[argmin(distances)];
      }
    }
  }
  
  public void run (double deltaMs) {
    if(!this.generate.getValueb() && running) {
      running = false;
      return;
    }
    if(this.generate.getValueb()) {
      if(!running) {
        running = true;
        makePattern();
      }
      timeToUpdate += deltaMs;
      if (timeToUpdate >= 1000/this.speed.getValuef()) {
        timeToUpdate = 0;
      } else {
        return;
      }
      updatePattern();
    }
  }
}

@LXCategory("Glass")
public static class PremadeStainedGlassPattern extends LXPattern {
  LXPoint[][] ledGrid;
  int lastImageNum;
  int numLampStrips;
  public final DiscreteParameter imageNum = new DiscreteParameter("imageNum", 0, 2)
     .setDescription("Image number");
     
  public PremadeStainedGlassPattern(LX lx) {
    super(lx);
    // Setup LED grid
    Storytime storytime = (Storytime)model;
    Lampshade lampshade = storytime.lampshade;
    numLampStrips = lampshade.lampStrips.size();
    ledGrid = new LXPoint[numLampStrips*2][LONG_SIDE_LED_COUNT-1];
    for (int i = 0; i < numLampStrips; i++) { 
      LampStrip s = lampshade.lampStrips.get(i);
      int k1 = 0;
      int k2 = 0;
      for(int j = 0; j < s.points.length; j++) {
        if (j < LONG_SIDE_LED_COUNT-1) {
          ledGrid[2*i][k1] = s.points[j];
          k1++;
        } else if (j >= LONG_SIDE_LED_COUNT + SHORT_SIDE_LED_COUNT && j < SHORT_SIDE_LED_COUNT + (LONG_SIDE_LED_COUNT)*2-1) {
          ledGrid[(2*i+1)][LONG_SIDE_LED_COUNT-k2-2] = s.points[j];
          k2++;
        }
        
      }
    }
    
    lastImageNum = 0;
    setImage(lastImageNum);
    addParameter("imageNum", this.imageNum);
  }
  
  public void setImage(int num) {
    int rowSkip = (int)Math.floor((float)stainedGlass[num].height/(2*numLampStrips));
    System.out.printf("rowSkip: %d\n", rowSkip);
    for (int i = 0; i < ledGrid.length; i++) { 
      for(int j = 0; j < ledGrid[i].length; j++) {
        colors[ledGrid[i][j].index] = stainedGlass[num].get(j, i*rowSkip); // (2*numLampStrips - i)*rowSkip); // LXColor.gray(0);
      }
    }
  }
  public void run(double deltaMs) {
    if(lastImageNum != this.imageNum.getValuei()) {
      lastImageNum = this.imageNum.getValuei();
      setImage(lastImageNum);
    }
  }
}

@LXCategory("Effects")
public static class ZigZagPattern extends LXPattern {
  LXPoint[][] ledGrid;
  int lampGreen = LXColor.rgb(142, 211, 129);
  // double speed = 2; // refresh rate in Hz
  double ref; //// refresh time in ms
  double timeToUpdate;
  int lastUpdatedInd1;
  int lastUpdatedInd2;
  int direction;
  int lastMode;
  
  int[] lastUpdatedInd_mode2; 
  
  public final CompoundParameter speed = new CompoundParameter("Speed", 1, 30)
    .setDescription("Speed to update pattern");
  public final DiscreteParameter mode = new DiscreteParameter("Mode", 0, 3)
    .setDescription("Pattern mode");
  public final CompoundParameter pos1 = new CompoundParameter("Pos1", 0, 1).setDescription("Position of bar in top row");
  public final CompoundParameter pos2 = new CompoundParameter("Pos2", 0, 1).setDescription("Position of bar in bottom row");

  private void setupLEDGrid() {
      Storytime storytime = (Storytime)model;
      Lampshade lampshade = storytime.lampshade;
      int numLampStrips = lampshade.lampStrips.size();
      ledGrid = new LXPoint[numLampStrips*2][LONG_SIDE_LED_COUNT-1];
      for (int i = 0; i < numLampStrips; i++) { 
        LampStrip s = lampshade.lampStrips.get(i);
        int k1 = 0;
        int k2 = 0;
        for(int j = 0; j < s.points.length; j++) {
          if (j < LONG_SIDE_LED_COUNT-1) {
            // ledGrid[2*numLampStrips - (2*i+1) - 1][LONG_SIDE_LED_COUNT-2-k1] = s.points[j];
            ledGrid[2*i][k1] = s.points[j];
            k1++;
          } else if (j >= LONG_SIDE_LED_COUNT + SHORT_SIDE_LED_COUNT && j < SHORT_SIDE_LED_COUNT + (LONG_SIDE_LED_COUNT)*2-1) {
            // ledGrid[2*numLampStrips - (2*i) - 1][k2] = s.points[j];
            ledGrid[(2*i+1)][k2] = s.points[j];
            k2++;
          }
          
        }
     }
  }
  public ZigZagPattern(LX lx) {
    super(lx);
    // Load lamp grid
    setupLEDGrid();
    timeToUpdate = 0;
    lastUpdatedInd1 = lastUpdatedInd2 = -1;
    direction = 1;
    lastMode = 1;
    
    
    addParameter("pos1", this.pos1);
    addParameter("pos2", this.pos2);
    // addParameter("speed", this.speed);
    addParameter("mode", this.mode);
  }
  void reset() {
    lastUpdatedInd_mode2 = new int[ledGrid.length*2];
    for(int i = 0; i < ledGrid.length; i++) {
      lastUpdatedInd_mode2[(int)(i/2)] = (int)(i/2)*8;
      lastUpdatedInd_mode2[(int)(i/2+1)] = (int)(i/2)*8;
      for(int j = 0; j < ledGrid[i].length; j++) {
         colors[ledGrid[i][j].index] = LXColor.gray(0); 
      }
    }
    lastUpdatedInd1 = lastUpdatedInd2 = -1;
    direction = 1;
    
    
  }
  
  void mode1(float posToUpdate1, float posToUpdate2) {
    int indToUpdate1 = (int)(Math.floor(139*posToUpdate1));
    int indToUpdate2 = (int)(Math.floor(139*posToUpdate2));
    if(indToUpdate1 != lastUpdatedInd1) {
      for(int i = 0; i < ledGrid.length; i+=2) {
         colors[ledGrid[i][indToUpdate1].index] = (colors[ledGrid[i][indToUpdate1].index]==LXColor.gray(100)) ? LXColor.gray(0) : LXColor.gray(100);
      }
      lastUpdatedInd1 = indToUpdate1; 
    }
    if(indToUpdate2 != lastUpdatedInd2) {
      for(int i = 1; i < ledGrid.length; i+=2) {
         colors[ledGrid[i][indToUpdate2].index] = (colors[ledGrid[i][indToUpdate2].index]==LXColor.gray(100)) ? LXColor.gray(0) : LXColor.gray(100);
      }
      lastUpdatedInd2 = indToUpdate2; 
    }
  }
  
  public void run(double deltaMs) {
    if (this.mode.getValuei() != lastMode) {
      lastMode = this.mode.getValuei();
      reset();
    }
    mode1(this.pos1.getValuef(), this.pos2.getValuef());
  }
  
}
