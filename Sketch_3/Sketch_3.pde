// Sketch 3 Digital Screening
 
float [][] sourceIntensity;
float [][] outputIntensity;
float [][] ditherKernel;

PImage inputImage;  // Loaded input image, do not alter!
PImage outputImage; // Put your result image in here, so it gets displayed
PImage ditherKernelImage;

float rotate = 0.f;          // current rotation
boolean sineDisplace = true; // enable sine displacement
float sineFreq = 1.f;        // sine parameters
float sineScale =  1.f;
float sinePhase = 0.f;
float I = 0.5f; 

boolean use_cross_kernel = false;

float k_w_scale = 1.f / 16.f; // kernel scale
float k_h_scale = 1.f / 16.f;

/***************************************************************************
TASK:

Now, you will tackle procedural screening, which is more tricky. Here you
do not load a kernel from a file, but define a mathematical function, as 
given in the slides. This is done in kernel_cross and 
kernel_double_sided_ramp. You can use the key 'k' to call "drawKernelRotated"
to visualize your kernel and see if it matches the reference image.

The next step is to implement mapModulo, which again can be viewed with 'm'
to call drawKernelModulo.

Finally, you can flesh out dither_screen_proc to actually apply the kernels 
to the loaded image. 

BONUS: Implement sine displacement mapping in displace_sine.

HINT: Check out the keys at the end to see which parameters you can experiment
with.

HINT: There are a lot of keybindings for this exercise, so make sure to check 
out the keyPressed() function at the end of the file. The most important keys 
are:
* '1' -> Reset
* '2' -> Switch to dithering and switch between sine displacement and regular mode.
* ' ' -> (Spacebar): Switch between the cross-kernel and double sided ramp
* 'r' -> Rotate the Kernel
* 's' -> Save the result
* 'k' -> Draw the kernel (useful to debug your kernel implementation)
* 'm' -> Draw the kernel with modulo mapping (again for debugging)
****************************************************************************/


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

/*
* Rotates a point (x_in, y_in) by the given amount in radians, in a picture of given
* width and height. 
*/
PVector rotate2D(int x_in, int y_in, int img_width, int img_height, float radians)
{
  float x = (float) x_in;
  float y = (float) y_in;
  
  // Our coordinate system has it's origin in the top left corner. We want to 
  // rotate the kernel about the center of the screen
  // To rotate point a around b, we compute t = a - b; t = t * R; a = t + b
  // this subtracts the pivot point, rotates around the origin and then moves the 
  // rotated point back to the pivot. Sampling the kernel in this way avoids 
  // rotating the kernel off-screen

  float xr = x - img_width / 2.0;
  float yr = y - img_height / 2.0;
  float x_rot = (xr*cos(radians)-yr*sin(radians));
  float y_rot = (xr*sin(radians)+yr*cos(radians));
  x_rot += img_width / 2.0;
  y_rot += img_height / 2.0;

  return new PVector(x_rot, y_rot, 0.0);
}

/*
* Debug function to draw a kernel, scaled up to the entire window.
* Use this to visualize your kernel functions!
*/
PImage drawKernelRotated(int w, int h, float radians)
{
  PImage kernel = createImage(w, h, RGB);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) 
    {
      PVector p = rotate2D(x, y, w, h, radians);

      float val;
      if (use_cross_kernel) {
        val = kernel_cross(p.x / (float) w, p.y / (float) h, I);
      } else {
        val = kernel_double_sided_ramp(p.x / (float) w, p.y / (float) h, I);
      }

      kernel.set(x, y, color(val * 255));
    }   
  }
  return kernel;
}

