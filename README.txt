TeamBEN:
	Nicole Sliwa
	Ender Barillas
	Bre’shard Busby

Youtube link: https://www.youtube.com/watch?v=d-7VQfYDd1o&feature=youtu.be

Reads and displays data from two or more sensors/hardware attached to the arduino
-> one sensor/input must use analog voltage (e.g., as simple as a potentiometer)
-> -> temperature sensor [ gets ambient temperature; affects server motor / RGB LED / sent to iOS]
-> the other inputs(s) can be analog, digital, or binary output (e.g., as simple as a button)
-> -> toggle switch [ triggers message to iOS ]
-> -> RGB LED [ affected by temperature (default); hijacked by message from iOS ] 
-> -> server motor [ affected by temperature; on/off hijacked by iOS ] 
-> the display of the sensor data should be more than just a text label
-> -> temperature: displayed in thermometer (‘mercury’ height controlled by progress bar -> temperature gets received as Celsius, then converted to percentage (mapped -40 - 100 F))
-> use proper sampling rates to display the sensor output
-> -> 57600
-> use proper dynamic range and voltage references
-> -> 5V reference for temperature sensor

Create a protocol for encoding and interpretting the data on the iPhone
-> packet: ’protocol type’ character, followed by payload as characters
-> -> motor control (iOS to arduino): ‘M0[0|1]’, 0 for off, 1 for on
-> -> color control (iOS to arduino): ‘C[00-12]’, 0 for return control to temp; 1-12 to map to colors on color wheel (starting with red, going cw)
-> -> temperature update (arduino to iOS): ’T[<temp in degrees Celsius>]’
-> -> triggermiser animation (arduino to iOS): ‘B’ (no payload)

Sends two or more control commands to the microcontroller that change the behavior of the arduino
-> make the controls change something noticeable in the operation of the Arduino
-> -> motor message controls whether motor on/off
-> -> color message controls color of RGB LED
-> the output must make use of a PWM signal (implemented in hardware)
-> -> server motor uses PWM

The Arduino sketch should also: 
-> use one or more interrupts 
-> -> toggle switch triggers interupt
-> the interrupt must change something noticeable in the operation of the Arduino
-> -> triggers message to iOS
-> use proper debouncing
-> -> n/a
-> use digital outputs (GPIO)
-> -> LED, motor, switch
-> use PWM (in hardware, look at which GPIO pins can do this)
-> -> server motor
-> use the ADC (for the analog input part)
-> -> temperature sensor

Wow factors:
-> ambient display (‘dangling string’ - esque) to visualize temperature
-> Easter Egg: Heat miser/ Snow miser
-> WunderGround API queried to get current average temperature in Dallas (using NSURLSession learned for A6)
-> notifications for BLE disabled
-> prevents message sending if !BLE connected
-> get pixel color of UIImageView on tap at tap location
-> custom launch screen / app icon
-> modal views
-> super awesome animation
-> super clever thermometer (progress bar for mercury rising!)
-> super awesome video demo with super smooth recovery
