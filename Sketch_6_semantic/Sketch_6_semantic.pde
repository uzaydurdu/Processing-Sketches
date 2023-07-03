PImage inp, canvas, semantic_map;
ArrayList<Stroke> strokes;
ArrayList<SemanticClass> semantic_classes;

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
// at your mouse location so you can debug your strokes.

SemanticClass getClass(int px, int py) {
  color semantic_label = semantic_map.pixels[px + py * semantic_map.width];  //<>//
    SemanticClass found_class = null;
    for (int sem_index = 0; sem_index < semantic_classes.size(); ++sem_index) { 
      if (semantic_classes.get(sem_index).getLabelRGB() == semantic_label) {
        found_class = semantic_classes.get(sem_index);
      }
    }
    return found_class;
}

void createACoupleOfStrokes(int noStrokes) {

  for (int i = 0; i < noStrokes; i++) {

    int px = (int)random(0, inp.width-1);
    int py = (int)random(0, inp.height-2);
    color col = inp.pixels[px + py*inp.width];
    
    SemanticClass new_class = getClass(px, py);
    if (new_class == null) {
      new_class = new SemanticClass();
    }
    
    Stroke s = new Stroke(new PVector(px, py), radius, col, new_class);
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
                   color(255-red(col), 255-green(col), 255-blue(col)), getClass(px, py));
  s.movePerpendicuarToGradient(20, inp); 
  s.draw();
}

void loadData() {
  JSONObject semantics_json;
  try {
    semantics_json = loadJSONObject("semantic_map.json");
  } catch(RuntimeException e) {
    println("JSON PArsing failed:"); // TODO: MEssage
    return;
  }
  
  String semantic_map_filename = semantics_json.getString("semantic_map_filename");
  semantic_map = loadImage(semantic_map_filename);
  semantic_map.loadPixels();
  println("W:" + semantic_map.width);
  println("H:" + semantic_map.height);
  
  JSONArray semantic_classes_json = semantics_json.getJSONArray("semantic_data");
  ArrayList<SemanticClass> loaded_classes = new ArrayList<SemanticClass>();
  
  for(int class_index = 0; class_index < semantic_classes_json.size(); ++class_index) {
    JSONObject semantic_class_json = semantic_classes_json.getJSONObject(class_index);
    SemanticClass new_class = new SemanticClass();
    new_class.fromJSON(semantic_class_json);
    loaded_classes.add(new_class);
    println("Loaded semantic class: " + new_class.getName()); 
  }
  
  semantic_classes = loaded_classes;
}

void setup() {

  inp = loadImage("flower_big.jpg");
  size(10,10);
  surface.setResizable(true);
  surface.setSize(inp.width, inp.height);
  surface.setResizable(false);

  strokes = new ArrayList<Stroke>(1000);
  
  background(255);
  noFill();
  strokeCap(ROUND);
  strokeJoin(ROUND);
  
  loadData();
}

void draw() {
  if (mode == 0) createACoupleOfStrokes(100);
  if (mode == 1) createStrokeAtMousePosition();
}

void keyPressed() {
  if (key == '0') mode = 0; 
  if (key == '1') mode = 1; 
  if (key == '-') radius /= 1.5;
  if (key == '+') radius *= 1.5;
  if (key == 's') save("output.png");
}
