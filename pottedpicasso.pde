import gifAnimation.*;
import java.util.Date;
import java.util.List;
import processing.opengl.*;
import processing.serial.*;
import twitter4j.*;
import twitter4j.api.*;
import twitter4j.auth.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.management.*;
import twitter4j.util.*;
import twitter4j.util.function.*;

// Declare global variables
int numPainters = 2;
int[] palXPos = new int[numPainters];
Painter[] painters = new Painter[numPainters];
Arduino arduino;
TwitterBot twitterBot;
GifMaker gifExport;
PImage pic;
PFont font;

// Variables controlling the max and min values that get passed to the painter method for each sensor reading
// TEMPORARILY MAKING THEM GLOBAL, THEY WONT BE IN THE FUTURE, THIS IS FOR TESTING
int light_low = 0;
int light_high = 255; // MUST BE SCREEN WIDTH-1
int temp_low = 10;
int temp_high = 250;
int moist_low = 1;
int moist_high = 50;

// boolean variables to see if sensor has been read from
boolean sensorsRead = false;
boolean painterCreated = false;

int globalTimer = 0;

ArrayList<String> drawingsToPost = new ArrayList<String>();

void setup()
{
  smooth();
  frameRate(60);
  size(256, 256); // if you change size, update light_high variable
  background(255);

  // Initialize class objects
  arduino = new Arduino();
  twitterBot = new TwitterBot();
  
  // Initialize the painter with random values if arduino isn't connecting
  /*for(int i=0; i<numPainters; i++){
    int maxTotal = (int)random(temp_low,temp_high);
    int light_val = (int)random(light_low,light_high);
    int maxInit = (int)random(moist_low,moist_high);
    palXPos[i] = (int)random(light_low,light_high);
    if(palXPos[i] > width) { 
      println("It's drawing black, because you haven't updated int light_high for the new screen width!");
    }
    painters[i] = new Painter(maxTotal, light_val, maxInit, palXPos[i]); 
  }*/
  pic = loadImage(dataPath("image.png"));
  gifExport = new GifMaker(this, dataPath("gif.gif"));
  
}

void draw() 
{
  globalTimer++;
  if(painterCreated==true){
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
  }
  
  // THIS SECTION WILL INITIALIZE THE PAINTER IF THE ARDUINO IS ACTUALLY SENDING VALUES //
  // LEAVE COMMENTED BUT DO NOT DELETE // - Matt
  
  
  
  // if the painter has been created then paint away
  /*if(painterCreated==true){
    if (painter.painting == true) {
      painter.paint();
    } 
  }*/
  
  if(painterCreated==false&&sensorsRead==true){ // if there isnt already a painter, create one
    for(int i=0; i<numPainters; i++){
      int maxTotal = (int)random(temp_low,temp_high);
      int light_val = (int)random(light_low,light_high);
      int maxInit = (int)random(moist_low,moist_high);
      palXPos[i] = (int)random(light_low,light_high);
      if(palXPos[i] > width) { 
        println("It's drawing black, because you haven't updated int light_high for the new screen width!");
      }
      painters[i] = new Painter(maxTotal, light_val, maxInit, palXPos[i]); 
    }
    painterCreated=true;
  }
  
  if (sensorsRead == false){
    arduino.initReadings();
    if(arduino.val_light>0&&arduino.val_temp>0&&arduino.val_moist>0){ // if the sensors have received values then we can begin to init the painter object
      sensorsRead=true;
    }
  }
  
  // once this timer reaches 15000 (not based on actual seconds or milliseconds) it will post to twitter
  // and then start drawing again
  if(globalTimer%1000==0) println(globalTimer);
  if(globalTimer%100000==0){
      controlPosting();
  }
  
}
void clearArray(ArrayList a){
  println("a.size="+a.size());
  for(int i = 0; i<a.size(); i++){
    println("a.get("+i+")="+a.get(i));
    a.remove(i);
  }
  printArray(a);
}
void controlPosting(){
    if(drawingsToPost.size()==0){
      println("grabbing new requests...");
      println("");
      /*clearArray(twitterBot.tweetRequests);
      clearArray(twitterBot.tweetRequestsUsername);
      clearArray(twitterBot.tweetsDrawn);
      clearArray(twitterBot.tweetsDrawnUsername);*/
      println("");
      drawingsToPost = checkForRequests();
    }
    printArray(drawingsToPost);
    if(drawingsToPost.size()>0){
      gifExport.finish();
      println("tweeting... "+drawingsToPost.get(0));
      tweet2(drawingsToPost.get(0));
      drawingsToPost.remove(0);
    }
    else{
        println("tweeting default tweet...");
        gifExport.finish();
        tweet2("Here is something I drew");
    }
    gifExport = new GifMaker(this, dataPath("gif.gif"));
}

