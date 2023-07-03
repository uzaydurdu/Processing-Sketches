class Stroke {
  ArrayList<PVector> pointList;

  float strokeWidth;
  color strokeColor;
  final int colorMaxDiff = 50;

  // Strokes cannot be default constructed (no arguments): A position is always present!
  Stroke(PVector pp, float pwid, color pcol) {
    strokeColor = pcol; 
    strokeWidth = pwid;
    pointList = new ArrayList<PVector>();
    pointList.add(pp);
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
    // TODO; Draw all points in pointList using the line() function of processing.
    // You should connect adjacent points with a line so you get a pattern like this:
    // o---o---o---o- ... -o
    // where each "o" is a control point and --- the line between them.
    
    for (int i = 0; i < pointList.size() - 1; i++) {
      PVector current = pointList.get(i);
      PVector next = pointList.get(i + 1);
      if(next != null){
        line(current.x, current.y, next.x, next.y);
      }
      else{
        break;
      }
      
    }
  }
  
  int getColorDiff(color c1, color c2) {
    
    int r1 = (int) red(c1);
    int g1 = (int) green(c1);
    int b1 = (int) blue(c1);
    int r2 = (int) red(c2);
    int g2 = (int) green(c2);
    int b2 = (int) blue(c2);

    int dr = r2 - r1;
    int dg = g2 - g1;
    int db = b2 - b1;

    return (int) sqrt(dr * dr + dg * dg + db * db);
  }

  void movePerpendicuarToGradient(int steps, PImage inp) {
    // TODO: call growStroke exactly step times in order to enlarge the stroke.
    // If growStroke returns (-1, -1), i.e. it has found no gradient, abort the stroke.
    // Keep track of the color at the start of the stroke and if the error exceeds 
    // colorMaxDiff, also abort the stroke.
    // HINT: Beware of strokes which go out of bounds.
    // HINT: use color c = inp.get(x, y) to get the color at a pixel location
    // HINT: use red() green() and blue() to get the corresposning color channel from a color
    // HINT: use sqrt() to get a square root.
    
    PVector startingPoint = pointList.get(0);
    color startColor = inp.get((int)startingPoint.x, (int)startingPoint.y);
    
    for(int i = 0; i<steps; i++){
      PVector nextPoint = growStroke(inp);
      
      if (nextPoint.x == -1 && nextPoint.y == -1) {
        break;
      }
      
      color currentColor = inp.get((int)nextPoint.x, (int)nextPoint.y);
      
      int colorError = getColorDiff(startColor, currentColor);
      
      if(colorError > colorMaxDiff){
        break;
      }
      
      if (nextPoint.x < 0 || nextPoint.x >= inp.width || nextPoint.y < 0 || nextPoint.y >= inp.height) {
        break;
      }
      
      addPoint(nextPoint);
    }
  }


  PVector growStroke(PImage inp) {
    // TODO: Extend te stroke by figuring out where the next point shall be located
    // 1) get the last point of this stroke
    // 2) Compute the local gradient at the curent location. Implement a sobel operator for this. You can use 
    //    brightness(inp.pixels[x + y * w]) to get the brightness easily at a point x, y.
    // 3) Move orthogonally to the gradient and movy by stepSize to a new position. Add this to the point list.
    // 4) Return the location you find or (-1, -1) if you have gradient of magnitude 0. 
    //
    // HINT: Beware of PVector.add() and related functions! If you intend to add vectors a and b to get c, writing
    // PVector c = a.add(b); then c will be a reference to a! To get the intended behaviour use c = PVector.add(a, b);
    // HINT: you can use constrain(min, max) to clamp a value to some bounds
    // HINT: Define a step size in relation to the stroke width, e.g. 1/2 or 1/4
    
    
    PVector lastPoint = pointList.get(pointList.size() - 1);
    int w = inp.width;
    int h = inp.height;
 
    int[][] sobelX = {
      {-1, 0, 1},
      {-2, 0, 2},
      {-1, 0, 1}
     };
    
    int[][] sobelY = {
      {-1, -2, -1},
      {0, 0, 0},
      {1, 2, 1}
    };
    
    float gx = 0;
    float gy = 0;
    
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            int x = (int) lastPoint.x + i;
            int y = (int) lastPoint.y + j;
            float brightness = brightness(inp.pixels[constrain(x + y * w, 0, w*h-1)]);
            
            gx += sobelX[i + 1][j + 1] * brightness;
            gy += sobelY[i + 1][j + 1] * brightness;
        }
    }
    
    float stepSize = strokeWidth / 4.0f;
    

    //float newX = lastPoint.x - stepSize * gy;
    //float newY = lastPoint.y + stepSize * gx;
    
    float orthogonalX = -gy;
    float orthogonalY = gx;


    PVector orthogonal = new PVector(orthogonalX, orthogonalY);
    orthogonal.normalize();
    

   // PVector newPoint = new PVector(newX, newY);
    PVector newPoint = PVector.add(lastPoint, PVector.mult(orthogonal, stepSize));

    pointList.add(newPoint);

    if (gx == 0 && gy == 0) {
        return new PVector(-1, -1);
    } else {
        return newPoint;
    }
  }

}
