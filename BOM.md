# Required:

## Resistors (all 0402):
- 1x 20k
- 1x 1k
- 3x 50k
- 1x 1M

## Capacitors:
- 2x 22uF ceramic non-polar 1206
- 3x 0.1uF ceramic non-polar 0603

## Discrete semiconductors:
- 1x SS24 Schottky diode SMT (unsure of package)
- 2x 2N5551 transistors TO-92

## ICs and modules:
- 2x CD4069UBM hex inverters
- 1x MT3608 boost converter IC
- 1x buck converter module -- the tiny cheap ones with just EN, Vin, GND, Vout
- 1x Attiny 261A
- 1x Pi Pico W

# Optional:
- 1x crystal
- 2x 12pF ceramic non-polar 0603
- 2x two-pin JST connector
- 1x LM7803 linear regulator (alternative to a buck converter to get 3.3V)
- 1x covenant with the Old Powers

#Notes: 

1. The optional crystal as a clock source for the attiny is untested. Maybe double check I connected it right. If using it, the 12pF caps are required.
2. The JST connectors are handly for connecting power to the board through J1. It's expected that you bridge the middle pin of J1 to VCC of the input voltage. It's connected to the enable pin of the MT3608
3. J2 lets you bypass the integrated boost converter, e.g. if you just want to supply ~12V to the board. In this case, all of the boost converter parts should not be added to the board.
4. Strictly speaking, the Attiny261A could be eliminated by just using the PIO of the pi pico. However, I often use this design in cases where Internet connectivity is not useful -- in these cases I just don't populate the Pi Pico, which is more expensive than an Attiny261A. Also I wrote the Von Neumann extractor for the attiny ages ago so already had it.
