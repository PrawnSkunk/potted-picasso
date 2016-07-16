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

// Create object from Serial class
Arduino arduino;

// Create object from TwitterBot class
TwitterBot twitterBot;

// Create object from Painter class
Painter painter;

void setup()
{
  // Application properties
  size(500,500);
  background(255);
  
  // Instantiate arduino object
  arduino = new Arduino();
  
  // Instantiate twitterBot object
  twitterBot = new TwitterBot();
  
  // Instantiate painter object
  painter = new Painter();
  
  // Begin painter
  painter.begin(); 
}

void draw() 
{
  // Paint
  painter.paint();
}

void mousePressed() 
{
  // Capture frame
  saveFrame(dataPath("image.png"));
  
  // Prepare status
  twitterBot.prepareStatus();
  
  // Update status
  twitterBot.updateStatus();
  
  // Restart painter
  painter.begin();
}