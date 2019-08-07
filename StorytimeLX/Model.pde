import java.util.Collections;
import java.util.List;

LXModel buildModel() {
  // A three-dimensional grid model
  return new Storytime();
}

public final static float LEDS_PER_METER = 60;
public final static float LED_SPACING = 1 * M / LEDS_PER_METER;
public final static float SHORT_SIDE_LENGTH = 6 * IN;
public final static float LONG_SIDE_LENGTH = (5 * M - 12 * IN) / 2;
public final static float INTER_PANEL_SPACE = 0 * CM;
public final static float LED_INSET = 1.5 * IN;

public final static float POLE_HEIGHT = 8 * FT;
public final static float POLE_WIDTH = 6 * IN;


public static class Storytime extends LXModel {
  public final Lampshade lampshade;
  
  public Storytime() {
    super(new Fixture());
    
    Fixture f = (Fixture)this.fixtures.get(0);
    lampshade = f.lampshade;
  }
  
  public static class Fixture extends LXAbstractFixture {
    private final Lampshade lampshade;
    private final Pole pole;
    private final Book topBook;
    private final Book bottomBook;
    
    Fixture() {
      LXTransform origin = new LXTransform();
      
      lampshade = new Lampshade(origin);
      addPoints(lampshade);
      
      origin.push();
      origin.translate(4 * FT, 1 * FT, 26 * IN);
      pole = new Pole(origin);
      addPoints(pole);
      origin.pop();
      
      origin.push();
      origin.translate(-0.5 * FT, -1 * POLE_HEIGHT + 1 * FT + 1.5 * FT, 22 * IN);
      topBook = new Book(origin, 6 * FT, 9 * FT, 17 * IN);
      addPoints(topBook);
      origin.pop();
      
      origin.push();
      origin.translate(-1 * FT, -1 * POLE_HEIGHT + 1 * FT + 1.5 * FT * 2, 22 * IN);
      bottomBook = new Book(origin, 8 * FT, 10 * FT, 18.5 * IN);
      addPoints(bottomBook);
      origin.pop();
    }
  }
}

public static class Lampshade extends LXModel {
  public Lampshade(LXTransform t){
    super(new Fixture(t));
  }
  
  public Lampshade() {
    this(new LXTransform());
  }
  
  public static class Fixture extends LXAbstractFixture {
    private final ArrayList<LampStrip> lampStrips = new ArrayList<LampStrip>();

    Fixture(LXTransform t) {
      t.push();
      
      // Bottom panel is at 0 x -9 x +35 from circle origin
      t.push();
      t.translate(0, -9 * IN, -35 * IN);
      t.rotateX(radians(38.1)); // Bottom front edge
      t.translate(0, 6 * IN, 0);
      
      for (int i = 0; i < 5; i++) {
        addLampStrip(new LampStrip(t));
        t.translate(0, SHORT_SIDE_LENGTH + INTER_PANEL_SPACE, 0);
      }
      t.pop();
      
      // Now we align the next panels based on an arc centered on the origin with radius 22"      
      for (int i = 0; i < 10; i++) {
        t.push();
        t.rotateX(radians(55 + 14.233*i)); // was: 14*i
        t.translate(0,0,-22 * IN);
        addLampStrip(new LampStrip(t));
        t.pop();
      }
      
      // Finally we run out the last vertical panels
      t.push();
      t.translate(0, 0, 22 * IN);
      for (int i = 0; i < 2; i++) {
        addLampStrip(new LampStrip(t));
        t.translate(0, -1 * SHORT_SIDE_LENGTH, 0);
      }
      t.pop();
      
      t.pop();
    }
    
    private void addLampStrip(LampStrip strip) {
      lampStrips.add(strip);
      addPoints(strip);
    }
  }
}

public static class LampStrip extends LXModel {
  public LampStrip(LXTransform t){
    super(new Fixture(t));
  }
  
  public LampStrip() {
    this(new LXTransform());
  }
  
