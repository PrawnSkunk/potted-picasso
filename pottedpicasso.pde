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

void setup()
{
  frameRate(200);
  size(500, 500);
  background(255);

  // Initialize class objects
  arduino = new Arduino();
  twitterBot = new TwitterBot();
  painter = new Painter();
}

void draw() 
{
  // Draw paint strokes
  if (painter.painting == true) {
    painter.paint();
  } 
  // Draw sensor values
  readSensors();
}

void mousePressed() 
{
  tweet();
}

void readSensors()
{
  arduino.initReadings();
  fill(0);
  text("temp: "+arduino.val_temp,10,20);
  text("light: "+arduino.val_light,10,40);
  text("moisture: "+arduino.val_moist,10,60);
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