/*
* Debug function to draw a kernel, as mapped my the modulo map function.
* Use this to visualize your modulo mapping!
*/
PImage drawKernelModulo(int w, int h, float radians)
{
  int mod_width = (int) (width  * k_w_scale);
  int mod_height = (int) (height  * k_h_scale);
  PImage kernel = createImage(w, h, RGB);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) 
    {
      PVector p = rotate2D(x, y, w, h, radians);
      PVector m = mapModulo(p, mod_width, mod_height);
      
      float val;
      if (use_cross_kernel) {
        val = kernel_cross(m.x, m.y, I);
      } else {
        val = kernel_double_sided_ramp(m.x, m.y, I);
      }

      kernel.set(x, y, color(val * 255));
    }   
  }
  return kernel;
}

///////////////////////////////////////////////////////////////////
// Your task below this line
///////////////////////////////////////////////////////////////////

float kernel_cross(float s, float t, float I)
{
  // TODO: Implement the cross hatching kernel here 
  
  if(s <= I){
    return I*t;
  }
  else{
    return (1-I)*s + I;
  }
}


float kernel_double_sided_ramp(float s, float t, float I)
{
  // TODO: Implement the double sided ramp here
  if(s <= 0.5){
    return 2*s;
  }
  else{
    return 2 - (2*s);
  }
}

PVector mapModulo(PVector position, int imageWidth, int imageHeight)
{
  // TODO: Create the modulo mapping function so you use the position (x, y)
  // and the width/height (called n and m in the slides) to produce a
  // repeating application of a dither kernel. This is done by mapping every 
  // pixel (x,y) to a value for the dither kernel (s, t) (with 0 <= s, t <= 1) 
  // and then using kernel(s,t) to modulate the image accordingly. If the mapped 
  // location turns negative, wrap back around to the positive side.
  // HINT: Beware of accidental integer division!
  PVector mapped = new PVector();
  
  // your code here!
  float s = position.x % imageWidth;
  float t = position.y % imageHeight;
  
  // Handle negative values by wrapping around to the positive side
  if (s < 0) {
    s += imageWidth;
  }
  if (t < 0) {
    t += imageHeight;
  }

  // Map the position to a value for the dither kernel (s, t)
  mapped.x = s / imageWidth;
  mapped.y = t / imageHeight;

  
  return mapped;
}


void dither_screen_proc(float[][] source, float[][] output) {

  int s_width = source.length;
  int s_height = source[0].length;
  int mod_width = (int) (s_width  * k_w_scale);
  int mod_height = (int) (s_height  * k_h_scale);
  
  // TODO: Iterate the image, then use rotate2D and mapModulo to first
  // rotate and then modulo map the current x/y location to a kernel
  // location. Optionally use displace_sine afterwards.
  // Then, either apply kernel_double_sided_ramp or kernel_cross at
  // the computed position to get your threshold. Finally, compare the
  // source image to the threshold to determine the output image result.
  
  for (int x = 0; x < s_width; x++) {
    for (int y = 0; y < s_height; y++) {
      
      PVector p = rotate2D(x, y, s_width,s_height, rotate);
      PVector m = mapModulo(p, mod_width, mod_height);
      PVector d = displace_sine(m, sineScale, sineFreq, sinePhase, s_height);
      
      float threshold = 0.0;
      if (use_cross_kernel) {
        threshold = kernel_cross(m.x, m.y, I);
      } 
      else {
        threshold = kernel_double_sided_ramp(m.x, m.y, I);
      }
     
      if (source[x][y] < threshold) {
        output[x][y] = 0.0;
      } 
      else {
        output[x][y] = 1.0;
      }
    }
  }

  
}

/*if (sineDisplace) {
        threshold = kernel_cross(d.x, d.y, I);
      } 
      else {
        threshold = kernel_double_sided_ramp(d.x, d.y, I);
      }*/

