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

void setup(){
  bandNumber = 9;
  bandSel = 0;
  
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
  vitTable = new int[bandNumber][180];
  
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
  
  rate[i] = new Glide(ac, 0.0, 100);
  sound[i].start();
  }

ac.start();
}
 

void draw() {
  background(0); 
  point = (point + 1 ) % 180;
    
  
  for(int i = 0; i<(bandNumber);i++){
    if(i==bandSel){gain[i].setValue(1.0);
    rate[i].setValue(vit*0.002);
    sound[i].setRate(rate[i]);   
   }else{gain[i].setValue(0.5);
       rate[i].setValue(vitTable[i][point]*0.002);
       sound[i].setRate(rate[i]);}
  }
  
  if (GPIO.digitalRead(2)==0){
  }else{
  }
  
  vitTable[bandSel][point] = vit;
  
  for (int i=0; i<9 ; i++){
  image(img[i],i*width*0.1,-cursor[i]+height*0.5,width*0.1,img[i].height*4);
  cursor[i] = cursor[i] + int(vitTable[i][point]*0.08);  
}
  
  noFill();
  stroke(255);
  rect(bandSel*width*0.1,0,width*0.1,height);
  
  stroke(255,0,0);
  line(0,height*0.5,width*0.9,height*0.5);
  
  stroke(0,255,255);
  
  line(width*0.95,((float(point)/90)-1)*height,width*0.95,(float(point)/90)*height);
  
}
  
void serialEvent(Serial p) {
  vit = int(float(p.readString()));
}

void pinEvent(int pin){
  
  bandSel = (bandSel + 1) % (bandNumber);
  sound[bandSel].setPosition(000);
  cursor[bandSel] = 0;
  for(int i=0; i<180; i++){
    vitTable[bandSel][i] = 0;
  }
  delay(200);
 
}
