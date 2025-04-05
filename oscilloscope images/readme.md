# Oscilloscope traces

These are here to help with any troubleshooting. There's some noise, mainly cause by he trying to hold 4 things in place at once rather than connect things to the board properly.

The first image is of the raw avalanche signal, AC coupled, just past C1. It has a strong DC bias before C1.

The second image is the cleaned signal coming out of the final hex inverter stage.

The final image is the 10usec pulse that come out of the attiny261A every time a new byte is ready.

If your signals don't look mostly like these, it's not working properly, even if you're getting output!
