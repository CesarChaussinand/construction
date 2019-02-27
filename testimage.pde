import beads.*;
import org.jaudiolibs.beads.*;

import processing.serial.*;
import processing.io.*;

  Serial myPort;
  int lf = 10;
  int vit;
  int vitTable[][];

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
  
  float maxRate;
  float xScale;
  int glideTime;
  int loopLenght;

void setup(){
  bandNumber = 12;
  bandSel = 0;
  maxRate = 2;
  xScale = 2;
  glideTime = 80;
  loopLenght = 100;
  
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[1],38400);
  myPort.bufferUntil(lf);
  
  size(640,480);
  
  GPIO.pinMode(2,GPIO.INPUT_PULLUP);
  GPIO.attachInterrupt(2, this, "pinEvent", GPIO.FALLING);
  
  ac = new AudioContext();
  img = new PImage[bandNumber];
  cursor = new int[bandNumber];
  soundName = new String[bandNumber];
  sound = new SamplePlayer[bandNumber];
  attenuateur = new Gain[bandNumber];
  gain = new Glide[bandNumber];
  rate = new Glide[bandNumber];
  vitTable = new int[bandNumber][loopLenght];
  
  for (int i=0; i<(bandNumber); i++){
    img[i]= loadImage("img/" + str(i) + ".png");
    cursor[i] = 0;
    
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
    rate[i] = new Glide(ac, 0.0, glideTime);
    sound[i].start();
  }

  ac.start();
}
 

void draw() {
  background(0); 
  point = (point + 1 ) % loopLenght;
    
  for(int i = 0; i<bandNumber;i++){
    if(i==bandSel){gain[i].setValue(1.0);
      rate[i].setValue(vit*0.001*maxRate);
      sound[i].setRate(rate[i]);   
    }else{gain[i].setValue(0.6);
      rate[i].setValue(vitTable[i][point]*0.001*maxRate);
      sound[i].setRate(rate[i]);
    }
  }
  
  vitTable[bandSel][point] = vit;
  
  for (int i=0; i<bandNumber ; i++){
  image(img[i],i*width/(bandNumber+1),-cursor[i]+height*0.5,width/(bandNumber+1),img[i].height*4);
  cursor[i] = cursor[i] + int(vitTable[i][point]*0.022*xScale);  
  }
  
  noFill();
  stroke(255);
  rect(bandSel*width/(bandNumber+1),0,width/(bandNumber+1),height);
  
  stroke(255,0,0);
  line(0,height*0.5,width*bandNumber/(bandNumber+1),height*0.5);
  
  stroke(0,255,255);
  line(width*0.98,float(point)*height*0.5/loopLenght,width*0.98,(2-(float(point)/loopLenght))*height*0.5);
  
  if(point==0){
     for(int i=0;i<bandNumber;i++){
     sound[i].setPosition(000);
     cursor[i]=0;
     }
   }
}
  
void serialEvent(Serial p) {
  vit = int(float(p.readString()));
}

void pinEvent(int pin){
  
  bandSel = (bandSel + 1) % (bandNumber);
  sound[bandSel].setPosition(000);
  cursor[bandSel] = 0;
  for(int i=0; i<loopLenght; i++){
    vitTable[bandSel][i] = 0;
  }
  delay(160);
}
