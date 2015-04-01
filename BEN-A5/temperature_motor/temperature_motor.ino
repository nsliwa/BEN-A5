//TMP36 Pin Variables
#include <Servo.h>
#include <elapsedMillis.h>
#define COMMON_ANODE

elapsedMillis timeElapsed;

Servo myservo;
int pos = 0;

int TGLPIN = 2;

int redPin = 4;
int greenPin = 5;
int bluePin = 6;

int sensorPin = 0;
float temperatureC;

unsigned int interval = 60000; //1 minute interval

void setup()
{
  Serial.begin(9600);  
  
  myservo.attach(3);    

  pinMode(TGLPIN, INPUT);
  attachInterrupt(0, blink, CHANGE);

  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);  
  
  setIntensityFromTemperature();
}
 
void loop()                     
{
 
  if (timeElapsed > interval) 
  {
    setIntensityFromTemperature();
    
    timeElapsed = 0;
  }
  
  int r = map(temperatureC, -10, 40, 0, 255);
  int b = map(temperatureC, -10, 40, 255, 0);
  setColor(r, 0, b);  
 
  int tglOn = digitalRead(TGLPIN);
 
}

void setIntensityFromTemperature(){
  
  //getting the voltage reading from the temperature sensor
    int reading = analogRead(sensorPin); 
    delay(1000);
    reading = analogRead(sensorPin);
   
   // converting that reading to voltage, for 3.3v arduino use 3.3
    float voltage = reading * 5.0;
    voltage /= 1024.0; 
   
   // print out the voltage
    Serial.print(voltage); Serial.println(" volts");
   
   // now print out the temperature
    temperatureC = (voltage - 0.5) * 100 ;  //converting from 10 mv per degree wit 500 mV offset
                                             //to degrees ((voltage - 500mV) times 100)
    Serial.print(temperatureC); Serial.println(" degrees C");
   
    int intensity = map(temperatureC, -10, 40, 91, 120);
    Serial.print("intensity: "); Serial.println(intensity);
    myservo.write(intensity);
  
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
  setColor(0,255,0);
  delay(1000);
}



