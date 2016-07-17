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

void setup()
{
  size(500, 500);
  background(255);

  // Initialize class objects
  arduino = new Arduino();
  twitterBot = new TwitterBot();
  painter = new Painter();
}

void draw() 
{
  painter.move();
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