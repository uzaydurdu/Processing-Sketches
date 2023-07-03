PImage inputImage;
PImage outputImage;

float [][] sourceIntensity;

int pointCount = 0;
int intensityWindow = 2;
boolean printPointCount = false;

float poissonDiscRadius = 3;
float pointRadius = 2;
int maxPoints = 6000; 
int maxAttempts = 500000;
float percentComplete = 0;

boolean uniformDiscRadii = false;
boolean doPlacementStippling = false;

PGraphics offscreenBuffer;

/**************************************************************************
TASK:

In this sketch you will implement two kinds of placement stippling.

First we implement the very basic "dart throwing" technique, where you pick
a random pixel location and place a point based on the original image
inensity. This is done in the draw() method, so you can see how points are
placed one after the other. It also showcases inefficiencies of this method.
This is associated to key '2'.

Second, you will implement poisson (like the french word for fish, pronounced
"puah-so" not "poison", merde alors!) stippling. This is NOT done in draw(),
instead in this mode you generate instances of Point and then draw them into
the PImage outputImage. This is then shown in draw(). Hence for poisson 
stippling it is a "one shot" rendering, not incrementally adding points
Implement:

distantEnough (checks if a location is far away enough from all other points)
insertPointPoissonDisc (determines one point and adds it to the list)
createPointsPoissonDisc (creates a lot of points and returns them as a LIST)
createOutputImage (converts a list of points to a PImage which can then be shown)

The final part is to implement the fast stippling, using an offscreen buffer:
Implement insertPointPoissonDisc_FAST and checkBuffer to do PD stippling with
the offscreen buffer as described in the lecture slides. Then you can use keys
4 and 5 to test it and view the offscreen buffer.

***************************************************************************/

// The Point class provides basic storage of 2D points 

class Point {
  float x, y, r; // R is used for the radius of a point
  
  Point(float px, float py) {
    x = px; 
    y = py; 
    r = 1; //2D case: Default radius to 1, so all are uniform
  }
  
  Point(float px, float py, float pr) {
    x = px; 
    y = py; 
    r = pr; 
  }
  
  Point (Point p) {
    x = p.x; 
    y = p.y;
    r = p.r;  
  }
  
  // Computes euclidian distance between this point and another coordinate pair in the XY plane
  float distXY(float px, float py) {
     return sqrt((x-px)*(x-px) + (y-py)*(y-py));
  }
}


/*
 * Creates an Pimage form a 2D array of float intensity values. 
 */
PImage createOutputImage(float [][] outputIntensity) {
  
    int w = outputIntensity.length;
    int h = outputIntensity[0].length;

    outputImage = createImage(w, h ,RGB);
    for (int y=0; y<h; ++y)
      for (int x = 0; x < w; ++x) {
        float val = 255.0 * (1.0 - outputIntensity[x][y]);
        outputImage.pixels[x+y*w] = color(val,val,val);
    }
    
    return outputImage;
}


/*
 * Takes a PImage sourceImage and converts it to greyscale intensity array with values in [0.0 - 1.0]
 */
void createIntensityVal(PImage sourceImage, float[][] intensityArray) {
  sourceImage.loadPixels();
  for (int y = 0;y < sourceImage.height; ++y) {
    for (int x = 0; x < sourceImage.width; ++x) { 
       intensityArray[x][y] = brightness(sourceImage.pixels[x+y*sourceImage.width]) / 255.0;
    }
  }
}

/*
 * Computes the intensity in the rectangle given by (x1, y1) and (x2, y2), reading data from intensityArray
 * The average intensity is the sum of all intensity values, divided by the area visited
 */

float getAvgIntensity(int x1, int y1, int x2, int y2, float [][] intensityArray) {

  int w = intensityArray.length;
  int h = intensityArray[0].length;
  x1 = max(0, min(w, x1));
  x2 = max(0, min(w, x2));
  y1 = max(0, min(h, y1));
  y2 = max(0, min(h, y2));
  
  float intensitySum = 0;
  
  for (int y = y1; y < y2; ++y) {
    for (int x = x1; x < x2; ++x) { 
       intensitySum += intensityArray[x][y];
    }
  }

  return intensitySum / ((x2-x1)*(y2-y1));
}

