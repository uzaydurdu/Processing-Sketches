// Sketch 1-3 Floyd Steinberg with lines
 
float [][] sourceIntensity;
float [][] outputIntensity;

PImage inputImage;  // Loaded input image, do not alter!
PImage outputImage; // Put your result image in here, so it gets displayed

/************************************************************************
TASK:

You will find several empty functions marked with TODO in this file. 
Implement the algorithms required to solve the described task. You can
find reference images in the data folder, which can help you to see if 
you are on track. The functions you need to work on (in recommended 
order) are:

1) dither_treshold
2) dither_random
3) dither_FloydSteinberg1D
4) dither_FloydSteinberg2D
5) drawLine
6) dither_FloydSteinberg2DLines
*************************************************************************/

/*
 * Converts an intensity array to a PImage (RGB)
 */
PImage convertIntensityToPImage(float [][] intensityArrayImg) {
  
    int w = intensityArrayImg.length;
    int h = intensityArrayImg[0].length;

    PImage convertedImage = createImage(w, h, RGB);
    for (int y = 0; y < h; ++y)
      for (int x = 0; x < w; ++x) {
        float val = 255.0 * intensityArrayImg[x][y]; //<>//
        convertedImage.pixels[x+y*w] = color(val,val,val);
    }
    
    return convertedImage;
}

/*
 * Initializes the passed float array with the corresponding intensity values of the source image.
 * intensityArray is passed BY REFERENCE so changes will be made to it.
 */

void createIntensityVal(PImage sourceImage, float[][] intensityArray) {
  // PImage.pixels is only filled with valid data after loadPixels() is called
  // After PImage pixels is changed, you must call updatePixels() for the changes
  // to have effect.
  sourceImage.loadPixels();
  for (int y = 0; y < sourceImage.height; ++y) {
    for (int x = 0; x < sourceImage.width; ++x) {
		  intensityArray[x][y] = brightness(sourceImage.pixels[x + y*sourceImage.width]) / 255.0;
    }
  }
}

void dither_treshold(float[][] source, float[][] out) {
  
  // TODO: Iterate all pixels in S. Compare the intensity to a threshold value (e.g. 0.5) and set the corresponding pixel
  // in O to 0.0 if the intensity if below the threshold. Set it to 1.0 if it is greater or equal.
  // Hint: Access is S[x][y]. So the length of S is the width of the image and the length of S[0] is the height.
  // Accessing S[0][1] accesses the pixel in the first column, in the second row.
  // . . .
  // x . .     <- S[0][1]
  // . . .  

  int w = source.length;
  int h = source[0].length;
  float threshold = 0.5;
  
  for (int y = 0; y < h; ++y) {
    for (int x = 0; x < w; ++x) {
      if(source[x][y] > threshold){
        out[x][y] = 1.0;
      }
      
      else{
        out[x][y] = 0.0;
      }
    }
  }
  

}

void dither_random(float[][] source, float[][] out) {
  
  // TODO: Do the same as in dither_threshold, but add or subtract a small value form the threshold.
  // Change the random value for each pixel.

  int w = source.length;
  int h = source[0].length;
  
  float threshold = 0.5;
  
  for (int y = 0; y < h; ++y) {
    for (int x = 0; x < w; ++x) {
      if(source[x][y] > threshold + random(-0.2, 0.2)){
        out[x][y] = 1.0;
      }
      
      else{
        out[x][y] = 0.0;
      }
    }
  }

} 

void dither_FloydSteinberg1D(float[][] S, float[][] O) {

   // TODO: Implement Floyd-Steinberg DIthering in 1D.
   // Iterate all pixels of S and set the corresponding pixel in O if the source pixel exceeds a threshold.
   // Compute the error created by the thresholding and propagate it according to the 1D error propagation.
   // HINT: Watch out to not access an out-of-bounds pixel while propagating!
  
  int w = S.length;
  int h = S[0].length;
  float threshold = 0.5;
  float k = 0.0;
  float error = 0.0;
 
  for (int y = 0; y < h; ++y) {
    for (int x = 0; x < w; ++x) {
      
      if(S[x][y] > threshold){
        k = 1.0;
      }
      else{
        k = 0.0;
      }
      
      O[x][y] = k;
      error = S[x][y] - k;
      if(x != 518){
        S[x+1][y] += error;
      }
      
      }
  }

} 

