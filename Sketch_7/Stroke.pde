class Stroke { //<>//
  ArrayList<PVector> strokePoints;
  float strokeWidth;
  color strokeColor;
  PImage texi, _texi;
  PVector start;

  Stroke(PVector pp, float pw, color pc, PImage ptexi) {
    strokeColor = pc;
    strokeWidth = pw;
    texi = ptexi;
    start = pp;
    iniTexture();
    strokePoints = new ArrayList<PVector>();
  }

  void addPoint(PVector pp) {
    strokePoints.add(pp);
  }

  void addPoint(float px, float py) {
    strokePoints.add(new PVector(px, py));
  }

  void setRadius(float pr) {
    strokeWidth = pr;
  }

  void setColor(color pcol) {
    strokeColor = pcol;
  }

  ArrayList<PVector> getPoints() {
    return strokePoints;
  }

  void draw() {

    if (strokePoints.size()<2) return;

    float len = getStrokeLength();
    float l=0, x=0, y=0;



    beginShape(QUAD_STRIP);
    texture(_texi);
    normal(0, 0, 1); // only for lights
    for (int i = 0; i < strokePoints.size(); i++) {
      // TODO: Compute the vertices of the quad strip as shown in the lecture.
      // keep track of the length of the stroke drawn so far to map the proper
      // texture coordinates.  Use the function vertex(x, y, u, v) to create a
      // vertex for the current quad strip. The order in which you create
      // vertices is critical! If you get bowties instead of squares the order
      // is probably wrong.

      PVector point = strokePoints.get(i);
      PVector pn = null;
      PVector normal = null;
      PVector zAxis = new PVector(0, 0, 1);
      float segmentLength = 0;

      if (i == 0 || i == strokePoints.size()-1) {

        pn = PVector.sub(strokePoints.get(i == 0 ? i : i - 1), strokePoints.get(i == 0 ? i + 1: i));
        //println(strokePoints.get(i == 0 ? i : i -1) + " " + strokePoints.get(i == 0 ? i + 1: i));
        normal = new PVector(-pn.y, pn.x, 0);

        normal = pn.cross(zAxis);

        //println(strokePoints.get(0)+ " " +  strokePoints.get(strokePoints.size()-1));
      } else {
        PVector nextPoint = strokePoints.get(i+1);
        x = point.x;
        y = point.y;


        pn = PVector.sub(strokePoints.get(i-1), strokePoints.get(i+1));
        //println(point  + " " + nextPoint + " " + i + " x: " + x + " y: " + y  + " pn: " + pn );


        normal = pn.cross(zAxis);
      }

      normal.normalize();

      
      PVector newPos = PVector.add(point, PVector.mult(normal, strokeWidth));
      PVector oppPos = PVector.sub(point, PVector.mult(normal, strokeWidth));
      PVector nextPos = PVector.add(strokePoints.get(i < strokePoints.size() - 1 ? i + 1: i), PVector.mult(normal, strokeWidth));


      segmentLength = sqrt((nextPos.x - newPos.x) * (nextPos.x - newPos.x) + (nextPos.y - newPos.y) * (nextPos.y - newPos.y));
      l += segmentLength;
      println(strokePoints.get(i < strokePoints.size() - 1 ? i + 1: strokePoints.size()-1) + " " + l);
      float uNew = map(newPos.y, 0, oppPos.y, 1, strokeWidth); // Map Y coordinate to U over the width of the stroke
      float vNew = map(newPos.x, 0, oppPos.x, l, len); // Map X coordinate to V over the entire length
   
      vertex(newPos.x, newPos.y, uNew, vNew);

      float uOpp = map(oppPos.y, 0, nextPos.y, 1, strokeWidth); // Map Y coordinate to U over the width of the stroke
      float vOpp = map(oppPos.x, 0, nextPos.x, l, len); // Map X coordinate to V over the entire length
      //println(oppPos + " " + newPos + " " + l + " " + len +  " " + strokePoints.size() + " u: " +  " " + uNew + " v: "  + " " + vNew  + " " );
      vertex(oppPos.x, oppPos.y, uOpp, vOpp);
      /*
       PVector point = strokePoints.get(i);
       
       if (i < strokePoints.size() - 1) {
       PVector nextPoint = strokePoints.get(i + 1);
       float segmentLength = dist(point.x, point.y, nextPoint.x, nextPoint.y);
       l += segmentLength;
       
       }
       
       float u = map(point.y, 10, strokeWidth, 0, 1); // Map Y coordinate to U over the width of the stroke
       float v = map(point.x, 0, l, 0, 1); // Map X coordinate to V over the entire length
       vertex(point.x, point.y, u, v);
       
       // Update the length drawn so far
       println("l: " + l + " len:" + len);
       println("u: " + u + " v:" + v);*/
    }
    endShape();
  }


  float getStrokeLength() {
    float len = 0;
    for (int i = 1; i<strokePoints.size(); i++) {
      PVector p  = strokePoints.get(i);
      PVector pp = strokePoints.get(i-1);
      len += sqrt(sq(pp.x-p.x)+sq(pp.y-p.y));
    }
    return len;
  }

  int getSize() {
    return strokePoints.size();
  }


  PVector getOffsetNormal(ArrayList<PVector> pointList, int index) {

    // TODO: For the point in plist at position index, compute the
    // offset normal as discussed in the lecture. Handle the following cases:
    // 1) Index is out of bounds
    // 2) First or last point in the point list
    // 3) Indicated point has neighbors
    PVector point = null;

    if (index < pointList.size()-1) {
      point = pointList.get(index);
    }

    return new PVector();
  }



  void iniTexture() {

    if (texi == null) {
      texi = createImage(10, 10, RGB);
      for (int i=0; i<texi.width*texi.height; i++)
        texi.pixels[i]=color(0, 0, 0, 255);
    }

    // _texi has the color of the stroke color c
    // and brightness values (inverse) are mapped to alpha

    float cred = red(strokeColor);
    float cgreen = green(strokeColor);
    float cblue = blue(strokeColor);

    _texi = createImage(texi.width, texi.height, ARGB);
    for (int i=0; i<texi.width*texi.height; i++) {
      float a = 255-brightness(texi.pixels[i]);
      _texi.pixels[i]=color(cred, cgreen, cblue, a);
    }
  }


  public String toString() {
    String s = "Line [";
    for (int i = 1; i<strokePoints.size(); i++)
      s += strokePoints.get(i).toString();
    s += "] ";
    return s;
  }


  void movePerpendicuarToGradient(int steps, PImage inp) {
    strokePoints.add(start);
    PVector current = start;
    color col = inp.get(round(current.x), round(current.y));
    PVector previous = start;

    for (int i = 0; i < steps; ++i) {
      PVector next = tracePosition(inp, current);

      if (next.x == 0.0 && next.y == 0.0) {
        // nowhere to go? Go to a random place!
        next.x = current.x + random(strokeWidth / 2);
        next.y = current.y + random(strokeWidth / 2);
      }


      color actC = inp.get(round(next.x), round(next.y));

      // if color changes too much along the stroke
      if (sqrt(sq(red(col)-red(actC)) + sq(green(col)-green(actC)) + sq(blue(col)-blue(actC))) > 50) {
        break;
      }


      // TODO:
      // a ----- b
      //         /
      //        /
      //       c
      //
      // Calculate angle between the vectors b -> a and b -> (using a -> b would result in a blunt angle!)
      // a - b <- > c - b
      //
      // look at the previous, current and next point. If the angle is smaller than 45 degrees, then abort the stroke.

      PVector cn = PVector.sub(next, previous);
      PVector cp  = PVector.sub(current, next);


      float angle = PVector.angleBetween(cp, cn);
      //println(cn + " " + cp + " " + previous + " " + current + " " + next + " " + degrees(angle) );
      if (degrees(angle) < 45.0) {
        break;
      }

      previous = current;
      current = next;
      strokePoints.add(next);
    }
  }


  PVector tracePosition(PImage inp, PVector pos) {
    int actX = round(pos.x);
    int actY = round(pos.y);
    int w = inp.width;

    actX = constrain(actX, 1, inp.width-2);
    actY = constrain(actY, 1, inp.height-2);

    // Gradient
    float gx =   (brightness(inp.pixels[actX+1 + (actY-1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) +
      2*(brightness(inp.pixels[actX+1 + (actY  )*w]) - brightness(inp.pixels[actX-1 + (actY  )*w])) +
      (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY+1)*w]));

    float gy =   (brightness(inp.pixels[actX-1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) +
      2*(brightness(inp.pixels[actX   + (actY+1)*w]) - brightness(inp.pixels[actX   + (actY-1)*w])) +
      (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX+1 + (actY-1)*w]));

    // Normalize
    float len = sqrt(sq(gx) + sq(gy));
    if (len == 0) {
      return new PVector(0, 0);
    }

    gx /= len;
    gy /= len;

    // find new postion
    float stepSize = strokeWidth / 2;
    float dx = -gy*stepSize;
    float dy =  gx*stepSize;
    return new PVector(actX+dx, actY+dy);
  }
}
