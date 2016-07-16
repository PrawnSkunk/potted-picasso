class TwitterBot {
 
  // Twitter objects
  Twitter twitter;
  StatusUpdate status;

  TwitterBot(){
    // Instantiate twitter object
    twitter = new TwitterFactory(new ConfigurationBuilder()         
      .setDebugEnabled(true) 
      .setOAuthConsumerKey("vEBA9JDv9onXRSIKENRToJuI3") 
      .setOAuthConsumerSecret("B6Zlj3mkC49eKMQHZ7JECBHAtjBSQQCESJbgQK2uu84geOdRqf") 
      .setOAuthAccessToken("743475229242986497-ocDQ70FNhJBTSGYJd9pvL6xUjADDUO9") 
      .setOAuthAccessTokenSecret("i3suZLvqw3SQ7McsubtTsI6hO0dCakcgWlrOtGOERE4zH")
      .build()).getInstance();
  }
  
  // Prepare status
  void prepareStatus(){
    status = new StatusUpdate("Test");
    status.setMedia(new File(dataPath("image.png"))); 
  }
  
  // Update status
  void updateStatus() { 
    try {
      twitter.updateStatus(status);
    } catch (TwitterException te){
      println("Error: " + te);
    }
  }
}