void dither_FloydSteinberg2D(float[][] S, float[][] O) {

   // TODO: Implement Floyd-Steinberg DIthering in 2D.
   // Iterate all pixels of S and set the corresponding pixel in O if the source pixel exceeds a threshold.
   // Compute the error created by the thresholding and propagate it according to the 2D error propagation.
   // HINT: Make sure to use floating point values and not integers.
   // HINT: Watch out to not access an out-of-bounds pixel while propagating!
  
  int w = S.length;
  int h = S[0].length;
  float threshold = 0.5;
  float k = 0.0;
  float error = 0.0;
  
  for (int y = 0; y < h; ++y) {
    for (int x = 0; x < w; ++x) {
      
      if(S[x][y] > threshold){
        k = 1.0;
      }
      else{
        k = 0.0;
      }
      O[x][y] = k;
      error = S[x][y]  - k;
      
      if(x != w-1 && x != 0 && y != h-1 && y != 0){
        S[x+1][y] += (7.0/16.0) * error;
        S[x-1][y+1] += (3.0/16.0) * error;
        S[x][y+1] += (5.0/16.0) * error;
        S[x+1][y+1] += (1.0/16.0) * error;
      }
      }
  }
} 

int drawLineOverlap(float[][] targetImg, int x0, int y0, int len) {
  // TODO: draw a line in O by setting the pixel belonging to the line to 0.0 (black)
  // The line shall be at 45° and be drawn only onto pixels that have already been visited.
  // If you draw "ahead" of the error propagation your picture will be off.
  // Example: A line at x = 10, y = 10 and len = 3 should set the pixels (10, 10); (9, 9); (8, 8) 
  // to black. 
  // HINT: Don't get fancy with angles! Just draw the required amount of pixels diagonally 
  // towards the top left.
  
  int w = targetImg.length;
  int h = targetImg[0].length;
  int count = 0;
  
  for(int z = 0; z < len; z++){
    if(!(x0-z < 0) && !(y0-z < 0)){
      if(targetImg[x0-z][y0-z] == 0.0){
        count++;
      }
      else{
         targetImg[x0-z][y0-z] = 0.0;
      }
    } 
  }
  
  

  return count;
} 

void drawLine(float[][] targetImg, int x0, int y0, int len) {
  // TODO: draw a line in O by setting the pixel belonging to the line to 0.0 (black)
  // The line shall be at 45° and be drawn only onto pixels that have already been visited.
  // If you draw "ahead" of the error propagation your picture will be off.
  // Example: A line at x = 10, y = 10 and len = 3 should set the pixels (10, 10); (9, 9); (8, 8) 
  // to black. 
  // HINT: Don't get fancy with angles! Just draw the required amount of pixels diagonally 
  // towards the top left.
  
  int w = targetImg.length;
  int h = targetImg[0].length;
  
  
  for(int z = 0; z < len; z++){
    if(!(x0-z < 0) && !(y0-z < 0)){
      targetImg[x0-z][y0-z] = 0.0;
    } 
  }
  
 
} 


