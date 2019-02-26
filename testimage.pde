import beads.*;
import org.jaudiolibs.beads.*;

import processing.serial.*;
import processing.io.*;

Serial myPort;
int lf = 10;
float vit;
float vitTable[][];

PImage img[];
int cursor[];
int point;

AudioContext ac;
String soundName[];
SamplePlayer sound[];
Gain attenuateur[];
Glide gain[];
Glide rate[];

int bandSel;
int bandNumber;

void setup(){
  bandNumber = 10;
  bandSel = 0;
  
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[1],38400);
  myPort.bufferUntil(lf);
  
  size(640,480);
  frameRate(30);
  
  GPIO.pinMode(2,GPIO.INPUT_PULLUP);
  GPIO.attachInterrupt(2, this, "pinEvent", GPIO.FALLING);
 
  ac = new AudioContext();
  img = new PImage[bandNumber];
  soundName = new String[bandNumber];
  sound = new SamplePlayer[bandNumber];
  attenuateur = new Gain[bandNumber];
  gain = new Glide[bandNumber];
  rate = new Glide[bandNumber];
  vitTable = new float[bandNumber][300];
  
  for (int i=0; i<(bandNumber-1); i++){
  
  img[i]= loadImage("img/" + str(i) + ".png");
    
  soundName[i] = sketchPath("") + "sons/" + str(i) + ".wav";
  try{
    sound[i] = new SamplePlayer(ac, new Sample(soundName[i]));
  }catch(Exception e){
    println("Exception while attempting to load sample!");
    e.printStackTrace();
    exit();
  }
  
  sound[i].setKillOnEnd(false);
  
  gain[i] = new Glide(ac, 0.0, 20);
  attenuateur[i] = new Gain(ac, 1, gain[i]);
  attenuateur[i].addInput(sound[i]);
  ac.out.addInput(attenuateur[i]);
  
  rate[i] = new Glide(ac, 1.0, 100);
  sound[i].start();
  }

ac.start();
}
 

void draw() {
  background(0); 
  point = (point + 1 ) % 300;
  
  rate[bandSel].setValue(vit*0.002);
  sound[bandSel].setRate(rate[bandSel]);
  gain[bandSel].setValue(GPIO.digitalRead(2));
  if (GPIO.digitalRead(2)==0){
      
  }else{
     
  }
  
  for (int i=0; i<9 ; i++){
  image(img[i],i*width*0.1,vitTable[i][point],width*0.1,img[i].height*4);
  }
  
  text(vit,100,100);
  text(GPIO.digitalRead(2),200,100);
  text(bandSel,250,100);
  
  noFill();
  stroke(255);
  rect(bandSel*width*0.1,0,width*0.1,height);
  
}

void serialEvent(Serial p) {
  vit = float(p.readString());
}

void pinEvent(int pin){
  
  bandSel = (bandSel + 1) % bandNumber;
  delay(200);
 
}
