enum EStyle {
  DEFAULT,
  DOTTED,
  LINES,
  THIN,
  THICK
}

class SemanticClass {
  String className;
  EStyle classStyle;
  color label_rgb;
  
  SemanticClass() {
    className = "Undefined";
    classStyle = EStyle.DEFAULT;
    label_rgb = #000000;
  }
  
  void fromJSON(JSONObject semantic_class) {
    className = semantic_class.getString("class");
    String classStyleString = semantic_class.getString("style");
    
    println(classStyleString);
    if (classStyleString.equals("default")) {
      classStyle = EStyle.DEFAULT;
    } else if (classStyleString.equals("dotted")) {
      classStyle = EStyle.DOTTED;
    } else if (classStyleString.equals("lines")) {
      classStyle = EStyle.LINES;
    } else if (classStyleString.equals("thin")) {
      classStyle = EStyle.THIN;
    } else if (classStyleString.equals("thick")) {
      classStyle = EStyle.THICK;
    } else {
      println("Unknown Style: " + classStyleString);
      classStyle = EStyle.DEFAULT;
    }
    
    JSONArray class_rgb_json = semantic_class.getJSONArray("color");
    int class_r = class_rgb_json.getInt(0);
    int class_g = class_rgb_json.getInt(1);
    int class_b = class_rgb_json.getInt(2);
    label_rgb = color(class_r, class_g, class_b);
  }
  
  String getName() {
    return className;
  }
  
  color getLabelRGB() {
    return label_rgb;
  }
  
  EStyle getStyle() {
    return classStyle;
  }
}
