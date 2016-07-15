import twitter4j.*;
import twitter4j.api.*;
import twitter4j.auth.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.management.*;
import twitter4j.util.*;
import twitter4j.util.function.*;
import java.util.Date;
import processing.serial.*;

// Create object from Serial class
Serial port; // Serial port
int val_temp; // Data received from the serial port - variable to store the temperature sensor reading
int val_light; // Data received from the serial port - variable to store the light sensor reading
int val_moist; // Data received from the serial port - variable to store the moisture sensor reading
byte[] inBuffer = new byte[255]; //size of the serial buffer to allow for end of data characters

// Twitter objects
Twitter twitter;
StatusUpdate status;

// Constants
int dimx = 500;
int dimy = 500;
int num = 0;
int maxnum = 150;

// Grid of cracks
int[] cgrid;
Crack[] cracks;

// Color parameters
int maxpal = 512;
int numpal = 0;
color[] goodcolor = new color[maxpal];

// Sand painters
SandPainter[] sands;

void setup()
{
  // Application properties
  size(500,500);
  background(255);
  
  takecolor(dataPath("palette.gif"));
  cgrid = new int[dimx*dimy];
  cracks = new Crack[maxnum];

  // Instantiate twitter object
  twitter = new TwitterFactory(new ConfigurationBuilder()         
    .setDebugEnabled(true) 
    .setOAuthConsumerKey("vEBA9JDv9onXRSIKENRToJuI3") 
    .setOAuthConsumerSecret("B6Zlj3mkC49eKMQHZ7JECBHAtjBSQQCESJbgQK2uu84geOdRqf") 
    .setOAuthAccessToken("743475229242986497-ocDQ70FNhJBTSGYJd9pvL6xUjADDUO9") 
    .setOAuthAccessTokenSecret("i3suZLvqw3SQ7McsubtTsI6hO0dCakcgWlrOtGOERE4zH")
    .build()).getInstance();
  
  // Instantiate serial object
  port = new Serial(this, Serial.list()[0], 9600);
  
  // Begin
  begin(); 
}

void draw() {
  // crack all cracks
  for (int n=0;n<num;n++) {
    cracks[n].move();
  }
}

int splitVal(String masterString, String breakPoint){
  
  String[] sensorReading = split(masterString, breakPoint);  //get sensor reading
      if (sensorReading.length != 3) return -1;  //exit this function if packet is broken
      return int(sensorReading[1]);
      
}
void initReadings(){
  if (0 < port.available()) { // If data is available to read,
    
    port.readBytesUntil('&', inBuffer);  //read in all data until '&' is encountered
    
    if (inBuffer != null) {
      String myString = new String(inBuffer);
      
      String[] fullPacket = splitTokens(myString, "&");  
      if (fullPacket.length < 2) return;  //exit this function if packet is broken
      
      //get light sensor reading 
      val_temp = splitVal(fullPacket[0], "a");

      //get slider sensor reading 
      val_light = splitVal(fullPacket[0], "b");
      
      //get moisture sensor reading      
      val_moist = splitVal(fullPacket[0], "c");
      
    }
  }
}

void mousePressed() {
  
  // Capture timestamp
  //long timestamp = new Date().getTime()/1000;
  saveFrame(dataPath("image.png"));
  
  // Prepare status
  status = new StatusUpdate("Test");
  status.setMedia(new File(dataPath("image.png"))); 

  // Upload status
  try {
    twitter.updateStatus(status);
  } catch (TwitterException te){
    println("Error: " + te);
  }
  
  begin();
}

// METHODS --------------------------------------------------

void makeCrack() {
  if (num<maxnum) {
    // make a new crack instance
    cracks[num] = new Crack();
    num++;
  }
}

void begin() {
  // erase crack grid
  for (int y=0;y<dimy;y++) {
    for (int x=0;x<dimx;x++) {
      cgrid[y*dimx+x] = 10001;
    }
  }
  // make random crack seeds
  for (int k=0;k<16;k++) {
    int i = int(random(dimx*dimy-1));
    cgrid[i]=int(random(360));
  }

  // make just three cracks
  num=0;
  for (int k=0;k<3;k++) {
    makeCrack();
  }
  background(255);
}

// COLOR METHODS ----------------------------------------------------------------

color somecolor() {
  // pick some random good color
  return goodcolor[int(random(numpal))];
}

