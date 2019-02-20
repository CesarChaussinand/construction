import processing.serial.*;
import processing.io.*;
//import oscP5.*;
//import netP5.*;

//NetAdress local;
//OscP5 oscP5;

Serial myPort;
PImage img;
int x;
float val=0;
int lf = 10;
float rate;
int cursor = 0;
float vit;
int bandSel;

void setup() {
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[1],38400);
  myPort.bufferUntil(lf);
  img = loadImage("2ext3sec.png");
  size(640,480);
  x = 0;
  frameRate(30);
  GPIO.pinMode(2,GPIO.INPUT_PULLDOWN);
  GPIO.attachInterrupt(2, this, "pinEvent", GPIO.FALLING);
  
  bandSel = 0;
//vit = - int(img.width / (file.duration()*25));

//  oscP5 = new OscP5(this, 12000);
 // local = NetAdress(127.0.0.1,12000);
}

void draw() {
 // OscMessage msg = new OscMessage("/input/vitesse");
  //msg.add(val);
  //oscP5.send(msg,local);
  
  
  background(0);
  //image(img,cursor+width*0.5,0,img.width,height*0.2);
  //image(img,0,height*0.2,img.width,height*0.2);
//  x = x + val;
  val = val + (mouseX-width*0.5);
  stroke(255);
  noFill();
  rect(bandSel*width*0.1,0,width*0.1,height);
 
  stroke(255,0,0);
  line(width*0.5,0,width*0.5,height*0.2);
 
 text (bandSel, 100, 50);
  cursor = cursor + int(vit*0.02) ;
}


void serialEvent(Serial p) {
  vit = float(p.readString());
}

void pinEvent (int pin){
  GPIO.noInterrupts();
 bandSel = (bandSel + 1) % 10;
 delay(100);
 GPIO.interrupts();
}
/*
PImage img2 = createImage(200,200,RGB);
tint(255,120,0,127);
image(img2,0,0);

float[] octave = { 
  0.25, 0.5, 1.0, 2.0, 4.0
};
*/
