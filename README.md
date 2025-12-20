# Cartridge

Cartridges contain instrument definitions that can be loaded into the console. Each cartridge provides a custom synthesizer or sampler that extends the base instrument framework.

## Overview

The cartridge system provides a modular way to create and distribute ChucK instruments. Cartridges are physical modules containing FRAM memory that store instrument code, which is then read and executed by the console.

## Structure

```
cartridge/
├── baseInstrument.ck       # Base class (DO NOT MODIFY)
└── customInstrument.ck     # Example custom instrument implementation
```

## Creating a Cartridge

### 1. BaseInstrument (Framework)

**⚠️ DO NOT MODIFY `baseInstrument.ck` ⚠️**

The `BaseInstrument` class provides the foundation for all cartridge instruments:

```chuck
public class BaseInstrument
{
    Gain output;                // Master output (connect to console)
    float volume;               // Overall volume level
    int currentNote;            // Currently playing note

    fun UGen @ getOutput()      // Returns audio output
    fun void init()             // Initialize instrument
    fun void noteOn(float freq, float velocity)   // Start note
    fun void noteOff()          // Stop note
    fun void setVolume(float vol)                 // Set volume
}
```

### 2. Creating Your Custom Instrument

Extend `BaseInstrument` to create your own instrument. See `customInstrument.ck` for a complete example.

#### Required Structure

```chuck
// Metadata class (optional but recommended)
public class CustomInstrumentMetaData
{
    "Your Name" => string author;
    "Instrument Name" => string title;
    1.0 => float version;
}

// Main instrument class
public class CustomInstrument extends BaseInstrument
{
    // Your audio chain - MUST connect to output
    // Example: SawOsc saw => ADSR env => output;

    // Override init()
    fun void init() {
        // Set volume and output gain
        0.7 => volume;
        1.0 => output.gain;

        // Configure your audio chain
        // ...
    }

    // Override noteOn()
    fun void noteOn(float freq, float velocity) {
        freq $ int => currentNote;  // Track current note

        // Your note trigger logic
        // ...
    }

    // Override noteOff()
    fun void noteOff() {
        // Your note release logic
        // ...
    }
}
```

## Example: Saw Synthesizer

The included `customInstrument.ck` demonstrates a simple filtered saw wave synthesizer:

```chuck
public class CustomInstrument extends BaseInstrument
{
    // Audio chain
    SawOsc saw => LPF filter => ADSR env => output;

    // Parameters
    100::ms => dur attack;
    500::ms => dur decay;
    0.5 => float sustain;
    1000::ms => dur release;

    fun void init() {
        0.7 => volume;
        1.0 => output.gain;
        env.set(attack, decay, sustain, release);
        2000.0 => filter.freq;
        0.5 => filter.Q;
    }

    fun void noteOn(float freq, float velocity) {
        freq $ int => currentNote;
        freq => saw.freq;
        velocity * volume => saw.gain;
        env.keyOn();
    }

    fun void noteOff() {
        env.keyOff();
    }
}
```

## Building Blocks

Your instrument can use any ChucK UGen (Unit Generator):

### Oscillators
- `SinOsc`: Sine wave
- `SawOsc`: Sawtooth wave
- `SqrOsc`: Square wave
- `TriOsc`: Triangle wave
- `PulseOsc`: Pulse wave (adjustable width)

### Filters
- `LPF`: Low-pass filter
- `HPF`: High-pass filter
- `BPF`: Band-pass filter
- `BRF`: Band-reject filter

### Envelopes
- `ADSR`: Attack-Decay-Sustain-Release
- `Envelope`: Custom envelope shapes

### Effects
- `Echo`: Delay/echo effect
- `JCRev`: Reverb
- `Chorus`: Chorus effect
- `PitShift`: Pitch shifter

### Utilities
- `Gain`: Amplitude control/mixing
- `Pan2`: Stereo panning
- `Noise`: White noise generator

## Best Practices

1. **Always connect to output**: Your final audio chain must connect to `output`
   ```chuck
   myOsc => myFilter => output;
   ```

2. **Initialize properly**: Set up all parameters in `init()`
   ```chuck
   fun void init() {
       parent.init();  // Optional: call parent init
       // Your setup here
   }
   ```

3. **Track current note**: Store frequency in `currentNote` for reference
   ```chuck
   freq $ int => currentNote;
   ```

4. **Respect velocity**: Use MIDI velocity to control dynamics
   ```chuck
   velocity * volume => oscillator.gain;
   ```

5. **Clean note-off**: Properly release envelopes and stop oscillators
   ```chuck
   fun void noteOff() {
       envelope.keyOff();
       // or: 0 => oscillator.gain;
   }
   ```

6. **Add metadata**: Include author, title, and version info
   ```chuck
   public class CustomInstrumentMetaData {
       "Your Name" => string author;
       "Instrument Name" => string title;
       1.0 => float version;
   }
   ```

## Testing Your Cartridge

Before deploying to physical cartridge:

1. Copy your instrument files to `/tmp/cartridge/`
2. Create a symlink: `ln -s /tmp/cartridge/customInstrument.ck /tmp/cartridge_current.ck`
3. Run the console launcher: `./console/console-launcher.sh`
4. Test with MIDI or watch the demo melody playback

## MIDI CC Parameters (Optional)

The console's MIDI controller exposes these parameters:
- **CC 20**: Attack time (if your instrument uses ADSR)
- **CC 21**: Decay time
- **CC 22**: Sustain level
- **CC 23**: Release time

To make your instrument respond to CC, implement setter methods:
```chuck
fun void setAttack(float a) { a::ms => attack; env.set(attack, decay, sustain, release); }
fun void setDecay(float d) { d::ms => decay; env.set(attack, decay, sustain, release); }
// etc...
```

## File Requirements

- File must be named `customInstrument.ck`
- Must contain public class `CustomInstrument extends BaseInstrument`
- Must implement `init()`, `noteOn()`, and `noteOff()`
- Must be valid ChucK syntax
- Must not modify `baseInstrument.ck`

## Deployment

Physical cartridges store instrument code in FRAM memory. The console's `fram-reader.py` extracts this data to `/tmp/cartridge_current.ck` when the cartridge is inserted.