void takecolor(String fn) {
  PImage b;
  b = loadImage(fn);
  image(b,0,0);

  for (int x=0;x<b.width;x++){
    for (int y=0;y<b.height;y++) {
      color c = get(x,y);
      boolean exists = false;
      for (int n=0;n<numpal;n++) {
        if (c==goodcolor[n]) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        // add color to pal
        if (numpal<maxpal) {
          goodcolor[numpal] = c;
          numpal++;
        }
      }
    }
  }
}




// OBJECTS -------------------------------------------------------

class Crack {
  float x, y;
  float t;    // direction of travel in degrees
  
  // sand painter
  SandPainter sp;
  
  Crack() {
    // find placement along existing crack
    findStart();
    sp = new SandPainter();
  }
  
  void findStart() {
    // pick random point
    int px=0;
    int py=0;
    
    // shift until crack is found
    boolean found=false;
    int timeout = 0;
    while ((!found) || (timeout++>1000)) {
      px = int(random(dimx));
      py = int(random(dimy));
      if (cgrid[py*dimx+px]<10000) {
        found=true;
      }
    }
    
    if (found) {
      // start crack
      int a = cgrid[py*dimx+px];
      if (random(100)<50) {
        a-=90+int(random(-2,2.1));
      } else {
        a+=90+int(random(-2,2.1));
      }
      startCrack(px,py,a);
    } else {
      //println("timeout: "+timeout);
    }
  }
   
  void startCrack(int X, int Y, int T) {
    x=X;
    y=Y;
    t=T;//%360;
    x+=0.61*cos(t*PI/180);
    y+=0.61*sin(t*PI/180);  
  }
             
  void move() {
    // continue cracking
    x+=0.42*cos(t*PI/180);
    y+=0.42*sin(t*PI/180); 
    
    // bound check
    float z = 0.33;
    int cx = int(x+random(-z,z));  // add fuzz
    int cy = int(y+random(-z,z));
    
    // draw sand painter
    regionColor();
    
    // draw black crack
    stroke(0,85);
    point(x+random(-z,z),y+random(-z,z));
    
    
    if ((cx>=0) && (cx<dimx) && (cy>=0) && (cy<dimy)) {
      // safe to check
      if ((cgrid[cy*dimx+cx]>10000) || (abs(cgrid[cy*dimx+cx]-t)<5)) {
        // continue cracking
        cgrid[cy*dimx+cx]=int(t);
      } else if (abs(cgrid[cy*dimx+cx]-t)>2) {
        // crack encountered (not self), stop cracking
        findStart();
        makeCrack();
      }
    } else {
      // out of bounds, stop cracking
      findStart();
      makeCrack();
    }
  }
  
  void regionColor() {
    // start checking one step away
    float rx=x;
    float ry=y;
    boolean openspace=true;
    
    // find extents of open space
    while (openspace) {
      // move perpendicular to crack
      rx+=0.81*sin(t*PI/180);
      ry-=0.81*cos(t*PI/180);
      int cx = int(rx);
      int cy = int(ry);
      if ((cx>=0) && (cx<dimx) && (cy>=0) && (cy<dimy)) {
        // safe to check
        if (cgrid[cy*dimx+cx]>10000) {
          // space is open
        } else {
          openspace=false;
        }
      } else {
        openspace=false;
      }
    }
    // draw sand painter
    sp.render(rx,ry,x,y);
  }
}


class SandPainter {

  color c;
  float g;

  SandPainter() {

    c = somecolor();
    g = random(0.01,0.1);
  }
  void render(float x, float y, float ox, float oy) {
    // modulate gain
    g+=random(-0.050,0.050);
    float maxg = 1.0;
    if (g<0) g=0;
    if (g>maxg) g=maxg;
    
    // calculate grains by distance
    //int grains = int(sqrt((ox-x)*(ox-x)+(oy-y)*(oy-y)));
    int grains = 64;

    // lay down grains of sand (transparent pixels)
    float w = g/(grains-1);
    for (int i=0;i<grains;i++) {
      float a = 0.1-i/(grains*10.0);
      stroke(red(c),green(c),blue(c),a*256);
      point(ox+(x-ox)*sin(sin(i*w)),oy+(y-oy)*sin(sin(i*w)));
    }
  }
}