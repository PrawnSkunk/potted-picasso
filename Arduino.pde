class Arduino
{
  Serial port; // Serial port
  int val_temp; // Data received from the serial port - variable to store the temperature sensor reading
  int val_light; // Data received from the serial port - variable to store the light sensor reading
  int val_moist; // Data received from the serial port - variable to store the moisture sensor reading
  byte[] inBuffer = new byte[255]; //size of the serial buffer to allow for end of data characters

  Arduino() {
    // Open the port that the board is connected to and use the same speed (9600 bps)
    port = new Serial(pottedpicasso.this, Serial.list()[0], 9600);
  }

  int splitVal(String masterString, String breakPoint) {

    String[] sensorReading = split(masterString, breakPoint);  //get sensor reading
    if (sensorReading.length != 3) return -1;  //exit this function if packet is broken
    return int(sensorReading[1]);
  }

  void initReadings() {
    if (0 < port.available()) { // If data is available to read,

      port.readBytesUntil('&', inBuffer);  //read in all data until '&' is encountered

      if (inBuffer != null) {
        String myString = new String(inBuffer);

        String[] fullPacket = splitTokens(myString, "&");  
        if (fullPacket.length < 2) return;  //exit this function if packet is broken

        //get light sensor reading 
        val_temp = splitVal(fullPacket[0], "a");

        //get slider sensor reading 
        val_light = splitVal(fullPacket[0], "b");

        //get moisture sensor reading      
        val_moist = splitVal(fullPacket[0], "c");
      }
    }
  }
}