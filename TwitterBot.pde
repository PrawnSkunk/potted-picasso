class TwitterBot {

  // Instance variables
  Twitter twitter;
  StatusUpdate status;
  StatusUpdate statuspaint; 
  // TwitterBot constructor
  
  ArrayList<String> tweetRequests = new ArrayList<String>();
  ArrayList<String> tweetsDrawn = new ArrayList<String>();
  ArrayList<String> tweetRequestsUsername = new ArrayList<String>();
  ArrayList<String> tweetsDrawnUsername = new ArrayList<String>();
  
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
    statuspaint = new StatusUpdate("Here is something I drew");
    statuspaint.setMedia(new File(dataPath("gif.gif")));

  }
  
  void updateStatus2(String stat){
    
    status = new StatusUpdate(stat);
    status.setMedia(new File(dataPath("image.png")));
    statuspaint = new StatusUpdate(stat);
    statuspaint.setMedia(new File(dataPath("gif.gif")));
    
    try{
    twitter.updateStatus(statuspaint);
    }
    catch (TwitterException te) 
    {
      println("updateStatus 2 Error: " + te.getErrorMessage()+" "+te.getRateLimitStatus());
    }
  } 
  
  void prepareStatus2(String statusForPost) 
  {
    status = new StatusUpdate(statusForPost);
    status.setMedia(new File(dataPath("image.png")));
    statuspaint = new StatusUpdate(statusForPost); // this will say the actual thing being drawn
    statuspaint.setMedia(new File(dataPath("gif.gif")));
    //tweetRequests.remove(0); //remove the last request off the stack, so it goes in order
    //tweetRequestsUsername.remove(0);

  }

  // Update status
  void updateStatus() 
  { 
    try 
    {
      //twitter.updateStatus(status);
      twitter.updateStatus(statuspaint);
    } 
    catch (TwitterException te) {
      println("updateStatus Error: " + te.getErrorMessage()+" "+te.getRateLimitStatus());
    }
  }
  String splitString(String baseString, String splitter, int returnInt){
    String[] split = split(baseString, splitter);
    return split[returnInt];
  }
  
  void searchTweets(String searchString) {
      try{
        Query query = new Query(searchString);
        QueryResult result = twitter.search(query);
        for (Status status : result.getTweets()) {
            String returnedString = "@" + status.getUser().getScreenName() + ":" + status.getText();
            tweetRequests.add(splitString(returnedString," Draw me a ",1));
            tweetRequestsUsername.add(status.getUser().getScreenName());
        }
      } catch (TwitterException te) {
        println("SearchTweets Error: " + te.getErrorMessage()+" "+te.getRateLimitStatus());
      }
    }
  void searchMyTweets(String searchString) {
    try{
      Query query = new Query(searchString);
      QueryResult result = twitter.search(query);
      List<Status> statuses = twitter.getHomeTimeline();
      for (Status status : statuses){//result.getTweets()) {
          String returnedString = splitString(status.getText()," https://t.co",0);
          if(returnedString.equals(searchString)){
            tweetsDrawn.add(splitString(returnedString," Here's the ",1));
            String userName = splitString(returnedString," Here's the ",0);
            tweetsDrawnUsername.add(userName.substring(1));
          }
      }
    } catch (TwitterException te) {
      println("SearchMyTweets Error: " + te.getErrorMessage()+" "+te.getRateLimitStatus());
    }
  }
}