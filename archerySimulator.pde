import controlP5.*;

import beads.*;
import org.jaudiolibs.beads.*;
import controlP5.*;
import java.util.*;



ControlP5 p5;

int waveCount = 10;
float baseFrequency = 440.0;
Buffer CosineBuffer = new CosineBuffer().getDefault();

// Array of Glide UGens for series of harmonic frequencies for each wave type (fundamental wave, square, triangle, sawtooth)
Glide[] waveFrequency = new Glide[waveCount];
// Array of Gain UGens for harmonic frequency series amplitudes (i.e. baseFrequency + (1/3)*(baseFrequency*3) + (1/5)*(baseFrequency*5) + ...)
Gain[] waveGain = new Gain[waveCount];
Gain masterGain;
Glide masterGainGlide;
// Array of wave wave generator UGens - will be summed by masterGain to additively synthesize square, triangle, sawtooth waves
WavePlayer[] waveTone;

boolean presetting = true;
boolean shoulder = false;
boolean wrist = false;
boolean back = false;

Button startEventStream;
Button pauseEventStream;
Button stopEventStream;

Button wristButton;
Button shoulderButton;
Button backButton;
Button presetButton;
Button shootButton;

Slider straightnessSlider;
Slider levelnessSlider;
Slider heightSlider;
Slider alignmentSlider;
Slider expansionSlider;
Slider backArchSlider;

Slider presetStraightnessSlider;
Slider presetLevelnessSlider;
Slider presetHeightSlider;
Slider presetAlignmentSlider;
Slider presetExpansionSlider;
Slider presetBackArchSlider;

float presetStraightnessValue;
float presetLevelnessValue;
float presetHeightValue;;
float presetAlignmentValue;
float presetExpansionValue;
float presetBackArchValue;

float straightnessValue;
float levelnessValue;
float heightValue;;
float alignmentValue;
float expansionValue;

Gain clickGain;
Gain beepGain;
Gain soundGain;
Gain levelGain;
Gain chantGain;

SamplePlayer beepPlayer;
SamplePlayer clickPlayer;
SamplePlayer chantPlayer;

WavePlayer levelnessPlayer;
BiquadFilter filter;
BiquadFilter chantFilter;
WavePlayer alignmentPlayer;
Glide soundGainGlide;
Glide cutoffGlide;
Glide levelGlide;
Glide heightGlide;


Comparator<Notification> comparator;
PriorityQueue<Notification> queue;
Notification notification;
NotificationListener notificationListener;





//to use text to speech functionality, copy text_to_speech.pde from this sketch to yours
//example usage below

//IMPORTANT (notice from text_to_speech.pde):
//to use this you must import 'ttslib' into Processing, as this code uses the included FreeTTS library
//e.g. from the Menu Bar select Sketch -> Import Library... -> ttslib

TextToSpeechMaker ttsMaker; 

//<import statements here>

//to use this, copy notification.pde, notification_listener.pde and notification_server.pde from this sketch to yours.
//Example usage below.

//name of a file to load from the data directory
String eventDataJSON2 = "scen1.json";
String eventDataJSON1 = "scen2.json";

NotificationServer notificationServer;
ArrayList<Notification> notifications;

//MyNotificationListener myNotificationListener;

