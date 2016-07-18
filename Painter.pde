class Painter 
{
  // Constant variables
  public final int WIN_WIDTH = width;    // Window width
  public final int WIN_HEIGHT = height;  // Window height
  
  public int MAX_TOTAL = 160;            // Maximum number of total cracks
  public final int MAX_CRACKS = 8;      // Maximum number of live cracks
  public int MAX_PAL = 100;              // Maximum number of colors
  public int MAX_INITIAL = 6;            // Maximum number of initial crack spawns
        
  public float strokeWidth = 11.5;         // Stroke height
  public int strokeWeight = 7;           // Stroke weight
  public int strokeOpacity = 225;        // Stroke opacity
  
  // Instance variables
  public SandPainter[] sands; // Contains sand strokes
  public Crack[] cracks;      // Contains crack strokes
  public color[] goodcolor;   // Color grid
  public int[] cgrid;         // Crack grid
  public int totalCracks;     // Number of total cracks
  public int numCracks;       // Number of live cracks
  public int numPal;          // Number of colors
  public boolean painting;    // When false, cracks cannot move
  public boolean cracking;    // When false, cracks cannot split
  
      
  // Constructor
  Painter(int maxTotal, int light_val, int maxInit) 
  {

    // Initialize instance variables
    //MAX_PAL=maxPal;
    this.goodcolor = new color[MAX_PAL];
    //MAX_TOTAL = maxTotal;
    this.cgrid = new int[WIN_WIDTH*WIN_HEIGHT];
    this.cracks = new Crack[MAX_CRACKS];
    //MAX_INITIAL = maxInit;
    takecolor(dataPath("swatch.png"));
    restart();
  }

  public void paint()
  {
    boolean drawing = false;
    for (int n=0; n<numCracks; n++) {
      if(cracks[n].moving == true) {
        cracks[n].move();
        drawing = true;
      }
    }
    if (!drawing){
      painting = false;
    }
  }

  // Make a new crack instance
  public void makeCrack() 
  {
    if (totalCracks++ < MAX_TOTAL) {
      if (numCracks<MAX_CRACKS) {
      cracks[numCracks++] = new Crack();
      }
    } else cracking = false;
  }

  // Setup painter
  public void restart() 
  {
    // Reset global variables
    painting = true;
    cracking = true;
    numCracks = 0;
    totalCracks = 0;
    
    // Erase crack grid
    for (int y=0; y<WIN_HEIGHT; y++) 
      for (int x=0; x<WIN_WIDTH; x++) 
        cgrid[y*WIN_WIDTH+x] = 10001;

    // Make random crack seeds
    for (int k=0; k<16; k++) 
    {
      int i = int(random(WIN_WIDTH*WIN_HEIGHT-1));
      cgrid[i] = int(random(360));
    }

    // Make just three cracks
    numCracks=0;
    for (int k=0; k<MAX_INITIAL; k++) {
      makeCrack();
    }
    background(somecolor());
  }

  // COLOR METHODS ----------------------------------------------------------------

  color somecolor() 
  {
    // pick some random good color
    return goodcolor[int(random(numPal))];
  }

  void takecolor(String fn) 
  {
    PImage b = loadImage(fn);
    image(b, 0, 0);
    
    for (int i = palXPos; i <= palXPos+100 && i <= light_high; i++) 
    {
        color c = get(i, 0);
        boolean exists = false;

        for (int n = 0; n < numPal; n++) 
        {
          if (c == goodcolor[n]) 
          {
            exists = true;
            break;
          }
        }
        if (!exists && numPal<MAX_PAL) {
          // add color to palette
          goodcolor[numPal] = c;
          numPal++;
      }
    }
  }

  // OBJECTS -------------------------------------------------------

  class Crack {
    float x, y;
    float t;    // direction of travel in degrees
    boolean moving = true;

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
        px = int(random(WIN_WIDTH));
        py = int(random(WIN_HEIGHT));
        if (cgrid[py*WIN_WIDTH+px]<10000) {
          found=true;
        }
      }
      int angle = (int)random(90-35,90+35);
      if (found) {
        // start crack
        int a = cgrid[py*WIN_WIDTH+px];
        if (random(100)<50) {
          a-=angle+int(random(-2, 2.1));
        } else {
          a+=angle+int(random(-2, 2.1));
        }
        startCrack(px, py, a);
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
      int cx = int(x+random(-z, z));  // add fuzz
      int cy = int(y+random(-z, z));

      // draw sand painter
      regionColor();

      // draw black crack
      strokeWeight(5);
      stroke(0,0);
      point(x+random(-z, z), y+random(-z, z));


      if ((cx>=0) && (cx<WIN_WIDTH) && (cy>=0) && (cy<WIN_HEIGHT)) {
        // safe to check
        if ((cgrid[cy*WIN_WIDTH+cx]>10000) || (abs(cgrid[cy*WIN_WIDTH+cx]-t)<5)) {
          // continue cracking
          cgrid[cy*WIN_WIDTH+cx]=int(t);
        } else if (abs(cgrid[cy*WIN_WIDTH+cx]-t)>2) {
          // crack encountered (not self), stop cracking
          newCrack();
        }
      } else {
        // out of bounds, stop cracking
        newCrack();
      }
    }
    
    void newCrack(){
      if (cracking == true) {
        findStart();
        makeCrack();
      } else {
        moving = false;
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
        if ((cx>=0) && (cx<WIN_WIDTH) && (cy>=0) && (cy<WIN_HEIGHT)) {
          // safe to check
          if (cgrid[cy*WIN_WIDTH+cx]>10000) {
            // space is open
          } else {
            openspace=false;
          }
        } else {
          openspace=false;
        }
      }
      // draw sand painter
      sp.render(rx, ry, x, y);
    }
  }

  class SandPainter {

    color c;
    float g;

    SandPainter() {

      c = somecolor();
      g = random(0.01, 0.1);
    }
    void render(float x, float y, float ox, float oy) {
      
   
      // modulate gain
      g+=random(strokeWidth);
      float maxg = 1.0;
      if (g<0) g=0;
      if (g>maxg) g=maxg;

      // calculate grains by distance
      int grains = int(sqrt((ox-x)*(ox-x)+(oy-y)*(oy-y)));
     // int grains = strokeGrains;

      // lay down grains of sand (transparent pixels)
      float w = g/(grains-1);
      for (int i=0; i<grains; i++) {
        float a = 0.1-i/(grains*10.0);    
        strokeWeight(strokeWeight);
        stroke(red(c), green(c), blue(c), a*strokeOpacity);
        point(ox+(x-ox)*sin(sin(i*w)), oy+(y-oy)*sin(sin(i*w)));
      }
    }
  }
}