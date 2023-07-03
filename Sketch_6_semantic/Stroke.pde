class Stroke {
  ArrayList<PVector> pointList;
  float strokeWidth;
  float stepSize;
  color strokeColor;
  SemanticClass semantic_class;
  int colorMaxDiff = 50;
  

  // Strokes cannot be default constructed (no arguments): A position is always present!
  Stroke(PVector start_pos, float s_width, color s_color, SemanticClass semantic_info) {
    strokeColor = s_color; 
    strokeWidth = s_width;
    stepSize = strokeWidth/4;
    semantic_class =  semantic_info; //<>//
    pointList = new ArrayList<PVector>();
    pointList.add(start_pos);
  }

  void addPoint(PVector pp) {
    pointList.add(pp);
  }

  void addPoint(float px, float py) {
    pointList.add(new PVector(px, py));
  }

  void setRadius(float pr) {
    strokeWidth = pr;
  }

  void setColor(color pcol) {
    strokeColor = pcol;
  }


  void draw() {
    stroke(strokeColor);
    strokeWeight(strokeWidth); 
    for (int i = 1; i < pointList.size(); ++i) {
      line(pointList.get(i-1).x, pointList.get(i-1).y, 
        pointList.get(i).x, pointList.get(i).y);
    }
  }

  void movePerpendicuarToGradient(int steps, PImage inp) {
    int actX = (int)round(pointList.get(pointList.size()-1).x);
    int actY = (int)round(pointList.get(pointList.size()-1).y);
    color col = inp.get(actX, actY);
    
    // TODO: Add a switch statement here to modify stroke parameters based on 
    // the info in semantic_class //<>//
    
    for (int i = 0; i < steps; i++) {
      PVector nextPos = growStroke(inp, semantic_map);

      if (nextPos == null) {
        // no gradient!
        break;
      }
  
      switch(semantic_class.getStyle()){
          case DEFAULT: strokeWidth = 20;
                     break;
          case DOTTED: strokeWidth = 10;
                     break;
          case LINES: strokeWidth = 20;
                     break;
          case THIN: strokeWidth = 5;
                     break;
          case THICK: strokeWidth = 30;
                     break;
      }
    
      color actC = inp.get(round(nextPos.x), round(nextPos.y));

      // if color changes too much along the stroke
      if (sqrt(sq(red(col)-red(actC)) + sq(green(col)-green(actC)) + sq(blue(col)-blue(actC))) > colorMaxDiff) {
        break;
      }
    }
  }


  PVector growStroke(PImage inp, PImage semantic_map) {
    int actX = (int)round(pointList.get(pointList.size()-1).x);
    int actY = (int)round(pointList.get(pointList.size()-1).y);
    int w = inp.width;

    actX = constrain(actX, 1, inp.width - 2);
    actY = constrain(actY, 1, inp.height - 2);

    // Gradient 
    float gx =   (brightness(inp.pixels[actX+1 + (actY-1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) + 
               2*(brightness(inp.pixels[actX+1 + (actY  )*w]) - brightness(inp.pixels[actX-1 + (actY  )*w])) +
                 (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY+1)*w]));

    float gy =   (brightness(inp.pixels[actX-1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) + 
               2*(brightness(inp.pixels[actX   + (actY+1)*w]) - brightness(inp.pixels[actX   + (actY-1)*w])) +
                 (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX+1 + (actY-1)*w]));

    // Check if any gradient exists
    float len = sqrt(sq(gx)+sq(gy));    
    if (len == 0) {
      return null;
    }

    // Normalize
    gx /= len;
    gy /= len;

    // find new postion
    float dx = -gy*stepSize;
    float dy =  gx*stepSize;
    int new_x = constrain(actX + round(dx), 1, semantic_map.width - 2);
    int new_y = constrain(actY + round(dy), 1 , semantic_map.height - 2);
    
    // TODO: Add an if to ensure this stroke never leaves its semantic class
    
    pointList.add(new PVector(new_x, new_y));

    return new PVector(actX+dx, actY+dy);
  }
}