/*
 * Checks if a point (xy) is at least ata distance of radius to all other points in pointList. 
 */
boolean distantEnough(float x, float y, float radius, ArrayList<Point> pointList) {
  // TODO: Check if the point (x, y) is at least radius unit away from any other point in point list
   
   
   float distance = 0.0f;
   boolean isEnough = true;
   
   for(Point p : pointList){
     
     distance = p.distXY(x, y);
     
     if (distance < radius) {
       isEnough = false;
       //println("distance not enough: " + distance);
       return isEnough; 
      }
     else{
       isEnough = true;
       //println("distance enough: " + distance);
       return isEnough;
      }
   }
   
   return isEnough;
}


/*
 * Try to insert a point at (xy) using the poisson disc check
 */
boolean insertPointPoissonDisc(float [][] intensityArray, float x, float y, ArrayList<Point>  pointList) {
  // TODO: Get the average intensity around (x,y) in a window with radius 2. When uniformDiscRadii
  // is true, use poissonDiscRadius * 2.0 as a test radius, otherwise include the average intensity
  // in the computation of the radius. You can exclude intensities > 0.95 to keep the background 
  // clean. Use distantEnough() to accept or reject a point. If you accept a point, add it as a 
  // new instance of Point to the pointList. Return the acceptance status.
  
  
  float avgIntensity = getAvgIntensity((int)x-2, (int)y-2, (int)x+2, (int)y+2, intensityArray);
  float testRadius = 0.0f;
  boolean insertPoint = false;
  
  int px = (int)round(x);
  int py = (int)round(y);
   
  if (uniformDiscRadii) {
    testRadius = poissonDiscRadius * 2.0;
  } 
  else {
    testRadius = poissonDiscRadius / (avgIntensity + 1);
  }
  
  if (avgIntensity > 0.95) {
    insertPoint = false;
    
    return insertPoint;
   }
   
  if(distantEnough(px, py, testRadius, pointList)){
    pointList.add(new Point(px, py, testRadius));
    insertPoint = true;
    return insertPoint;
   }
  
  
  
  return insertPoint;
}

ArrayList createPointsPoissonDisc(boolean fast) {
  
  ArrayList<Point> pointList = new ArrayList<Point>(maxPoints);
  int points = 0;
  int attempts = 0;
  
  // TODO: Create random positions (x,y) and attempt to insert a point there.
  // Keep track of how many attemtps you made and how many points are accepted.
  // Continue inserting points until you either reach enough points or exceed 
  // the allowerd amount of attempts (maxAttempts). Also print the % complete 
  // in a resonable frequency. Too much println() will slow your program down 
  // a lot! Finally, return the list of points.
  
  while(attempts < maxAttempts){
    
    int xRandom = (int)random(0, sourceIntensity.length);
    int yRandom = (int)random(0, sourceIntensity[0].length);
    if(points < maxPoints){
      if(fast){
      if(insertPointPoissonDisc_FAST(sourceIntensity,xRandom,yRandom,pointList)){
        //println("fast creating started");
        
        points++;
        percentComplete = ((float)points / maxPoints) * 100;
        if (percentComplete % 50 == 0) {
           System.out.println(percentComplete + "% complete.");
        }
        
      }
      //println("fast creating started out");
    }
    else{
      if(insertPointPoissonDisc(sourceIntensity,xRandom,yRandom,pointList)){
        //println("slow creating started");
        points++;
        percentComplete = ((float)points / maxPoints) * 100;
        
        if (percentComplete % 50 == 0) {
           System.out.println(percentComplete + "% complete.");
        }
      }
      //println("slow creating started out");
      //println("insert return: " + insertPointPoissonDisc(sourceIntensity,xRandom,yRandom,pointList));
    }
    }
    attempts++;
  }
  
  
  
  return pointList;
}