void setup() {
  size(600,400);
  p5 = new ControlP5(this);
  //float waveIntensity = 1.0;
  
  ac = new AudioContext(); //ac is defined in helper_functions.pde
  
  masterGainGlide = new Glide(ac, .2, 200); 
  heightGlide = new Glide(ac, .2, 0);
  masterGain = new Gain(ac, 1, masterGainGlide);
  soundGainGlide = new Glide(ac, 1.0, 0);
  soundGain = new Gain(ac, 1, soundGainGlide);
  levelGlide = new Glide(ac, 1.0, 00);
  masterGain.addInput(soundGain);
  
  
  waveTone = new WavePlayer[waveCount];
  levelGain = new Gain(ac, 1, levelGlide);
  
  chantFilter = new BiquadFilter(ac, BiquadFilter.AP, heightGlide, 0.5f);
  
  
  
    // create a comparator to keep queued items in priority order
  Comparator<Notification> priorityComp = new Comparator<Notification>() {
    public int compare(Notification n1, Notification n2) {
      return min(n1.getPriorityLevel(), n2.getPriorityLevel());
    }
  };
  
  queue = new PriorityQueue<Notification>(10, priorityComp);

 // Load the beep sound
    try {
        beepPlayer =  getSamplePlayer("beep.wav");
    } catch (Exception e) {
        e.printStackTrace();
        return;
    }
    
    // Create a SamplePlayer for the beep sound
    //SamplePlayer beepPlayer = new SamplePlayer(ac, beepSample);
    beepGain = new Gain(ac, 1, 0);
    // Set the gain (volume) for the beep sound
    beepGain.addInput(beepPlayer);
    masterGain.addInput(beepPlayer);
    
    // Add the beepPlayer to the audio context
    ac.out.addInput(beepPlayer);
    beepPlayer.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    
 // Load the chant sound
        chantPlayer =  getSamplePlayer("chant.wav");
    
    
    // Create a SamplePlayer for the chant sound
    //SamplePlayer beepPlayer = new SamplePlayer(ac, beepSample);
    chantGain = new Gain(ac, 1, 0);
    // Set the gain (volume) for the beep sound
    chantGain.addInput(chantPlayer);
    masterGain.addInput(chantPlayer);
    masterGain.addInput(chantGain);
    
    // Add the beepPlayer to the audio context
    
    //chantPlayer.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);

//load the click sound
  try {
    SamplePlayer click = getSamplePlayer("click.wav");
    clickGain = new Gain(ac, 1, 0); 

// Connect the SamplePlayer to the Gain
  clickGain.addInput(click);
// Add the Gain to the audio context output
  ac.out.addInput(clickGain);
  }catch(Exception e){
 // If there is an error, print the steps that got us to
 // that error.
 e.printStackTrace();
 }
  //this will create WAV files in your data directory from input speech 
  //which you will then need to hook up to SamplePlayer Beads
  cutoffGlide = new Glide(ac, 1500.0, 50);
   filter = new BiquadFilter(ac, BiquadFilter.AP, cutoffGlide, 0.0f);
   filter.addInput(beepPlayer);
    
  alignmentPlayer = new WavePlayer(ac, 200, Buffer.SINE);
  soundGain.addInput(alignmentPlayer);
  
  filter.addInput(beepGain);
  filter.addInput(beepPlayer);
  //soundGain.addInput(filter);
  
  ac.out.addInput(masterGain);
  filter.setQ(1); // Set the filter Q value (bandwidth)
  filter.setGain(0); // Set the gain (in dB)
  
  levelnessPlayer = new WavePlayer(ac, 300, Buffer.SINE);
  levelnessPlayer.addInput(filter);
  ac.out.addInput(levelnessPlayer);
  levelGain.addInput(levelnessPlayer);
  ac.out.addInput(filter);
  
  //START NotificationServer setup
  notificationServer = new NotificationServer();
  
  
  //instantiating a custom class (seen below) and registering it as a listener to the server
  notificationListener = new MyNotificationListener();
  notificationServer.addListener(notificationListener);
    
  //END NotificationServer setup
  
  startEventStream = p5.addButton("startEventStream")
    .setPosition(40,20)
    .setSize(150,20)
    .setLabel("Start Event Stream");
    
  startEventStream = p5.addButton("pauseEventStream")
    .setPosition(40,60)
    .setSize(150,20)
    .setLabel("Pause Event Stream");
 
  startEventStream = p5.addButton("stopEventStream")
    .setPosition(40,100)
    .setSize(150,20)
    .setLabel("Stop Event Stream");

  wristButton = p5.addButton("wristButton").setPosition(40, 150).setSize(150,20).setLabel("Wrist").activateBy((ControlP5.RELEASE));
  shoulderButton = p5.addButton("shoulderButton").setPosition(40, 190).setSize(150,20).setLabel("Shoulder").activateBy((ControlP5.RELEASE));
  backButton = p5.addButton("backButton").setPosition(40, 230).setSize(150,20).setLabel("Back").activateBy((ControlP5.RELEASE));
  presetButton = p5.addButton("createPreset").setPosition(40, 270).setSize(150,20).setLabel("Edit Preset").activateBy((ControlP5.RELEASE));
  shootButton = p5.addButton("shootTTS").setPosition(40, 310).setSize(150,20).setLabel("Shoot").activateBy((ControlP5.RELEASE));
  
  //slider for the notification system to move the sounds
  //s[0] = p5.addSlider("frequencySlider").setPosition(410, 50).setSize(180, 15).setRange(55, 3520).setValue(frequency).setLabel("F").hide();
  straightnessSlider = p5.addSlider("straightnessSlider").setPosition(280, 70).setSize(180, 15).setRange(-3, 3).setValue(0).setLabel("Straightness").hide();
  levelnessSlider = p5.addSlider("levelnessSlider").setPosition(280, 90).setSize(180, 15).setRange(-5, 5).setValue(0).setLabel("Levelness").hide();
  heightSlider = p5.addSlider("heightSlider").setPosition(280, 110).setSize(180, 15).setRange(-5, 5).setValue(0).setLabel("Height").hide();
  alignmentSlider = p5.addSlider("alignmentSlider").setPosition(280, 130).setSize(180, 15).setRange(-180, 180 ).setValue(0).setLabel("Alignment").hide();
  expansionSlider = p5.addSlider("expansionSlider").setPosition(280, 150).setSize(180, 15).setRange(0, 10).setValue(0).setLabel("Expansion").hide();
  backArchSlider = p5.addSlider("backArchSlider").setPosition(280, 170).setSize(180, 15).setRange(-180, 180).setValue(0).setLabel("Back Arch").hide();
  
  presetStraightnessSlider = p5.addSlider("presetStraightnessSlider").setPosition(280, 70).setSize(180, 15).setRange(-3, 3).setValue(0).setLabel("Preset Straightness").show();
  presetLevelnessSlider = p5.addSlider("presetLevelnessSlider").setPosition(280, 90).setSize(180, 15).setRange(-5, 5).setValue(3).setLabel("Preset Levelness").show();
  presetHeightSlider = p5.addSlider("presetHeightSlider").setPosition(280, 110).setSize(180, 15).setRange(-5, 5).setValue(0).setLabel("Preset Height").show();
  presetAlignmentSlider = p5.addSlider("presetAlignmentSlider").setPosition(280, 130).setSize(180, 15).setRange(-180, 180 ).setValue(0).setLabel("Preset Alignment").show();
  presetExpansionSlider = p5.addSlider("presetExpansionSlider").setPosition(280, 150).setSize(180, 15).setRange(0, 10).setValue(0).setLabel("Preset Expansion").show();
  //presetBackArchSlider = p5.addSlider("presetBackArchSlider").setPosition(280, 170).setSize(180, 15).setRange(-180, 180).setValue(40).setLabel("Preset Back Arch").show();
  
  ac.start();
}

