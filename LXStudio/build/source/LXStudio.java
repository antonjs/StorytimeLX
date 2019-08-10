import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import heronarts.lx.studio.*; 
import heronarts.lx.studio.ui.*; 
import heronarts.lx.studio.ui.browser.*; 
import heronarts.lx.studio.ui.clip.*; 
import heronarts.lx.studio.ui.device.*; 
import heronarts.lx.studio.ui.device.modulator.*; 
import heronarts.lx.studio.ui.global.*; 
import heronarts.lx.studio.ui.lfo.*; 
import heronarts.lx.studio.ui.midi.*; 
import heronarts.lx.studio.ui.mixer.*; 
import heronarts.lx.studio.ui.modulation.*; 
import heronarts.lx.studio.ui.osc.*; 
import heronarts.lx.studio.ui.toolbar.*; 
import heronarts.lx.*; 
import heronarts.lx.audio.*; 
import heronarts.lx.blend.*; 
import heronarts.lx.clip.*; 
import heronarts.lx.clipboard.*; 
import heronarts.lx.color.*; 
import heronarts.lx.effect.*; 
import heronarts.lx.midi.*; 
import heronarts.lx.midi.remote.*; 
import heronarts.lx.midi.surface.*; 
import heronarts.lx.model.*; 
import heronarts.lx.modulator.*; 
import heronarts.lx.osc.*; 
import heronarts.lx.output.*; 
import heronarts.lx.parameter.*; 
import heronarts.lx.pattern.*; 
import heronarts.lx.script.*; 
import heronarts.lx.transform.*; 
import heronarts.p3lx.*; 
import heronarts.p3lx.font.*; 
import heronarts.p3lx.pattern.*; 
import heronarts.p3lx.ui.*; 
import heronarts.p3lx.ui.component.*; 
import heronarts.p3lx.ui.control.*; 
import heronarts.p3lx.video.*; 
import uk.co.xfactorylibrarians.coremidi4j.*; 
import com.google.gson.*; 
import com.google.gson.annotations.*; 
import com.google.gson.internal.*; 
import com.google.gson.internal.bind.*; 
import com.google.gson.internal.bind.util.*; 
import com.google.gson.reflect.*; 
import com.google.gson.stream.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class LXStudio extends PApplet {

/** 
 * By using LX Studio, you agree to the terms of the LX Studio Software
 * License and Distribution Agreement, available at: http://lx.studio/license
 *
 * Please note that the LX license is not open-source. The license
 * allows for free, non-commercial use.
 *
 * HERON ARTS MAKES NO WARRANTY, EXPRESS, IMPLIED, STATUTORY, OR
 * OTHERWISE, AND SPECIFICALLY DISCLAIMS ANY WARRANTY OF
 * MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR A PARTICULAR
 * PURPOSE, WITH RESPECT TO THE SOFTWARE.
 */

// ---------------------------------------------------------------------------
//
// Welcome to LX Studio! Getting started is easy...
// 
// (1) Quickly scan this file
// (2) Look at "Model" to define your model
// (3) Move on to "Patterns" to write your animations
// 
// ---------------------------------------------------------------------------

// Reference to top-level LX instance
heronarts.lx.studio.LXStudio lx;

public void setup() {
  // Processing setup, constructs the window and the LX instance
  
  lx = new heronarts.lx.studio.LXStudio(this, buildModel(), MULTITHREADED);
  lx.ui.setResizable(RESIZABLE);
}

public void initialize(final heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) {
  // Add custom components or output drivers here
}

public void onUIReady(heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) {
  // Add custom UI components here
}

public void draw() {
  // All is handled by LX Studio
}

// Configuration flags
final static boolean MULTITHREADED = true;
final static boolean RESIZABLE = true;

// Helpful global constants
final static float INCHES = 1;
final static float IN = INCHES;
final static float FEET = 12 * INCHES;
final static float FT = FEET;
final static float CM = IN / 2.54f;
final static float MM = CM * .1f;
final static float M = CM * 100;
final static float METER = M;
public LXModel buildModel() {
  // A three-dimensional grid model
  return new GridModel3D();
}

public static class GridModel3D extends LXModel {
  
  public final static int SIZE = 20;
  public final static int SPACING = 10;
  
  public GridModel3D() {
    super(new Fixture());
  }
  
  public static class Fixture extends LXAbstractFixture {
    Fixture() {
      for (int z = 0; z < SIZE; ++z) {
        for (int y = 0; y < SIZE; ++y) {
          for (int x = 0; x < SIZE; ++x) {
            addPoint(new LXPoint(x*SPACING, y*SPACING, z*SPACING));
          }
        }
      }
    }
  }
}
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
  
  public final CompoundParameter wth = new CompoundParameter("Width", .4f, 0, 1)
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
// Particle (Point Light)
// - Position
// - Color
// - Falloff

@LXCategory("Form")
public static class PointLight extends LXPattern {
  public final CompoundParameter iPositionX = new CompoundParameter("X");
  public final CompoundParameter iPositionY = new CompoundParameter("Y");
  public final CompoundParameter iPositionZ = new CompoundParameter("Z");
  public final ColorParameter    iColor     = new ColorParameter("Color");
  public final CompoundParameter iFalloff   = new CompoundParameter("Falloff");

  public PointLight(LX lx) {
    super(lx);
    addParameter("X",       this.iPositionX);
    addParameter("Y",       this.iPositionY);
    addParameter("Z",       this.iPositionZ);
    addParameter("Color",   this.iColor);
    addParameter("Falloff", this.iFalloff);
  }

  // Time is in milliseconds
  public void run(double deltaTime) {
    for (LXPoint point : model.points) {
      colors[point.index] = LX.rgb(iColor.getColor());
    }

    // float pos = this.pos.getValuef();
    // float falloff = 100 / this.wth.getValuef();
    // float n = 0;
    // for (LXPoint p : model.points) {
    //   switch (this.axis.getEnum()) {
    //   case X: n = p.xn; break;
    //   case Y: n = p.yn; break;
    //   case Z: n = p.zn; break;
    //   }
    //   colors[p.index] = LXColor.gray(max(0, 100 - falloff*abs(n - pos)));
    // }
  }
}
  public void settings() {  size(800, 720, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "LXStudio" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