  public static class Fixture extends LXAbstractFixture {
    Fixture(LXTransform t) {
      int shortSideLEDCount = round(LEDS_PER_METER * SHORT_SIDE_LENGTH / M);
      int longSideLEDCount = round(LEDS_PER_METER * LONG_SIDE_LENGTH / M);
      
      System.out.println(LEDS_PER_METER);
      System.out.println(LONG_SIDE_LENGTH);
      System.out.println(longSideLEDCount);
      System.out.println(shortSideLEDCount);
      
      t.push();
      //addPoint(new LXPoint(t));
      
      //t.translate(LONG_SIDE_LENGTH,0,0);
      //addPoint(new LXPoint(t));
      
      //t.translate(0,-1 * SHORT_SIDE_LENGTH,0);
      //addPoint(new LXPoint(t));
      
      //t.translate(-1 * LONG_SIDE_LENGTH,0,0);
      //addPoint(new LXPoint(t));
      t.translate(LED_INSET, -1 * LED_INSET, 0);
      
      for (int i = 0; i < longSideLEDCount; i++) {
         t.translate((LONG_SIDE_LENGTH - 2 * LED_INSET) / longSideLEDCount, 0, 0);
         addPoint(new LXPoint(t));
      }
      
      for (int i = 0; i < shortSideLEDCount; i++) {
        t.translate(0, -1 * (SHORT_SIDE_LENGTH - 2 * LED_INSET) / shortSideLEDCount, 0);
        addPoint(new LXPoint(t));
      }
      
      for (int i = 0; i < longSideLEDCount; i++) {
        t.translate(-1 * (LONG_SIDE_LENGTH - 2 * LED_INSET) / longSideLEDCount, 0, 0);
        addPoint(new LXPoint(t));
      }
      
      for (int i = 0; i < shortSideLEDCount; i++) {
        t.translate(0, 1 * (SHORT_SIDE_LENGTH - 2 * LED_INSET) / shortSideLEDCount, 0);
        addPoint(new LXPoint(t));
      }
      
      t.pop();
    }
  }
}

public static class Pole extends LXModel {
  public Pole(LXTransform t){
    super(new Fixture(t));
  }
  
  public Pole() {
    this(new LXTransform());
  }
  
  public static class Fixture extends LXAbstractFixture {
    private final ArrayList<ArrayList<LXPoint>> strips = new ArrayList<ArrayList<LXPoint>>();

    Fixture(LXTransform t) {
      // Oriented from top center of pole
      t.push();
      
      final float locations[][] = {
        {POLE_WIDTH/2, 0, -1 * POLE_WIDTH / 2}, // Front inside
        {-1 * POLE_WIDTH/2, 0, -1 * POLE_WIDTH / 2}, // Back inside
        {POLE_WIDTH/2, 0, 1 * POLE_WIDTH / 2}, // Front outside
        {-1 * POLE_WIDTH/2, 0, 1 * POLE_WIDTH / 2} // Back outside
      };
      
      for (int i = 0; i < locations.length; i++) {
        ArrayList<LXPoint> strip = new ArrayList<LXPoint>();
        
        t.push();
        t.translate(locations[i][0], locations[i][1], locations[i][2]); // Front inside pole strip
        
        for (int j = 0; j < POLE_HEIGHT / M * LEDS_PER_METER; j++) {
          LXPoint p = new LXPoint(t);
          addPoint(p);
          strip.add(p);
          t.translate(0, -1 * LED_SPACING, 0);
        }
        
        strips.add(strip);
        t.pop();
      }
      
      t.pop();
    }
  }
}

public static class Book extends LXModel {
  public Book(LXTransform t, float w, float l, float h){
    super(new Fixture(t, w, l, h));
  }
  
  public Book() {
    this(new LXTransform(), 6 * FT, 10 * FT, 18 * IN);
  }
  
  public static class Fixture extends LXAbstractFixture {
    private final ArrayList<ArrayList<LXPoint>> strips = new ArrayList<ArrayList<LXPoint>>();

    Fixture(LXTransform t, float w, float l, float h) {
      // Oriented from top front left of book
      // Two strips, separated by some distance, wrapped around the book facing out
      
      t.push();
      
      for (int j = 0; j < 2; j++) {
        ArrayList<LXPoint> strip = new ArrayList<LXPoint>();

        t.push();
        for (int i = 0; i < w / M * LEDS_PER_METER; i++) {
            LXPoint p = new LXPoint(t);
            addPoint(p);
            strip.add(p);
            
            t.translate(0, 0, -1 * LED_SPACING);
            strips.add(strip);
        }
        
        strip = new ArrayList<LXPoint>();
        for (int i = 0; i < l / M * LEDS_PER_METER; i++) {
            LXPoint p = new LXPoint(t);
            addPoint(p);
            strip.add(p);
            
            t.translate(1 * LED_SPACING, 0, 0);
            strips.add(strip);
        }
        
        strip = new ArrayList<LXPoint>();
        for (int i = 0; i < w / M * LEDS_PER_METER; i++) {
            LXPoint p = new LXPoint(t);
            addPoint(p);
            strip.add(p);
            
            t.translate(0, 0, 1 * LED_SPACING);
            strips.add(strip);
        }
        
        strip = new ArrayList<LXPoint>();
        for (int i = 0; i < l / M * LEDS_PER_METER; i++) {
            LXPoint p = new LXPoint(t);
            addPoint(p);
            strip.add(p);
            
            t.translate(-1 * LED_SPACING, 0, 0);
            strips.add(strip);
        }
        t.pop();
        
        t.translate(0, -1 * h, 0);
      }
        
      t.pop();
    }
  }
}