void createPreset() {
    presetting = !presetting;
  if (presetting) {
    presetStraightnessSlider.show();
    presetLevelnessSlider.show();
    presetHeightSlider.show();
    presetAlignmentSlider.show();
    presetExpansionSlider.show();
    //presetBackArchSlider.show();
    
    straightnessSlider.hide();
    levelnessSlider.hide();
    heightSlider.hide();
    alignmentSlider.hide();
    expansionSlider.hide();
    //backArchSlider.hide();
  } else {
    presetStraightnessSlider.hide();
    presetLevelnessSlider.hide();
    presetHeightSlider.hide();
    presetAlignmentSlider.hide();
    presetExpansionSlider.hide();
    //presetBackArchSlider.hide();
    
    straightnessSlider.show();
    levelnessSlider.show();
    heightSlider.show();
    alignmentSlider.show();
    expansionSlider.show();
    //backArchSlider.show();
  }
}

void startEventStream(int value) {
  //loading the event stream, which also starts the timer serving events
  println(eventDataJSON1);
  notificationServer.loadEventStream(eventDataJSON1); //<>//
}

void pauseEventStream(int value) {
  //loading the event stream, which also starts the timer serving events
  notificationServer.pauseEventStream();
}

void stopEventStream(int value) {
  //loading the event stream, which also starts the timer serving events
  notificationServer.stopEventStream();
}

void shootTTS() {
  ttsMaker = new TextToSpeechMaker();
  
  String exampleSpeech = "Shoot your arrow.";
  
  ttsExamplePlayback(exampleSpeech);
}

void backButton() {
  back = !back;
}

void shoulderButton() {
  shoulder = !shoulder;
  
  if (!shoulder) {
    alignmentPlayer.pause(true);
    chantPlayer.pause(true);
  } else {
    alignmentPlayer.pause(false);
    chantPlayer.pause(false);
  }
}

void wristButton() {
  wrist = !wrist;
  
  if (!wrist) {
    levelnessPlayer.pause(true);
    beepPlayer.pause(true);
  } else {
    levelnessPlayer.pause(false);
    beepPlayer.pause(false);
  }
}


void presetStraightnssSlider(float v) {
  presetStraightnessValue = 0.0;
  
}

void presetLevelnessSlider(float v) {
  presetLevelnessValue = 3.0;
  
}

void presetHeightSlider(float v) {
  presetHeightValue = 0.0 ;
  
}

