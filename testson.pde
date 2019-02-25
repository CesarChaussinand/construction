import beads.*;
String fichier;
AudioContext contexte;
SamplePlayer player;
Gain attenuateur;
Glide gain;

void setup() {

  contexte = new AudioContext();
  size(640,480);
  frameRate(30);

  fichier = SketchPath("") + "2ext3sec.wav";
  
  try{
    player = new Sampleplayer(contexte, new Sample(fichier));
  }catch(Exception e){
    println("Exception while attempting to load sample!");
    e.printStackTrace();
    exit();
  }
  
  player.setKillOnEnd(false);
  gain = new Glide(contexte,0.8,50);
  attenuateur = new Gain(contexte,1,gain);
  
  attenuateur.addInput(player);
  contexte.out.addInput(attenuateur);
  contexte.start();
}

void mousePressed(){
  sp.setToLoopStart();
  sp.start();
}


void draw() {
  
  background(0);
}
