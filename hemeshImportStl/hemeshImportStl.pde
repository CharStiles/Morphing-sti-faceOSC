import processing.pdf.*;

//Charlotte Stiles
//Thank you Matthew Plummer-Fernandez for the code to import stl to hemesh using toxiclibs http://www.plummerfernandez.com/
//bend and noise code from Hemesh library http://hemesh.wblut.com/
//head is from scotta3d on thingsverse http://www.thingiverse.com/thing:24335
//the head is a model from Memory by Daniel Chester French, it is found in the Metropolitan

import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.*;
import wblut.hemesh.*;
import wblut.geom.*;


// Toxiclibs for the import stl and save color stl

import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import toxi.processing.*;


import oscP5.*;

OscP5 oscP5;
//pshape is for importing my stl
PShape s;
int shouldRecord=0;
boolean once;//for choosing head when face disappears
PVector posePosition;
boolean found;
boolean record;
float eyeLeftHeight;
float eyeRightHeight;
float mouthHeight;
float mouthWidth;
float leftEyebrowHeight;
float rightEyebrowHeight;

float MN; //eyebrow to eye
 
float poseScale;

int head;
//
//String stlFilename = head + ".stl";

//this is for noise and everything else vv
HE_Mesh mesh, copymesh;
WB_Render render;

//this is for bend vv
WB_Plane P;
WB_Line L;
HEM_Bend bendModifier;
WB_GeometryFactory gf=WB_GeometryFactory.instance();



void setup() {
  //frameRate(10);
  size(800, 800, P3D);

  
  head= int(random(1,13));

  String stlFilename = head + ".stl";
  record=false;
  once = false;
  createMesh();
 // head = int(random(13));
  
  HEM_Noise modifier=new HEM_Noise();
  modifier.setDistance(20);
  copymesh.modify(modifier);
  //for noise^^
  
  bendModifier=new HEM_Bend();
  
  P=new WB_Plane(0,0,-200,0,0,1); 
  bendModifier.setGroundPlane(P);// Ground plane of bend modifier 
  //you can also pass directly as origin and normal:  modifier.setGroundPlane(0,0,-200,0,0,1)
 
  L=new WB_Line(0,0,-200,-1,0,-200);
  bendModifier.setBendAxis(L);// Bending axis
  //you can also pass the line as two points:  modifier.setBendAxis(0,0,-200,1,0,-200)
  
  bendModifier.setAngleFactor(30.0/400);// Angle per unit distance (in degrees) to the ground plane
  // points which are a distance d from the ground plane are rotated around the
  // bend axis by an angle d*angleFactor;
 
  bendModifier.setPosOnly(false);// apply modifier only on positive side of the ground plane?
  
  mesh.modify(bendModifier);
  
  
  render=new WB_Render(this);
  
    oscP5 = new OscP5(this, 8338);
  oscP5.plug(this, "mouthWidthReceived", "/gesture/mouth/width");
  oscP5.plug(this, "mouthHeightReceived", "/gesture/mouth/height");
  oscP5.plug(this, "eyebrowLeftReceived", "/gesture/eyebrow/left");
  oscP5.plug(this, "eyebrowRightReceived", "/gesture/eyebrow/right");
  oscP5.plug(this, "eyeLeftReceived", "/gesture/eye/left");
  oscP5.plug(this, "eyeRightReceived", "/gesture/eye/right");
  oscP5.plug(this, "jawReceived", "/gesture/jaw");
  oscP5.plug(this, "nostrilsReceived", "/gesture/nostrils");
  oscP5.plug(this, "found", "/found");
  oscP5.plug(this, "poseOrientation", "/pose/orientation");
  oscP5.plug(this, "posePosition", "/pose/position");
  oscP5.plug(this, "poseScale", "/pose/scale");
  
}

