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

@LXCategory("Form")
public static class VoronoiStainedGlass extends LXPattern {
  LXPoint[][] ledGrid;
  int[] colorPalette;
  boolean running;
  int[][] centers;
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
    Lampshade.Fixture f = (Lampshade.Fixture)lampshade.fixtures.get(0);
    ledGrid = new LXPoint[f.lampStrips.size()*2][140];
    for (int i = 0; i < f.lampStrips.size(); i++) { 
      LampStrip s = f.lampStrips.get(i);
      int k1 = 0;
      int k2 = 0;
      for(int j = 0; j < s.points.length; j++) {
        if (j < 140) {
          ledGrid[2*i][k1] = s.points[j];
          k1++;
        } else if (j >= 150 && j < 290) {
          ledGrid[2*i+1][139-k2] = s.points[j];
          k2++;
        }
      }
    }
  }
  
 private void setColorPalette() {
     colorPalette = new int[10];
     if(this.paletteNum.getValuei() == 1) {
       for(int i = 0; i < 10; i++) {
          colorPalette[i] = LXColor.gray(10*i); 
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
     // System.out.println(colorPalette[0]);
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
    centers = new int[N][2];
    directions = new double[N][2];
    for(int n = 0; n < N; n++) {
       centers[n][0] = ThreadLocalRandom.current().nextInt(0, ledGrid[0].length); // first coordinate = x
       centers[n][1] = ThreadLocalRandom.current().nextInt(0, ledGrid.length); // second coordinate = y
       
       directions[n][0] = ThreadLocalRandom.current().nextDouble(-1, 1); // first coordinate = x
       directions[n][1] = ThreadLocalRandom.current().nextDouble(-0.5, 0.5); // second coordinate = y
       
       // System.out.printf("%d, %d\n", centers[n][0], centers[n][1]);
    }
    // Reshuffle colors
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
       centers[n][0] = (int)Math.round(centers[n][0] + directions[n][0]);
       centers[n][1] = (int)Math.round(centers[n][1] + directions[n][1]);
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

@LXCategory("Form")
public static class PremadeStainedGlassPattern extends LXPattern {
  LXPoint[][] ledGrid;
  int lastImageNum;
  
  public final DiscreteParameter imageNum = new DiscreteParameter("imageNum", 0, 2)
     .setDescription("Image number");
     
  public PremadeStainedGlassPattern(LX lx) {
    super(lx);
    // Setup LED grid
    Storytime storytime = (Storytime)model;
    Lampshade lampshade = storytime.lampshade;
    Lampshade.Fixture f = (Lampshade.Fixture)lampshade.fixtures.get(0);
    ledGrid = new LXPoint[f.lampStrips.size()*2][140];
    
    
    for (int i = 0; i < f.lampStrips.size(); i++) { 
      LampStrip s = f.lampStrips.get(i);
      int k1 = 0;
      int k2 = 0;
      for(int j = 0; j < s.points.length; j++) {
        if (j < 140) {
          ledGrid[2*i+1][k1] = s.points[j];
          
          k1++;
        } else if (j >= 150 && j < 290) {
          ledGrid[2*i][139-k2] = s.points[j];
          
          k2++;
        }
        
      }
    }
    lastImageNum = 0;
    setImage(lastImageNum);
    addParameter("imageNum", this.imageNum);
  }
  
  public void setImage(int num) {
    int rowSkip = (int)Math.floor((float)stainedGlass[num].height/(17*2));
    for (int i = 0; i < ledGrid.length; i++) { 
      for(int j = 0; j < ledGrid[i].length; j++) {
        colors[ledGrid[i][j].index] = stainedGlass[num].get(j, (33 - i)*rowSkip); // LXColor.gray(0);
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

@LXCategory("Form")
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

  public ZigZagPattern(LX lx) {
    super(lx);
    // Load lamp grid
    Storytime storytime = (Storytime)model;
    Lampshade lampshade = storytime.lampshade;
    Lampshade.Fixture f = (Lampshade.Fixture)lampshade.fixtures.get(0);
    ledGrid = new LXPoint[f.lampStrips.size()*2][140];
    lastUpdatedInd_mode2 = new int[ledGrid.length*2];
    for (int i = 0; i < f.lampStrips.size(); i++) { 
      LampStrip s = f.lampStrips.get(i);
      int k1 = 0;
      int k2 = 0;
      lastUpdatedInd_mode2[2*i] = i*8;
      lastUpdatedInd_mode2[2*i+1] = i*8;
      for(int j = 0; j < s.points.length; j++) {
        if (j < 140) {
          ledGrid[2*i][k1] = s.points[j];
          k1++;
        } else if (j >= 150 && j < 290) {
          ledGrid[2*i+1][k2] = s.points[j];
          k2++;
        }
        colors[s.points[j].index] = LXColor.gray(0);
      }
    }
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
  
  void mode2() {
    int nextInd;
    for(int i = 0; i < ledGrid.length; i++) {
      nextInd = (lastUpdatedInd_mode2[i]+1) % ledGrid[i].length;
      if(colors[ledGrid[i][nextInd].index] == LXColor.gray(0))
        colors[ledGrid[i][nextInd].index] = lampGreen;
      else
        colors[ledGrid[i][nextInd].index] = LXColor.gray(0);
      lastUpdatedInd_mode2[i] = nextInd;
    }
  }
  
  public void run(double deltaMs) {
    //timeToUpdate += deltaMs;
    //if (timeToUpdate >= 1000/this.speed.getValuef()) {
    //  timeToUpdate = 0;
    //} else {
    //  return;
    //}
    
    if (this.mode.getValuei() != lastMode) {
      lastMode = this.mode.getValuei();
      reset();
    }
    switch(this.mode.getValuei()) {
      case 1:
        mode1(this.pos1.getValuef(), this.pos2.getValuef());
        break;
      case 2:
        mode2();
        break;
    }
  }
  
}


@LXCategory("Form")
public static class TestPattern extends LXPattern {
  
  public double timeRun;
  public double[] lastColors;
  public int lastPos;
  public double d = 0.5; 
  public double attenuate = 0.1; 
  
  //public enum Axis {
  //  X, Y, Z
  //};
  public enum Mode {
      on, off
  };
  
  public final EnumParameter<Mode> mode =
    new EnumParameter<Mode>("Mode", Mode.off)
    .setDescription("Whether animation is running or not.");
    
  public final BooleanParameter pulse = new BooleanParameter("Pulse", false)
    .setDescription("Trigger an impulse");
  
  public final DiscreteParameter pos = new DiscreteParameter("Pos", 1, 17)
    .setDescription("Position of the center of the plane");
  // public final CompoundParameter pos = new CompoundParameter("Pos", 0, 1)
  //    .setDescription("Light-bar index for pattern");
  
  public final CompoundParameter wth = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness of the plane");
    
  public final CompoundParameter speed = new CompoundParameter("Speed", 0, 1)
    .setDescription("Speed to update pattern");
    
  public final CompoundParameter attenRate = new CompoundParameter("Attenuation Rate", 0, 1)
    .setDescription("Speed to attenuate diffusion");
  
  public TestPattern(LX lx) {
    super(lx);
    // addParameter("mode", this.mode);
    pulse.setMode(BooleanParameter.Mode.MOMENTARY);
    addParameter("pos", this.pos);
    // addParameter("width", this.wth);
    addParameter("pulse", this.pulse);
    // addParameter("speed", this.speed);
    // addParameter("attenRate", this.attenRate);
    timeRun = 0;
    lastColors = new double[300];
    lastPos = 1;
  }
  
  public void updateColors() {
    int pos = this.pos.getValuei();
    double[] brightnesses = new double[300];
    if (pos != lastPos) {
      lastPos = pos;
      lastColors = new double[300];
    }
    
    Storytime storytime = (Storytime)model;
    Lampshade lampshade = storytime.lampshade;
    Lampshade.Fixture f = (Lampshade.Fixture)lampshade.fixtures.get(0);
    for (int i = 0; i < f.lampStrips.size(); i++) { 
      LampStrip s = f.lampStrips.get(i);
      if (i != pos-1)
         for(LXPoint p : s.points)
           colors[p.index] = LXColor.gray(0);
      else {
        if(this.pulse.getValueb()) {
          lastColors[70] = 1;
          colors[s.points[70].index] = LXColor.gray(0);
          lastColors[220] = 1;
          colors[s.points[220].index] = LXColor.gray(0);
        }
        // System.out.println(brightnesses[70]);
        for(int j = 0; j < s.points.length; j++) {
          LXPoint p = s.points[j];
          if ((j < 140) || (j >= 150 && j < 290)) {
              
              double leftVal, rightVal;
              if(j < 140) { 
                leftVal = (j > 0) ? lastColors[j-1] : 0;
                rightVal = (j < 139) ? lastColors[j+1] : 0;
              }
              else {
                leftVal = (j > 150) ? lastColors[j-1] : 0;
                rightVal = (j < 289) ? lastColors[j+1] : 0;
              }
              brightnesses[j] = Math.min(1, Math.max(0, attenuate*lastColors[j] + d*(leftVal - 2*lastColors[j] + rightVal)));
              colors[p.index] = LXColor.gray(brightnesses[j]*100);
              // if (j == 70)
                // System.out.println(colors[p.index]);
          } else
              colors[p.index] = LXColor.gray(0);
        }
        lastColors = brightnesses;
        // System.out.println(colors[s.points[69].index]);
      }
    }
  }
  
  public void run(double deltaMs) {
    // float falloff = 100 / this.wth.getValuef();
    // float n = 0;
    if(this.pulse.getValueb()) {
      updateColors();
    }
    timeRun += deltaMs;
    if(timeRun >= 5 && !this.pulse.getValueb()) {
      timeRun = 0;
      updateColors();
    }
    
  }
}
