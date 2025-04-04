# TRNG

This circuit is designed to output random bytes out MQTT, each as a message. It works at 100-300 bytes per second depending on system voltage and the fact that the bitrate of the entropy source is variable by nature.

The core entropy source is two transistors in an unusual configuration. This is an old method analogous to the classic "zener diode" method, and outputs tunneling noise with heavy DC bias.

We remove the DC component wth a capacitor, then use two hex inverters for amplification and pulse-shaping. The first hex inverter is running at ~12V and is configured as two inverting amplifiers -- this is really power inefficient and it gets a bit hot. A little heat sink is recommended. However, it reduces the parts count, is very cheap, and I have lots of hex inverters.

The next hex inverter operates more or less digitally, just shaping the signal into a clean square wave.

After that, and attiny261A acts as a Von Neumann extractor to convert the square wave into usable, unbiased bits of entropy. It's just an inefficient assembly program I wrote 15 years ago, I'll clean it up eventually. The bytes are read by a Pi Pico W and pushed out MQTT.

It would be possible to just use the PIO of the pi pico to do this. However, most of the time I don't actually want the Pi Pico or WiFi, and am just using the entropy locally. 


TODO: Clean up the project and KiCAD files before adding them here.

![photo of the trng](https://raw.githubusercontent.com/seanboyce/trng/refs/heads/main/qtrng.jpg)
