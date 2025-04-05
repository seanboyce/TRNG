# Function

This circuit is designed to output random bytes out MQTT, each as a message. It works at 8-10k bytes per second depending on system voltage and the fact that the bitrate of the entropy source is variable by nature.

# How it works

The core entropy source is two transistors in an unusual configuration. This is an old technique analogous to the classic "zener diode" method. It has the advantage of producing a slower signal, easier to sample.
It outputs avalanche noise with heavy DC bias. There's some nice [summary here](http://www.reallyreallyrandom.com/zener/why-its-random/index.html).

We remove the DC component wth a capacitor, then use two hex inverters for amplification and pulse-shaping. The first hex inverter is running at ~12V and is configured as two inverting amplifiers -- this is really power inefficient and it gets a bit warm due to the digital part working in linear modes. A little heat sink is recommended. 

This unusual use of the hex inverter is to reduce the parts count and cost -- I have a lot of hex inverters lying around. If you needed better power efficiency (e.g. for battery-powered use), you could use an op-amp. OPA132 is pretty easy to use.

The next hex inverter operates more or less digitally, just shaping the signal into a clean square wave. This one does not get warm.

After that, and attiny261A acts as a Von Neumann extractor to convert the square wave into usable, unbiased bits of entropy. 

The bytes are read by a Pi Pico W and pushed out MQTT. Basic authentication works. I didn't bother adding TLS.

It would be possible to just use the PIO of the pi pico instead of an attiny261A. However, most of the time I don't actually want the Pi Pico or WiFi, and am just using the entropy locally. If you wanted to do this, you would simply not populate the attiny 261A, and solder a wire between pin 9 of the Attiny socket, and whatever pin you want on the Pi Pico. That will bypass the attiny261A and push the raw entropy signal directly to the Pi Pico. I would recommend writing your own Von Neumann extractor with the PIO.

# How to build it

## Notes on surface mount components

This design makes extensive use of surface-mount components. I have limited budget and time to spend on my hobbies, so I generally use the smallest possible SMT components to save money and time. If you find 0402 difficult to work with, then it's very fast to open up the KiCAD files in this repo, and replace all the 0402 resistors with 0603 in the schematic. Then just pull up the board design, update from the schematic, and touch up the routing -- you should be good to go.

If you want to redesign everything as through-hole, this will require a bit of redesign. I would recommend purchasing a USB boost converter, not populating the integrated boost converter, and using the passthrough I've left you (J2). Then switch the CD4069 to the DIP version, and add in through hole resistors and capacitors. 

## Building the current design

I recommend building the boost converter first, then give it some power and make sure the output voltage is sane. Should be between 12 and 13 volts. Note that the EN pin of the MT3608 should be connected to Vin -- else nothing will output at all. I just bridge the middle pin of J1 to Vin.

Once that's in, I put in the transistors (mind polarity!), the hex inverter, and all the resistors and capacitors around them. Then I supply power again, for a short time, with a scope connected to the output of the first hex inverter. The scope is set to be AC coupled. I should see a pretty looking signal with a lot of noise. Then I cut power -- that hex inverter can get sort of hot with no heat sink attached.

Then I get the buck converter / LM7803 in, as well as the final hex inverter. Then I test as above, making sure the signal from the second hex inverter is a weird looking, but mostly clean square wave ranging from 0 to 3.3V.

If that's good, I flash the program to an Attiny261A. For the first few boards, I put in a socket for it, so I can pull it out and update the firmware. Then I quickly check again, specifically that the "new output" pin of the attiny261A is toggling, and that bits are coming out of PORTA.

At this point, I just load the program into the Pi Pico, disconnect it from the USB cable, and plug it in. The onboard LED should light up if it's receiving power, and flicker slightly if it's pushing out MQTT.

**DO NOT plug a USB cable into the Pi Pico while it is connected to this circuit** It is being powered by 3.3V. USB is 5V. Several components are likely to fail violently, and the circuit will put unsupported voltages on the Pi Pico GPIO pins.

## The Von Neumann Extractor

This just measures two time intervals between 2 sets of 2 independent events (it could probably use 3 events instead of 4 to calculate 2 intervals, but whatever. It's much faster than fast enough now). If t1>t2, it records a 0. If t1<t2, it records a 1. If they are equal, it tries again.

I wrote this *ages* ago. It was quite an experience to look at my ham-fisted assembly from 15 years ago. I redid it with many optimizations, which increased performance about 50x. Also it consumes less power. Use main.asm, not old_von_neumann.asm. Seriously, the latter is pretty awful.

I include both files, so that one day I may look back and consider *both attempts* primitive and silly.

TODO: Clean up the project and KiCAD files before adding them here.

![photo of the trng](https://raw.githubusercontent.com/seanboyce/trng/refs/heads/main/qtrng.jpg)