PVector displace_sine(PVector point, float scale, float freq, float phase, int s_height)
{
  // BONUS TODO: Implement sine displacement
  // Here you should compute a new point based on the input parameters:
  // Scale: Amplitude of the sine wave
  // Phase: Shift of the sine wave
  // Freq:  Frquency of the sine wave
  // Do bounds checking to not write out of bounds
  // Return the displaced point.
  
  float x = point.x;
  float y = point.y;
  
  float displacementX = scale * sin(TWO_PI / freq * (x + phase));
  float displacementY = scale * sin(TWO_PI / freq * (y + phase));
  
  PVector displacedPoint = new PVector(x + displacementX, y + displacementY);
  
  if (displacedPoint.y <= 0) {
    displacedPoint.y = 1;
  } 
  else if (displacedPoint.y >= s_height) {
    displacedPoint.y = s_height - 1;
  }
 
  return displacedPoint;
}
  /*float x = point.x;
  float y = point.y;
  
  float displacement = scale * sin(freq * (x + phase));
  
  PVector displacedPoint = new PVector(x * displacement, y);
  
  if (displacedPoint.y <= 0) {
    displacedPoint.y = 1;
  } 
  else if (displacedPoint.y >= s_height) {
    displacedPoint.y = s_height - 1;
  }
  ////////////////////////////////////////////////////////////////////
  float displacedX = point.x + scale * sin(( freq * point.x ) + phase);
  float displacedY = point.y + scale * sin(( freq * point.y ) + phase);
  
  // bounds checking
  displacedX = max(0, min(displacedX, width - 1));
  displacedY = max(0, min(displacedY, s_height - 1));
  
  PVector displacedPoint = new PVector(displacedX, displacedY);*/
/*
 * Setup gets called ONCE at the beginning of the sketch. Load images here, size your window etc.
 * If you want to size your window according to the input image size, use settings().
 */

void settings() {
  inputImage = loadImage("data/flower.png");
  ditherKernelImage = loadImage("data/kernels/4.png");
  size(inputImage.width, inputImage.height); // this is now the actual size
} 

void setup() {
  surface.setResizable(false);
  frameRate(3);

  sourceIntensity = new float [inputImage.width][inputImage.height];
  outputIntensity = new float [inputImage.width][inputImage.height];
  
  createIntensityVal(inputImage, sourceIntensity);
  outputImage = inputImage;
  
  int ditherKernelSize = 16;
  ditherKernel = new float [ditherKernelSize][ditherKernelSize];
  ditherKernelImage.resize(ditherKernelSize, ditherKernelSize);
  createIntensityVal(ditherKernelImage, ditherKernel);
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
  if (key=='1') {
    rotate = 0.f;
    outputImage = inputImage;
  }
  if (key=='2') {
    sineDisplace = !sineDisplace;
    dither_screen_proc(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key == ' ') {
    use_cross_kernel = !use_cross_kernel;
  }
  
  if (key=='r') {
    rotate += 0.125f * HALF_PI;
    dither_screen_proc(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='t') {
    sineFreq += 0.5f;
    dither_screen_proc(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='f') {
    sineFreq -= 0.5f;
    dither_screen_proc(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='g') {
    sineScale += 0.05f;
    dither_screen_proc(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='h') {
    sineScale -= 0.05f;
    dither_screen_proc(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  
  if (key=='+') {
    I += 0.1f;
    dither_screen_proc(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='-') {
    I -= 0.1f;
    dither_screen_proc(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  
  if (key=='l') {
    k_w_scale *= 0.5f;
    k_h_scale *= 0.5f;
    dither_screen_proc(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  if (key=='o') {
    k_w_scale *= 2.f;
    k_h_scale *= 2.5f;
    dither_screen_proc(sourceIntensity, outputIntensity);
    outputImage = convertIntensityToPImage(outputIntensity);
  }
  
  if (key=='k') {
    outputImage = drawKernelRotated(inputImage.width, inputImage.height, rotate);
    rotate += 0.125f * HALF_PI;
  }
  if (key=='m') {
    outputImage = drawKernelModulo(inputImage.width, inputImage.height, rotate);
    rotate += 0.125f * HALF_PI;
  }
  if (key == 's') save("output.png");
}