void dither_FloydSteinberg2DLinesOverlap(float[][] source, float[][] out) {

  // TODO: First implement drawLine() above.
  // As a first step, set all pixels of O to 1.0, to provide a white background.
  // Secondly, reimplement the Floyd Steinberg 2D dithering error porpagation, but 
  // consider the error of the line you have drawn, not just a single pixel. 
  // Propagate this error to the neighbors as before. 
  
  int w = source.length;
  int h = source[0].length;
  float error = 0.0;
  int m = 5;
  int count = 0;
  float threshold = 0.5;
  
  for (int y = 0; y < h; ++y) {
    for (int x = 0; x < w; ++x) {
      out[x][y] = 1.0;
    }
  }
  
  for (int y = 0; y < h; ++y) {
    for (int x = 0; x < w; ++x) {
      
      if(source[x][y] < threshold){
        count = drawLineOverlap(out,x,y,m);
        error = source[x][y] + (m-1-count);
      }
      else{
        error = source[x][y] - out[x][y];
      }
 
      if(x != w-1 && x != 0 && y != h-1 && y != 0){
        source[x+1][y] += (7.0/16.0) * error;
        source[x-1][y+1] += (3.0/16.0) * error;
        source[x][y+1] += (5.0/16.0) * error;
        source[x+1][y+1] += (1.0/16.0) * error;
      }
      }
  }

} 

void dither_FloydSteinberg2DLines(float[][] source, float[][] out) {

  // TODO: First implement drawLine() above.
  // As a first step, set all pixels of O to 1.0, to provide a white background.
  // Secondly, reimplement the Floyd Steinberg 2D dithering error porpagation, but 
  // consider the error of the line you have drawn, not just a single pixel. 
  // Propagate this error to the neighbors as before. 
  
  int w = source.length;
  int h = source[0].length;
  float error;
  int m = 5; 
  
  float threshold = 0.5;
  
  for (int y = 0; y < h; ++y) {
    for (int x = 0; x < w; ++x) {
      out[x][y] = 1.0;
    }
  }
  
  for (int y = 0; y < h; ++y) {
    for (int x = 0; x < w; ++x) {
      
      if(source[x][y] < threshold){
        drawLine(out,x,y,m);
        error = source[x][y] + (m-1);
      }
      else{
        error = source[x][y] - out[x][y];
      }
 
      if(x != w-1 && x != 0 && y != h-1 && y != 0){
        source[x+1][y] += (7.0/16.0) * error;
        source[x-1][y+1] += (3.0/16.0) * error;
        source[x][y+1] += (5.0/16.0) * error;
        source[x+1][y+1] += (1.0/16.0) * error;
      }
      }
  }

} 
  
/*
 * Setup gets called ONCE at the beginning of the sketch. Load images here, size your window etc.
 * If you want to size your window according to the input image size, use settings().
 */

void settings() {
  inputImage = loadImage("data/flower.png");
  size(inputImage.width, inputImage.height); // this is now the actual size
} 

void setup() {
  surface.setResizable(false);
  frameRate(3);

  sourceIntensity = new float [inputImage.width][inputImage.height];
  outputIntensity = new float [inputImage.width][inputImage.height];

  createIntensityVal(inputImage, sourceIntensity);
  outputImage = inputImage;   
}

/*
 * In this function, outputImage gets drawn to the window. Code in here gets executed EVERY FRAME
 * so be careful what you put here. You should only compute the dithering once, hence don't put
 * any calls to it here. 
 */
void draw() {

  // Displays the image at its actual size at point (0,0)
  image(outputImage, 0, 0); 
}

/*
 * This function gets called when a key is pressed. Use it to control your program and change parameters
 * via key input. 
 */

void keyPressed() {
  createIntensityVal(inputImage, sourceIntensity);
  if (key=='1') {
    outputImage = inputImage;
  }
  if (key=='2') {
      dither_treshold(sourceIntensity, outputIntensity);
      outputImage = convertIntensityToPImage(outputIntensity);
  }
    if (key=='3') {
      dither_random(sourceIntensity, outputIntensity);
      outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='4') {
    createIntensityVal(inputImage, sourceIntensity);
    dither_FloydSteinberg1D(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='5') {
    createIntensityVal(inputImage, sourceIntensity);
    dither_FloydSteinberg2D(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='6') {
    createIntensityVal(inputImage, sourceIntensity);
    dither_FloydSteinberg2DLines(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='7') {
    createIntensityVal(inputImage, sourceIntensity);
    dither_FloydSteinberg2DLinesOverlap(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }

  if (key == 's') save("output.png");
}