/*float percentComplete = 0.0f;
  
  while(attempts<maxAttempts){
    int xRandom = (int)random(0, width);
    int yRandom = (int)random(0, height);
     boolean insert = insertPointPoissonDisc(sourceIntensity, xRandom, yRandom, pointList);
   
   if (insert) {
      pointList.add(new Point(xRandom, yRandom));
      points++;
      if (fast == true) {
        percentComplete = ((float)points / maxPoints);
        System.out.println(percentComplete * 100 + "% complete.");
      }
    }
    attempts++;
  }
  
  if (fast == false) {
    System.out.println(percentComplete * 100 + "% complete.");
  }
  */

/*
 * Gets a list of points and renders them into a PImage
 */
PImage createOutputImage(ArrayList<Point> pointList) {
  
  PGraphics pointGraphics = createGraphics(width, height);
  pointGraphics.beginDraw();
  pointGraphics.background(255);
  pointGraphics.fill(0);
  // TODO: Here we actually render the points computed previously. For each point
  // in the pointList you shall draw an ellipse corresponding to the points radius.
  // paint onto pointGraphics, not directly onto the screen!
  
  for(Point p : pointList){
    pointGraphics.ellipse(p.x,p.y,p.r,p.r);
    //println("px: " + p.x +" py: " + p.y);
  }
  
  // End TODO
  
  pointGraphics.endDraw();

  return pointGraphics; // PGraphics is a PImage with extra drawing stuff tacked on.
}

boolean checkBuffer(float x, float y) {
  // TODO: Check the offscreen buffer for the presence of a nearby point.
  // if it is not white, something is here. Return false if the location
  // is occupied and true otherwise. To access the offscreen buffer at a
  // certain location do NOT use offscreenBuffer.pixels, as this would
  // require a call to loadPixels() which slows this approach down significantly.
  // Instead, use offscreenBuffer.get(a, b); for quick access.
  // Furthermore, .get() returns color, which is an int, containing the RGBA in
  // its bytes. Do not use brightness() here, but directly compare to color(255);
  
  int px = (int)round(x);
  int py = (int)round(y);
  
  if(offscreenBuffer.get(px,py) == color(255)){
    //println("it is white at: " + px + " " + py);
    return true;
  }
  
  
  return false;
}

boolean insertPointPoissonDisc_FAST(float [][] intensityArray, float x, float y, ArrayList<Point> pointList) {
  
  boolean accepted = false;
  int px = (int)round(x);
  int py = (int)round(y);
  
  float R = random(0,255);
  float G = random (0,255);
  float B = random (0,255);
  
  color fillColor = color(R, G, B);
  
  float avgIntensity = getAvgIntensity(px-2, py-2, px+2, py+2, intensityArray);
  float testRadius = 1.0;
  
  if (uniformDiscRadii) {
    testRadius = poissonDiscRadius * 2.0;
  } else {
    testRadius = poissonDiscRadius * (avgIntensity + 1);
  }
  if (avgIntensity > 0.95) {
    return false;
  }
  // TODO: In order to insert a point, check the offscreen buffer for another point
  // instead of looking at all other points. If you can place a point, then draw a
  // filled point of random color at the current location. The strokeWeight should be
  // the curent test radius.
  
  if(checkBuffer(x,y)){
    pointList.add(new Point(px, py, testRadius));
    accepted = true;
    offscreenBuffer.ellipse(px,py, testRadius, testRadius);
    
    offscreenBuffer.stroke(fillColor);
    offscreenBuffer.strokeWeight(testRadius);
    offscreenBuffer.fill(fillColor);
   }
  
  
  
  return accepted;
}


void settings() {
  inputImage = loadImage("data/stone_figure.png");
  inputImage.resize(0,1000);
  size(inputImage.width, inputImage.height); // this is now the actual size
}
  
