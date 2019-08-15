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

void setup() {
  // Processing setup, constructs the window and the LX instance
  size(800, 720, P3D);
  lx = new heronarts.lx.studio.LXStudio(this, buildModel(), MULTITHREADED);
  lx.ui.setResizable(RESIZABLE);
}

int[] getIndices(List<LXPoint> points) {
  int[] indices = new int[points.size()];
  for (int i = 0; i < points.size(); i++) {
    indices[i] = points.get(i).index;
  }
  
  return indices;
}

boolean addDatagram(LXDatagramOutput output, String ip, int universe, int[] indices) {
  try {
    ArtNetDatagram dg = new ArtNetDatagram(indices, universe);
    dg.setAddress(ip);
    dg.setByteOrder(LXDatagram.ByteOrder.RGB);  
    output.addDatagram(dg);
  } catch (Exception e) {
    return false;
  }
  
  return true;
}

boolean addDatagram(LXDatagramOutput output, String ip, int universe, List<LXPoint> points) {
  return addDatagram(output, ip, universe, getIndices(points));
}

void initialize(final heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) {
  final double MAX_BRIGHTNESS = 1.0;
  final String ARTNET_IP = "192.168.0.109";
  
  Storytime story = (Storytime)lx.model;

  try {
    int i = 0;
    // Construct a new DatagramOutput object
    LXDatagramOutput output = new LXDatagramOutput(lx);
      
    for (LampStrip strip : story.lampshade.lampStrips) {
      i++;
  
      // Add an ArtNetDatagram which sends all of the points in the strip
      println("Adding strip");
      println("Universe", i);
      println(getIndices(strip.getPoints()));
      println();
      
      addDatagram(output, ARTNET_IP, i, strip.getPoints());
    }
    
    // Add pole strips. The astute reader will notice we're using the iterator from
    // above---we assume that the pole strips will be just the next main controller
    // outputs after the lampshade.
    for (List<LXPoint> strip : story.pole.strips) {
      i++;
      
      addDatagram(output, ARTNET_IP, i, strip);
    }
    
    // Add books. These guys are on a remote controller; universes tbd but hopefully
    // sequential. That's what we'll do for now.
    addDatagram(output, ARTNET_IP, ++i, story.topBook.getPoints());
    addDatagram(output, ARTNET_IP, ++i, story.bottomBook.getPoints());
    
    output.brightness.setNormalized(MAX_BRIGHTNESS);
    
    // Add the datagram output to the LX engine
    //lx.addOutput(output);
  } catch (Exception x) {
    x.printStackTrace();
  }
}

void onUIReady(heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) {
  // Add custom UI components here
  ui.preview.pointCloud.setPointSize(10);
}

void draw() {
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
final static float CM = IN / 2.54;
final static float MM = CM * .1;
final static float M = CM * 100;
final static float METER = M;
