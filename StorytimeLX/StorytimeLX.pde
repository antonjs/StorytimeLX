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
static PImage[] stainedGlass;

void setup() {
  // Processing setup, constructs the window and the LX instance
  size(800, 720, P3D);
  lx = new heronarts.lx.studio.LXStudio(this, buildModel(), MULTITHREADED);
  lx.ui.setResizable(RESIZABLE);
  stainedGlass = new PImage[5];
  stainedGlass[0] = loadImage(dataPath("").concat("/stained-glass-history.jpg")); 
  stainedGlass[1] = loadImage(dataPath("").concat("/stained-glass-test-close.jpg"));
  stainedGlass[2] = loadImage(dataPath("").concat("/Colors.png")); 
  stainedGlass[3] = loadImage(dataPath("").concat("/Colors-flip.png")); 
  stainedGlass[4] = loadImage(dataPath("").concat("/IDs.png")); 

  
  if (lx.getProject() == null) {
    System.out.println("Loading the Default project");
    lx.openProject(this.saveFile("Default.lxp"));
  }
}

int[] getIndices(List<LXPoint> points) {
  int[] indices = new int[points.size()];
  for (int i = 0; i < points.size(); i++) {
    indices[i] = points.get(i).index;
  }
    
  return indices;
}

//boolean addDatagram(LXDatagramOutput output, String ip, int universe, int[] indices) {
//  try {
//    int[] first300 = new int[300];
//    for (int i = 0; i < 300; i++) first300[i] = indices[i];
//    ArtNetDatagram dg = new ArtNetDatagram(first300, universe);
//    dg.setAddress(ip);
//    dg.setByteOrder(LXDatagram.ByteOrder.RGB);  
//    output.addDatagram(dg);
//  } catch (Exception e) {
//    return false;
//  }
  
//  return true;
//}

int addDatagram(LXDatagramOutput output, String ip, int startUniverse, List<LXPoint> points) {
  int i = 0;
  try {
    for (i = 0; i < points.size() / 100; i++) {
      int universe = startUniverse + i;
      int startPoint = i * 100;
      int endPoint = min(i * 100 + 100, points.size());
      
      ArtNetDatagram dg = new ArtNetDatagram(getIndices(points.subList(startPoint, endPoint)), universe);
      dg.setAddress(ip);
      dg.setByteOrder(LXDatagram.ByteOrder.RGB);
      output.addDatagram(dg);
      
      println("Adding universe ", universe, " with points ", startPoint, "-", endPoint);
    }
  } catch (Exception e) {
    println(e);
    return 0;
  }
  
  return i;
}


//boolean addDatagram(LXDatagramOutput output, String ip, int universe, List<LXPoint> points) {
//  return addDatagram(output, ip, universe, getIndices(points));
//}

void initialize(final heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) {
  final double MAX_BRIGHTNESS = 0.5;
  final String ARTNET_IP = "192.168.0.100
  ";
  //final String ARTNET_IP = "127.0.0.1";
  //final int UNIVERSE_OFFSET = 3;
  
  Storytime story = (Storytime)lx.model;

  try {
    int i = 0;
    int universe = 1;
    // Construct a new DatagramOutput object
    LXDatagramOutput output = new LXDatagramOutput(lx);
      
    for (LampStrip strip : story.lampshade.lampStrips) {
      i++;
  
      // Add an ArtNetDatagram which sends all of the points in the strip
      println("Adding strip: ", i, " -> ", i);
      
      universe += addDatagram(output, ARTNET_IP, i * 3 - 2, strip.getPoints());
    }
    
    // Add pole strips. The astute reader will notice we're using the iterator from
    // above---we assume that the pole strips will be just the next main controller
    // outputs after the lampshade.
    //
    // Pole is on universes 18 and 19
    for (List<LXPoint> strip : story.pole.strips) {
      i++;
      
      println("Adding pole: ", i, " -> ", i);
      universe += addDatagram(output, ARTNET_IP, i * 3 - 2, strip);
    }
    
    // Add books. These guys are on a remote controller.
    //
    // Top Book:
    //   Top Strip: Port 20, Universe 58, 429 pixels.
    //   Bottom Strip: Port 21, Universe 63, 429 pixels.
    //
    // Bottom Book:
    //   Top strip: Port 22, Universe 68, 539 pixels
    //   Bottom strip: Port 23, Universe 74, 539 pixels
    
    i = 20; // Start book universes at 20 
    universe = 58;
    for (List<LXPoint> strip : story.topBook.strips) {
      println("Adding top book: ", i);
      universe += addDatagram(output, ARTNET_IP, universe, strip);
      i++;
    }
    
    for (List<LXPoint> strip : story.bottomBook.strips) {
      println("Adding bottom book: ", i);
      universe += addDatagram(output, ARTNET_IP, universe, strip);
      i++;
    }
    
    output.brightness.setNormalized(MAX_BRIGHTNESS);
    
    // Add the datagram output to the LX engine
    lx.addOutput(output);
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
