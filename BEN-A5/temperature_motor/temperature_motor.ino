//TMP36 Pin Variables
#include <Servo.h>
#include <elapsedMillis.h>
#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>

#define COMMON_ANODE

elapsedMillis timeElapsed;

Servo myservo;
int pos = 0;

int TGLPIN = 2;
volatile int interrupted = 0;

int redPin = 4;
int greenPin = 5;
int bluePin = 6;

int useTempColor = 1;
int setColorVar = 0;

int sensorPin = 0;
float temperatureC;

unsigned int interval = 10000; //1 minute interval

void setup()
{
  // Set your BLE Shield name here, max. length 10
  ble_set_name("Team BEN");
  
  // Init. and start BLE library.
  ble_begin();
  
  Serial.begin(57600);  
  
  myservo.attach(3);    

  pinMode(TGLPIN, INPUT);
  attachInterrupt(0, blink, CHANGE);

  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);  
  
  setIntensityFromTemperature();
}
 
unsigned char buf[16] = {0};
unsigned char len = 0;
 
void loop()                     
{
 
  if ( ble_available() )
  {
      while ( ble_available() )
      {
          byte data0 = ble_read();
          byte data1 = ble_read();
          byte data2 = ble_read();
      
          //Serial.print("data0: ");
          //Serial.println(data0);
          //Serial.print("data1: ");
          //Serial.println(data1);
          //Serial.print("data2: ");
          //Serial.println(data2);
      
          //Motor toggling
          //if(data0 == 'M')
          if(data0 == 77)
          {
            if(data2 == '0')
            {
              myservo.detach(); 
              Serial.println("Motor detached");
            }
            else
            {
              myservo.attach(3);
              Serial.println("Motor attached");
            }  
          } 
          //else if(data0 == 'C')
          else if(data0 == 67)
          {
            Serial.println("C");
             if(data1 == '0' && data2 == '0')
             {
                useTempColor = 1;
                Serial.println("Using temperature color");
             }   
             else 
             {
                Serial.println("Using manual color");
                
                useTempColor = 0;
                
                if(data1 == 48 && data2 == 49)
                  setColor(255, 0, 0);
                  
                if(data1 == 48 && data2 == 50)
                  setColor(255, 102, 0);
                  
                if(data1 == 48 && data2 == 51)
                  setColor(255, 148, 0);
                  
                if(data1 == 48 && data2 == 52)
                  setColor(254, 197, 0);
                  
                if(data1 == 48 && data2 == 53)
                  setColor(255, 255, 0);
                  
                if(data1 == 48 && data2 == 54)
                  setColor(140, 199, 0);
                  
                if(data1 == 48 && data2 == 55)
                  setColor(15, 173, 0);
                  
                 if(data1 == 48 && data2 == 56)
                  setColor(0, 163, 199);
                  
                if(data1 == 48 && data2 == 57)
                  setColor(99, 0, 165);
                  
                if(data1 == 49 && data2 == 48){
                  setColor(0, 0, 255); 
                }
                
                if(data1 == 49 && data2 == 49)
                  setColor(0, 16, 165);
                  
                if(data1 == 49 && data2 == 50)
                  setColor(197, 0, 124);
             }
          }
      
      }
      
    Serial.println();
  }
  
  if (timeElapsed > interval) 
  {
    setIntensityFromTemperature();
    
    String temp = "";
    temp += temperatureC;
    
    char tempBuffer[5];
    temp.toCharArray(tempBuffer, temp.length());
    
    //ble_write(temp);
    ble_write('T');
    for( int i=0; i<temp.length(); i++) 
    {
      ble_write(tempBuffer[i]);
    }
//    ble_write('1');
//    ble_write('2');
    timeElapsed = 0;
  }
  
  if(interrupted == 1){ 
    ble_write('B');  
    interrupted = 0;
  }
  
  if(useTempColor == 1)
    setLED();
  
  ble_do_events();
 
}

void setIntensityFromTemperature(){
  
  //getting the voltage reading from the temperature sensor
    int reading = analogRead(sensorPin); 
    delay(1000);
    reading = analogRead(sensorPin);
   
   // converting that reading to voltage, for 3.3v arduino use 3.3
    float voltage = reading * 5.0;
    voltage /= 1024.0; 
   
   // now print out the temperature
    temperatureC = (voltage - 0.5) * 100 ;  //converting from 10 mv per degree wit 500 mV offset
                                             //to degrees ((voltage - 500mV) times 100)
   
    int intensity = map(temperatureC, -10, 40, 91, 120);
    myservo.write(intensity);
  
}

void setLED(){
  if(useTempColor == 1){
    int r = map(temperatureC, -10, 40, 0, 255);
    int b = map(temperatureC, -10, 40, 255, 0);
    setColor(r, 0, b);  
  }else{
    //setColor to preset color 
  }
}

void setColor(int red, int green, int blue)
{
  #ifdef COMMON_ANODE
  red = 255 - red;
  green = 255 - green;
  blue = 255 - blue;
  #endif
  analogWrite(redPin, red);
  analogWrite(greenPin, green);
  analogWrite(bluePin, blue);  
}


void blink()
{
  interrupted = 1;
  setColor(0,255,0);
}



