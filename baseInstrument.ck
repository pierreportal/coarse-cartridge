// Base Instrument Class
// Provides common functionality for all cartridge instruments

/*
*
* /!\ DO NOT MODIFY THIS FILE!! /!\
*
*/

public class BaseInstrument
{
    // Audio chain - master output
    Gain output;
    0.5 => output.gain;

    // Connect output (console will connect this)
    fun UGen @ getOutput() { return output; }

    // Common properties
    float volume;
    int currentNote;

    // Initialization
    fun void init() {
        0.7 => volume;
        1.0 => output.gain;
    }

    // Base methods - override in child classes
    fun void noteOn(float freq, float velocity) {
        freq $ int => currentNote;
        // Child classes should override this
    }

    fun void noteOff() {
        // Child classes should override this
    }

    // Common utility methods
    fun void setVolume(float vol) {
        vol => volume;
        vol => output.gain;
    }
}
