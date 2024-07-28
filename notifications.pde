enum NotificationType { Wrist, Shoulder, Back}

class Notification {
   
  int timestamp;
  NotificationType type; 
  float straightness;
  float levelness;
  float heightValue; 
  float alignment; //
  float expansion; //
  float backArch; //degrees
  int priority; // 0 to 3
  String typeString;
  
  public Notification(JSONObject json) {
    this.timestamp = json.getInt("timestamp");
    //time in milliseconds for playback from sketch start
    if (json.getString("NotificationType") == null) {
      typeString = "";
    } else {
    typeString = json.getString("NotificationType");
    }
    
    
    try {
      this.type = NotificationType.valueOf(typeString);
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException(typeString + " is not a valid value for enum NotificationType.");
    }
    switch (type) {
      case Wrist:
     
        if (json.isNull("straightness")) {
          this.straightness = 0;
        } else {
          this.straightness = json.getFloat("straightness");
        }
        if (json.isNull("levelness")) {
          this.levelness = 0;
        } else {
          this.levelness = json.getFloat("levelness");
        }
        
      case Back:
        if (json.isNull("expansion")) {
          this.expansion = 0;
        } else {
          this.expansion = json.getFloat("expansion");
        }
        if (json.isNull("backArch")) {
          this.backArch = 0;
        } else {
          this.backArch = json.getFloat("backArch");
        }
        
  
    case Shoulder:
      if(json.isNull("heightValue")) {
        this.heightValue = 0;
      } else {
      this.heightValue = json.getFloat("heightValue"); //<>//
      }
      if (json.isNull("alignment")) {
        this.alignment = 0;
      } else {
         this.alignment = json.getFloat("alignment");
      }
      if (json.isNull("expansion")) {
        this.expansion = 0;
      } else {
       this.expansion = json.getFloat("expansion");
      }
       
    if (json.isNull("timestamp")) {
          this.timestamp = 0;
        } else {
        this.timestamp = json.getInt("timestamp");
        }
    if (json.isNull("priority")) {
        this.priority = json.getInt("priority");
        //1-3 levels (1 is highest, 3 is lowest)  
    }
  }
  }
  
  public int getTimestamp() { return timestamp; }
  public NotificationType getType() { return type; }
  public float getStraightness() { return straightness; }
  public float getLevelness() { return levelness; }
  public float getHeight() { return heightValue; }
  public float getAlignment() { return alignment; }
  public float getExpansion() { return expansion; }
  public float getBackArch() { return backArch; }
  public int getPriorityLevel() { return priority; }
  
  public String toString() {
      String output = getType().toString() + ": ";
      output += "(straightness: " + getStraightness() + ") ";
      output += "(levelness: " + getLevelness() + ") ";
      output += "(height: " + getHeight() + ") ";
      output += "(alignment: " + getAlignment() + ") ";
      output += "(expansion: " + getExpansion() + ") ";
      output += "(backArch: " + getBackArch() + ") ";
      output += "(priority: " + getPriorityLevel() + ") ";
      return output;
    }
}