void mousePressed() 
{
  println("saving images...");
  gifExport.finish();
  tweet();
  gifExport = new GifMaker(this, dataPath("gif.gif"));
}
ArrayList<String> checkForRequests(){
  
  ArrayList<String> tweetsToPost = new ArrayList<String>();
  int numNotEqual = 0;
  println("searching...");
    
    twitterBot.tweetRequests = new ArrayList<String>();
    twitterBot.tweetRequestsUsername = new ArrayList<String>();
    twitterBot.tweetsDrawn = new ArrayList<String>();
    twitterBot.tweetsDrawnUsername = new ArrayList<String>();
    twitterBot.searchTweets("@pottedpicasso Draw me a");
    
    for(int i = 0; i<twitterBot.tweetRequests.size(); i++){
      //println("here");
      twitterBot.searchMyTweets("@"+twitterBot.tweetRequestsUsername.get(i) + " Here's the " + twitterBot.tweetRequests.get(i));
    }
    
    for(int i = 0; i<twitterBot.tweetRequests.size(); i++){
      
      //println("");
      println("SEARCHING FOR: "+"@"+twitterBot.tweetRequestsUsername.get(i) + " Here's the " + twitterBot.tweetRequests.get(i));
      //twitterBot.searchMyTweets("@"+twitterBot.tweetRequestsUsername.get(i) + " Here's the " + twitterBot.tweetRequests.get(i));
      numNotEqual=0;
      
      for(int j = 0; j<twitterBot.tweetsDrawn.size(); j++){
        
        //println("i="+i+" j="+j+" nE="+numNotEqual+" tDsize="+twitterBot.tweetsDrawn.size()+" tRsize="+twitterBot.tweetRequests.size());
        //println("ARE THESE EQUAL?  "+twitterBot.tweetRequestsUsername.get(i)+" "+twitterBot.tweetRequests.get(i)+"  &  "+
        //twitterBot.tweetsDrawnUsername.get(j)+" "+twitterBot.tweetsDrawn.get(j));
        
        if(twitterBot.tweetRequests.get(i).equals(twitterBot.tweetsDrawn.get(j))&&
           twitterBot.tweetRequestsUsername.get(i).equals(twitterBot.tweetsDrawnUsername.get(j))){
          //println("EQUAL");
          break;
        }
        else{
          numNotEqual++;
          //println("NOT EQUAL ="+numNotEqual);
          if(numNotEqual==twitterBot.tweetsDrawn.size()){
            //println("ADDED: "+"@"+twitterBot.tweetRequestsUsername.get(i)+" Here's the "+twitterBot.tweetRequests.get(i));
            tweetsToPost.add("@"+twitterBot.tweetRequestsUsername.get(i)+" Here's the "+twitterBot.tweetRequests.get(i));
          }
        }
      }
    }
    //printArray(twitterBot.tweetRequests+" "+twitterBot.tweetRequestsUsername);
    //printArray(twitterBot.tweetsDrawn+" "+twitterBot.tweetsDrawnUsername);
    return tweetsToPost;
}
void keyPressed(){
  if(key=='a'){
    // for testing only
    controlPosting();
  }
  if(key=='b'){
    gifExport.finish();
    tweet();
  }
}

void tweet2(String status) // this one is for tweeting the request responses
{ 
    // Capture frame
    saveFrame(dataPath("image.png"));

    // Prepare status
    //println("preparing alternate status...");
    //twitterBot.prepareStatus2(status);
    
    // Update status
    println("updating status...");
    twitterBot.updateStatus2(status);
  
    // Restart painter
    println("restarting painter...");
    for(int i=0; i<numPainters; i++){
      palXPos[i] = (int)random(light_low,light_high);
      if(palXPos[i] > width) { 
        println("It's drawing black, because you haven't updated int light_high for the new screen width!");
      }
      painters[i] = new Painter((int)random(temp_low,temp_high), (int)random(light_low,light_high), (int)random(moist_low,moist_high), palXPos[i]); 
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
       palXPos[i] = (int)random(light_low,light_high);
      if(palXPos[i] > width) { 
        println("It's drawing black, because you haven't updated int light_high for the new screen width!");
      }
      painters[i] = new Painter((int)random(temp_low,temp_high), (int)random(light_low,light_high), (int)random(moist_low,moist_high), palXPos[i]); 
    }
    
    
    //painter = new Painter((int)map(arduino.val_temp, 0, 255, temp_low, temp_high), (int)map(arduino.val_light, 0, 255, light_low, light_high), (int)map(arduino.val_moist, 0, 255, moist_low,moist_high));
}