void presetAlignmentSlider(float v) {
  presetAlignmentValue = 3.0;
  
  
}

void presetExpansionSlider(float v) {
  presetExpansionValue = 5.0;
  
}

void presetBackArchSlider(float v) {
  presetBackArchValue = 40;
  
}

void straightnessSlider(float v) { //beep sharpness
  if (v != presetStraightnessValue && wrist) {
    beepPlayer.pause(false);
  Static rateStatic = new Static(ac, v); // 
       
  // Connect the Static UGen to the SamplePlayer's rate input
  beepPlayer.setRate(rateStatic);
  println("if");
  
  } else {
       
    beepPlayer.pause(true);
    println("else");
    
  }
}

void levelnessSlider(float v) { //sharper or flatter
  if (v != presetLevelnessValue && wrist) {
    levelnessPlayer.pause(false);
    filter.setGain(abs(v) * 100);
    println(abs(v)* 100);
    
  } else {
    filter.setGain(0);
    levelGain.setValue(0);
    levelnessPlayer.pause(true);
    
  }
}

void heightSlider(float v) { //singing get louder or quieter
    if (v != presetHeightValue && shoulder) {
      chantPlayer.pause(false);
      //chantPlayer.setValue(abs(v - presetHeightValue));
      chantFilter.setGain(v);
      chantGain.setGain(abs(v - presetHeightValue));
      
    } else {
      chantPlayer.pause(true);
    }
}


void alignmentSlider(float v) { //gets louder / quieter
    if (v != presetAlignmentValue && shoulder) {
      alignmentPlayer.pause(false);
      soundGain.setGain(abs( v - presetAlignmentValue) );
      println(abs(v - presetAlignmentValue));
    
    } else {
      alignmentPlayer.pause(true);
    }
    
}

void expansionSlider(float v) { //click
  if (v != presetExpansionValue && back) {
    clickGain.setGain(1);
  }

}


void draw() {
  //this method must be present (even if empty) to process events such as keyPressed()  
  background(0);
    // check to see if events are in the queue, if so sonify them
  notification = queue.poll();
  
  if (notification != null) {
    // sonify based on type, priority, queue.size(), etc.
  }
}

void keyPressed() {
  //example of stopping the current event stream and loading the second one
  if (key == RETURN || key == ENTER) {
    notificationServer.stopEventStream(); //always call this before loading a new stream
    notificationServer.loadEventStream(eventDataJSON2);
    println("**** New event stream loaded: " + eventDataJSON2 + " ****");
  }
    
}

//in your own custom class, you will implement the NotificationListener interface 
//(with the notificationReceived() method) to receive Notification events as they come in
//in your own custom class, you will implement the NotificationListener interface
        
class MyNotificationListener implements NotificationListener {
  
  public MyNotificationListener() {
    //setup here
    
  }
  
  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    queue.add(notification);
    println("<Example> " + notification.getType().toString() + " notification received at " 
    + Integer.toString(notification.getTimestamp()) + " ms");
    
    String debugOutput = ">>> ";
    switch (notification.getType()) {
      case Wrist:
        debugOutput += "wrist: ";
        straightnessSlider.setValue(notification.getStraightness());
        levelnessSlider.setValue(notification.getLevelness());
        
        break;
      case Shoulder:
        debugOutput += "shoulder: ";
        heightSlider.setValue(notification.getHeight());
        alignmentSlider.setValue(notification.getAlignment());
        
        break;
      case Back:
        debugOutput += "back: ";
        expansionSlider.setValue(notification.getExpansion());
        backArchSlider.setValue(notification.getBackArch());
        break;
      
    }
    debugOutput += notification.toString();
    //debugOutput += notification.getLocation() + ", " + notification.getTag();
    
    println(debugOutput);
    
   //You can experiment with the timing by altering the timestamp values (in ms) in the exampleData.json file
    //(located in the data directory)
  }
}

void ttsExamplePlayback(String inputSpeech) {
  //create TTS file and play it back immediately
  //the SamplePlayer will remove itself when it is finished in this case
  
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  
  //createTTSWavFile makes a new WAV file of name ttsX.wav, where X is a unique integer
  //it returns the path relative to the sketch's data directory to the wav file
  
  //see helper_functions.pde for actual loading of the WAV file into a SamplePlayer
  
  SamplePlayer sp = getSamplePlayer(ttsFilePath, true); 
  //true means it will delete itself when it is finished playing
  //you may or may not want this behavior!
  
  ac.out.addInput(sp);
  sp.setToLoopStart();
  sp.start();
  println("TTS: " + inputSpeech);
}
