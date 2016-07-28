class TwitterBot {

  // Instance variables
  Twitter twitter;
  StatusUpdate status;
  StatusUpdate statuspaint; 
  // TwitterBot constructor
  
  ArrayList<String> tweetarray = new ArrayList<String>();
  
  TwitterBot() 
  {
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
  void prepareStatus() 
  {
    status = new StatusUpdate("Test");
    status.setMedia(new File(dataPath("image.png")));
    statuspaint = new StatusUpdate("TestGIF");
    statuspaint.setMedia(new File(dataPath("gif.gif")));

  }
  
  void prepareStatus2() 
  {
    status = new StatusUpdate("Test");
    status.setMedia(new File(dataPath("image.png")));
    statuspaint = new StatusUpdate("Here's the " + tweetarray.get(0)); // this will say the actual thing being drawn
    statuspaint.setMedia(new File(dataPath("gif.gif")));
    tweetarray.remove(0); //remove the last request off the stack, so it goes in order

  }

  // Update status
  void updateStatus() 
  { 
    try 
    {
      //twitter.updateStatus(status);
      twitter.updateStatus(statuspaint);
    } 
    catch (TwitterException te) 
    {
      println("Error: " + te);
    }
  }
  String splitString(String baseString){
    String[] split = split(baseString, " Draw me a ");
    return split[1];
  }
  void searchTweets(String searchString) {
      try{
        Query query = new Query(searchString);
        QueryResult result = twitter.search(query);
        for (Status status : result.getTweets()) {
            String returnedString = "@" + status.getUser().getScreenName() + ":" + status.getText();
            tweetarray.add(splitString(returnedString));
            println(status.getUser().getScreenName()+" wants to draw a "+splitString(returnedString));
        }
      } catch (TwitterException te) {
        println("Error: " + te);
      }
    }
}