PImage inp, canvas;
ArrayList<Stroke> strokes;

int mode = 0;
float radius = 20;

//////////////////////////////////////////////////////////
//                 +++ IMPORTANT +++                    //
// There is not much to do in this file. The tasks are  //
// in the Stroke class, in the file next door ->        //
//////////////////////////////////////////////////////////

// HINT: Linux users might encounter rendering issues (Black window or broken patterns)
// This is due to processing being suprisingly buggy. In this case restarting processing 
// or trying to start the sketch multiple times can help. 

// HINT: use the mode switch to toggle between drawing lots of strokes and just one stroke
// at your mouse location so you can debug your strokes. (Mode 1 and 2)

void createACoupleOfStrokes(int noStrokes) {

  for (int i = 0; i < noStrokes; i++) {

    int px = (int)random(0, inp.width-1);
    int py = (int)random(0, inp.height-2);
    color col = inp.pixels[px + py*inp.width];
    
    Stroke s = new Stroke(new PVector(px, py), radius, col);
    s.movePerpendicuarToGradient(20, inp); 

    strokes.add(s);
   
    s.draw();
  }
}

void createStrokeAtMousePosition() { 
  background(inp);
  int px = (int)mouseX;
  int py = (int)mouseY;
  color col = inp.pixels[px + py*inp.width];
  Stroke s = new Stroke(new PVector(px, py), radius, 
                   color(255-red(col), 255-green(col), 255-blue(col)));
  s.movePerpendicuarToGradient(20, inp); 
  s.draw();
}

void setup() {

  inp = loadImage("kosovo.jpeg");
  
  PGraphics f = createGraphics(inp.width, inp.height);
  f.beginDraw();
  f.image(inp, 0, 0);
  f.filter(BLUR);
  f.endDraw();
  inp = f.get();
  
  inp.resize(1000,0);
  size(10,10);
  surface.setResizable(true);
  surface.setSize(inp.width, inp.height);

  strokes = new ArrayList<Stroke>(1000);
  
  background(255);
  noFill();
  strokeCap(ROUND);
  strokeJoin(ROUND);
}

void draw() {
  if (mode == 0) createACoupleOfStrokes(100);
  if (mode == 1) createStrokeAtMousePosition();
}

void keyPressed() {
  if (key == '0') mode = 0; // Normal rendering of many strokes
  if (key == '1') mode = 1;  // Renders only single strokes as mouse position for debugging
  if (key == '-') radius /= 1.5; // Increase or decrease brush radius
  if (key == '+') radius *= 1.5;
  if (key == 's') save("output.png");
}
