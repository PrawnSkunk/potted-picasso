

import twitter4j.*;
import twitter4j.api.*;
import twitter4j.auth.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.management.*;
import twitter4j.util.*;
import twitter4j.util.function.*;
import java.util.Date;
import processing.serial.*;
import java.util.List;

import gifAnimation.*;
import processing.opengl.*;

GifMaker gifExport;
PImage pic;

// Declare class objects
int numPainters = 1;
Painter[] painters = new Painter[numPainters];
Arduino arduino;
TwitterBot twitterBot;
PFont font;

// variables controlling the max and min values that get passed to the painter method for each sensor reading
// TEMPORARILY MAKING THEM GLOBAL, THEY WONT BE IN THE FUTURE, THIS IS STILL FOR TESTING
int light_low = 0;
int light_high = 500;
int temp_low = 10;
int temp_high = 250;
int moist_low = 1;
int moist_high = 50;


// boolean variables to see if sensor has been read from
boolean sensorsRead = false;
boolean painterCreated = false;
int palXPos;

int globalTimer = 0;

void setup()
{
  smooth();
  frameRate(60);
  size(300, 300);
  background(255);
  
  // temporary
  palXPos = (int)random(light_low,light_high);
  
  // Initialize class objects
  arduino = new Arduino();
  twitterBot = new TwitterBot();
  // initializing the painter with set values from arduino because you guys do not have the arduino set up - Matt
  
  for(int i=0; i<numPainters; i++){
    painters[i] = new Painter((int)random(temp_low,temp_high), (int)random(light_low,light_high), (int)random(moist_low,moist_high)); 
  }
  pic = loadImage(dataPath("image.png"));
  gifExport = new GifMaker(this, dataPath("gif.gif"));
}

void draw() 
{
  for(int f=0; f<80; f++){
    for(int i=0; i<numPainters; i++){
      if (painters[i].painting == true) {
          painters[i].paint();
          i = numPainters; // enable to make them all draw at the same time
          if (f == 0) {
              gifExport.setDelay(1);
              gifExport.addFrame();
          }
        }
      } 
    }
  
  // THIS SECTION WILL INITIALIZE THE PAINTER IF THE ARDUINO IS ACTUALLY SENDING VALUES //
  // LEAVE COMMENTED BUT DO NOT DELETE // - Matt
  
  /*
  
  // if the painter has been created then paint away
  if(painterCreated==true){
    if (painter.painting == true) {
      painter.paint();
    } 
  }
  
  if(painterCreated==false&&sensorsRead==true){ // if there isnt already a painter, create one
    println("values are: temp="+arduino.val_temp+" light="+arduino.val_light+" moist="+arduino.val_moist);
    println("painter created with temp="+(int)map(arduino.val_temp, 0, 255, temp_low, temp_high)+" light="+(int)map(arduino.val_light, 0, 255, light_low, light_high)+" moist="+(int)map(arduino.val_moist, 0, 255, moist_low,moist_high));
    painter = new Painter((int)map(arduino.val_temp, 0, 255, temp_low, temp_high), (int)map(arduino.val_light, 0, 255, light_low, light_high), (int)map(arduino.val_moist, 0, 255, moist_low,moist_high));
    painterCreated=true;
  }
  
  if (sensorsRead == false){
    arduino.initReadings();
    if(arduino.val_light>0&&arduino.val_temp>0&&arduino.val_moist>0){ // if the sensors have received values then we can begin to init the painter object
      sensorsRead=true;
    }
  }
  
  // once this timer reaches 3000 (not based on actual seconds or milliseconds) it will post to twitter
  // and then start drawing again
  /*globalTimer++;
  if(globalTimer%1000==0) println(globalTimer);
  if(globalTimer%3000==0) tweet();*/
  
}

void mousePressed() 
{
  println("saving images...");
  gifExport.finish();
  tweet();
}
void keyPressed(){
  if(key=='a'){
    println("searching...");
    twitterBot.searchTweets("@pottedpicasso Draw me a");
  }
}

void tweet()
{ 
    // Capture frame
    saveFrame(dataPath("image.png"));

    // Prepare status
    println("preparing status...");
    twitterBot.prepareStatus();
    
  
    // Update status
    println("updating status...");
    twitterBot.updateStatus();
  
    // Restart painter
    println("restarting painter...");
    for(int i=0; i<numPainters; i++){
      painters[i] = new Painter((int)random(temp_low,temp_high), (int)random(light_low,light_high), (int)random(moist_low,moist_high)); 
    }
    
    
    //painter = new Painter((int)map(arduino.val_temp, 0, 255, temp_low, temp_high), (int)map(arduino.val_light, 0, 255, light_low, light_high), (int)map(arduino.val_moist, 0, 255, moist_low,moist_high));
}