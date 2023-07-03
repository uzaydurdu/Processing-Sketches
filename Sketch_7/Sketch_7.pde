PImage inp, blurred, texture;
ArrayList<Stroke> strokes;
int mode = 0;
float lineWidth = 15;
float drawAlpha = 30;

boolean strokeDebug = false;
boolean startOnWhite = true;

float computeColorImpact(Stroke s, PImage ref) {
  // TODO: For a given stroke, acquire its points and sum the color error created at each point.
  // return the sum divided by the stroke length, to provide a measure o a strokes quality.
  ArrayList<PVector> points = s.getPoints();

  float errorSum = 0.0;

  // ...your code here...

  for (PVector point : points) {
    color col = ref.get(round(point.x), round(point.y));
    color strokeColor = s.strokeColor;
    errorSum += sqrt(sq(red(col)-red(strokeColor)) + sq(green(col)-green(strokeColor)) + sq(blue(col)-blue(strokeColor)));
  }
  errorSum = errorSum/points.size();
  return errorSum;
}

////////////////////////////////////////////////////////

void createACoupleOfStrokes(int noStrokes) {
  int strokesPainted = 0;
  while (strokesPainted < noStrokes) {
    int px = (int)random(0, inp.width-1);
    int py = (int)random(0, inp.height-2);
    color col = inp.pixels[px + py*inp.width];

    // TODO: Only continue with this stroke when starting on white background of the CANVAS
    // (not the input image!) you can use the function get() for this purpose. In processing 4
    // you should check that each channel is 255 and ignore alpha, since the alpha value can
    // be inconsistent.
    color canvasColor = get(px, py);

    if (startOnWhite && red(canvasColor) == 255 && green(canvasColor) == 255 && blue(canvasColor) == 255) {

      Stroke s = new Stroke(new PVector(px, py), lineWidth, col, texture);
      s.movePerpendicuarToGradient(20, blurred);

      if (s.getSize() > 3) {
        float strokeError = computeColorImpact(s, inp);

        // TODO: If the stroke error is smaller than 50 (i.e. it has little effect) omit it
        // otherwise draw it using Stroke's class method draw()
        if (strokeError > 50) {
          s.draw();
          strokesPainted++;
        }
      }
    }
  }
}

/*
if (startOnWhite && red(canvasColor) == 255 && green(canvasColor) == 255 && blue(canvasColor) == 255) {
 Stroke s = new Stroke(new PVector(px, py), lineWidth, col, texture);
 s.movePerpendicuarToGradient(20, blurred);
 
 if (s.getSize() > 3) {
 float strokeError = computeColorImpact(s, inp);
 
 // TODO: If the stroke error is smaller than 50 (i.e. it has little effect) omit it
 // otherwise draw it using Stroke's class method draw()
 if (strokeError > 50) {
 s.draw();
 strokesPainted++;
 }
 }
 }
 }*/

/////////////////////////////////////////////////////////
// draw the stroke at the position of the mouse
// for debugging, color is inverse to image
/////////////////////////////////////////////////////////

void createStrokeAtMousePosition() {
  background(inp);
  int px = (int)mouseX;
  int py = (int)mouseY;
  color col = inp.pixels[px + py*inp.width];
  Stroke s = new Stroke(new PVector(px, py), lineWidth,
    color(255-red(col), 255-green(col), 255-blue(col)), texture);
  s.movePerpendicuarToGradient(20, blurred);
  s.draw();
}

void createDebugStroke() {
  // HINT: Use this to debug your stroke rendering.
  background(255);
  Stroke s = new Stroke(new PVector(100, 100), 30, color(255, 0, 0), texture);
  s.addPoint(100, 100); //top left corner 
  s.addPoint(200, 100); //top right corner
  s.addPoint(200, 200); //bottom right corner
  s.addPoint(100, 200); //bottom left corner

  s.draw();
}

/////////////////////////////////////////////////////////

void settings() {
  // inp = loadImage("rampe.png");
  inp = loadImage("flower2.jpg");
  inp.resize(1000, 0);
  size(inp.width, inp.height, P3D);
}

void setup() {
  surface.setResizable(false);
  texture = loadImage("data/brush.png");

  strokes = new ArrayList<Stroke>(1000);

  blurred = inp.copy();
  blurred.filter(BLUR, lineWidth / 2);

  background(255);
  noFill();
  noStroke();
  textureMode(IMAGE);
}

////////////////////////////////////////////////////////

void draw() {
  if (mode == 0) createACoupleOfStrokes(50);
  if (mode == 1) createStrokeAtMousePosition();
  if (mode == 2) createDebugStroke();
}

////////////////////////////////////////////////////////

void keyPressed() {
  if (key == '0') mode = 0;
  if (key == '1') mode = 1;
  if (key == '2') mode = 2;
  if (key == 'd') {
    strokeDebug = !strokeDebug;
    if (strokeDebug) {
      stroke(0);
    } else {
      noStroke();
    }
  }
  if (key == 's') {
    save("painting.png");
  }
  if (key == 'w') {
    startOnWhite = !startOnWhite;
  }
  if (key == '-') lineWidth /= 1.5;
  if (key == '+') lineWidth *= 1.5;
}