void setup() {
  frameRate(3);

  sourceIntensity = new float [inputImage.width][inputImage.height];
  createIntensityVal(inputImage, sourceIntensity);
  outputImage = inputImage;
}

void draw() {
  if (doPlacementStippling) {
    // TODO: Select a random position inside the window (use the system variables width and height for this)
    // and compute the average intensity around that location using getAvgIntensity. use the value in 
    // intensityWindow to determine the radius (2 is a good value but you can use keys to play with this).
    // Place around 500 points per frame so you do not have to wait a long time. Count how many points are 
    // placed and print this when printPointCount is true and frameCount % 100 == 0. When do you start 
    // seeing good results?
    
    
    
    while(pointCount<501){
      
      int xRandom = (int)random(0, sourceIntensity.length);
      int yRandom = (int)random(0, sourceIntensity[0].length);
      
      float avgIntensity = getAvgIntensity((int)xRandom-2, (int)yRandom-2, (int)xRandom+2, (int)yRandom+2, sourceIntensity);
      
      if (avgIntensity < random(0,1)) {
        fill(avgIntensity);
        noStroke();
        ellipse(xRandom, yRandom, pointRadius, pointRadius);
        pointCount++;
      }
      
      
    }
    if (printPointCount && frameCount % 100 == 0) {
       println("Point count: ", pointCount);
    }
    
    
  } else {
    image(outputImage,0,0);
  }
}

void keyPressed() {
  if (key=='s') save("result.png");
  
  if (key=='1') {
    // Reset to the input image and don't do any stippling 
    outputImage = inputImage;
    doPlacementStippling = false;
  }
  if (key=='2') {
    // Clear the image and start stippling. The flag doPlacementStippling is checked in the 
    // main draw loop and enables or disables the random placement of points.
     background(255);
     doPlacementStippling = true;
  }
  if (key=='3') {
    // Slow stippling: Disable placement stippling, create the points for the image and then
    // draw them to an image. By updating output image, it will be shown in the draw loop.
    doPlacementStippling = false;
    ArrayList<Point> pointList = createPointsPoissonDisc(false);
    outputImage = createOutputImage(pointList);
  }
  if (key=='4') {
    // Now we do fast stippling with the offscreen buffer. First, we disable placement stippling and then creare
    // a clear offscreen buffer as a PGraphics object. Then by calling createPointsPoissonDisc(true) we do the
    // quick stippling.
    doPlacementStippling = false;
    offscreenBuffer = createGraphics(inputImage.width, inputImage.height);
    offscreenBuffer.beginDraw();
    offscreenBuffer.stroke(color(0));
    offscreenBuffer.background(255);
    offscreenBuffer.fill(0);
    
    ArrayList<Point> pointList = createPointsPoissonDisc(true);
    outputImage = createOutputImage(pointList);
  }
  if (key=='5') {
    // For debug puposes we can show the offscreen buffer as well
    if (offscreenBuffer != null) {
      offscreenBuffer.endDraw();
      outputImage = offscreenBuffer;
    }
  }

  if (key == 'u') {
    // Enable/disable uniform disc radii
    uniformDiscRadii = !uniformDiscRadii;
  }

  if (key=='+') {
    // Increase the maximum number of points we create
    maxPoints *= 1.3;
    ArrayList<Point> pointList = createPointsPoissonDisc(false);
    outputImage = createOutputImage(pointList);
  } 
  if (key=='-') {
    // decrease the maximum number of points we create
    maxPoints /= 1.3;
    ArrayList<Point> pointList = createPointsPoissonDisc(false);
    outputImage = createOutputImage(pointList);
  } 
  /*if(key == 'd' && poissonDiscRadius != 0){
    poissonDiscRadius--;
  }
  if(key == 'i'){
    poissonDiscRadius++;
  }*/
  if (key == 'p') {
    // Enable or disable the printing of the current point count. Since this can slow down
    // your program a lot, this should not be on all the time.
    printPointCount = !printPointCount;
    println("Print point count: ", printPointCount);
    
  }
}
