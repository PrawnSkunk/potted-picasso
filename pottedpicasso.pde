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

// Declare class objects
Arduino arduino;
TwitterBot twitterBot;
Painter painter;
PFont font;

boolean sensorsRead = false;
boolean painterCreated = false;

void setup()
{
  frameRate(200);
  size(500, 500);
  background(255);

  // Initialize class objects
  arduino = new Arduino();
  twitterBot = new TwitterBot();
  painter = new Painter(25, 1024, 0); // initializing the painter with set values from arduino because you guys do not have the arduino set up - Matt
}

void draw() 
{
  
  if (painter.painting == true) {
      painter.paint();
  } 
  
  // THIS SECTION WILL INITIALIZE THE PAINTER IF THE ARDUINO IS ACTUALLY SENDING VALUES //
  // LEAVE COMMENTED BUT DO NOT DELETE // - Matt
  /*
  if(painterCreated==true){
    if (painter.painting == true) {
      painter.paint();
    } 
  }
  if(painterCreated==false&&sensorsRead==true){
    println("painter created with temp="+(int)map(arduino.val_temp, 0, 255, 10, 25)+" light="+(int)map(arduino.val_light, 0, 255, 500, 1023)+" moist="+arduino.val_moist);
    
    painter = new Painter((int)map(arduino.val_temp, 0, 255, 10, 25), (int)map(arduino.val_light, 0, 255, 500, 1023), arduino.val_moist);
    painterCreated=true;
  }
  if (sensorsRead == false){
    arduino.initReadings();
    if(arduino.val_light>0){
      sensorsRead=true;
    }
  }*/
}

void mousePressed() 
{
  tweet();
}

void tweet()
{
    // Capture frame
    saveFrame(dataPath("image.png"));
  
    // Prepare status
    twitterBot.prepareStatus();
  
    // Update status
    twitterBot.updateStatus();
  
    // Restart painter
    painter.restart();
}