void draw() {
  background(230);
  directionalLight(255, 255, 255, 1, 1, -1);
  directionalLight(127, 127, 127, -1, -1, 1);
  
  if (found) {
    if (once== true){
    createMesh();
    once=false;
    }
    translate(posePosition.x, posePosition.y+300);
    scale(poseScale*2);
    shouldRecord=-1;
    
  }
  else{
    if (shouldRecord== 0){
    record = true;
  }else{record=false;}
    
    once= true;
    translate(width/2, height/2+200);
    scale(8);
    
    
  }
  
 //if (record == true){
 //beginRaw(PDF, "frame-####.pdf");
 //}
 
  rotateY(400*1.0/width*TWO_PI);
  rotateX(200*1.0/height*TWO_PI);
  
   HEM_Noise modifier=new HEM_Noise();
  copymesh=mesh.get();
  
  MN = rightEyebrowHeight - eyeRightHeight - 4;
// println(MN);

if (MN < 0) MN=0; //eyebrow eye ratio
 
  modifier.setDistance(MN/2);
  copymesh.modify(modifier);
  
 float heightWidthRatio=mouthHeight/mouthWidth;
  //println(heightWidthRatio);
  if (heightWidthRatio < .2) heightWidthRatio= 0;
  L=gf.createLineThroughPoints(0,0, heightWidthRatio-100,-1,0,heightWidthRatio-100);
  //this one controls the speed vv
  bendModifier.setAngleFactor(20* 0.030 *heightWidthRatio);
  bendModifier.setBendAxis(L);
  mesh.modify(bendModifier);
  
  noStroke();
  render.drawEdges(mesh);
  noStroke();
  render.drawFaces(copymesh);
  
  
//if (record){
////    String[] params = { "/usr/bin/lpr", "/Users/charlottestiles/Documents/Processing/hemeshImportStl/frame-####.pdf" };
////    exec(params);
//       endRaw(); 
//       exit();
//}

shouldRecord ++;  
println (shouldRecord);

}


 
public void mouthWidthReceived(float w) {
//  println("mouth Width: " + w);
  mouthWidth = w;
}
 
public void mouthHeightReceived(float h) {
 // println("mouth height: " + h);
  mouthHeight = h;
}
 
public void eyebrowLeftReceived(float h) {
 // println("eyebrow left: " + h);
  leftEyebrowHeight = h;
}
 
public void eyebrowRightReceived(float h) {
 // println("eyebrow right: " + h);
  rightEyebrowHeight = h;
}
 
public void eyeLeftReceived(float h) {
 // println("eye left: " + h);
  eyeLeftHeight = h;
}
 
public void eyeRightReceived(float h) {
 // println("eye right: " + h);
  eyeRightHeight = h;
}

public void found(int i) {
  //println("found: " + i); // 1 == found, 0 == not found
  found = i == 1;
}
 
public void posePosition(float x, float y) {
 // println("pose position\tX: " + x + " Y: " + y );
  posePosition = new PVector(x, y);
}
 
public void poseScale(float s) {
 // println("scale: " + s);
  poseScale = s;
}
 
public void poseOrientation(float x, float y, float z) {
 // println("pose orientation\tX: " + x + " Y: " + y + " Z: " + z);
}
 
 
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.isPlugged()==false) {
   // println("UNPLUGGED: " + theOscMessage);
  }
}

void createMesh(){
  head= int(random(1,13));

  String stlFilename = head + ".stl";
  mesh = new HE_Mesh(fromStl(stlFilename));
  copymesh= mesh.get();

}




HEC_FromFacelist fromStl(String stlName) { 
  println("Start Build");
  WETriangleMesh wemesh = (WETriangleMesh) new STLReader().loadBinary(sketchPath(stlName), STLReader.WEMESH);
  //convert toxi mesh to a hemesh. Thanks to wblut for personally coding this part during #GX30
  int n=wemesh.getVertices().size();
  ArrayList<WB_Point> points= new ArrayList<WB_Point>(n);
  for (Vec3D v : wemesh.getVertices ()) { 
    points.add(new WB_Point(v.x, v.y, v.z));
  }
  int[] toxiFaces=wemesh.getFacesAsArray();
  int nf=toxiFaces.length/3;
  int[][] faces=new int[nf][3];
  for (int i=0; i<nf; i++) {
    faces[i][0]=toxiFaces[i*3];
    faces[i][1]=toxiFaces[i*3+1];
    faces[i][2]=toxiFaces[i*3+2];
  }
  HEC_FromFacelist ff=new HEC_FromFacelist().setVertices(points).setFaces(faces);
  return ff;
 
}

