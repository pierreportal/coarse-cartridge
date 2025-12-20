// Custom Instrument - extends BaseInstrument
// This demonstrates how to create a custom instrument by inheriting from the base

public class CustomInstrumentMetaData
{
	"Pierre Portal" => string author;
	"Saw lite" => string title;
	1.0 => float version;
}

public class CustomInstrument extends BaseInstrument
{
    // Custom audio chain - connects to parent's output
    SawOsc saw => LPF filter => ADSR env => output;

    // Custom parameters
    100::ms => dur attack;
    500::ms => dur decay;
    0.5 => float sustain;
    1000::ms => dur release;

    // Initialize the instrument
    fun void init() {
        // Set parent properties directly
        0.7 => volume;
        1.0 => output.gain;

        // Custom setup
        env.set(attack, decay, sustain, release);
        2000.0 => filter.freq;
        0.5 => filter.Q;
        0 => env.value;
    }

    // Override noteOn
    fun void noteOn(float freq, float velocity) {
        // Track note (from parent logic)
        freq $ int => currentNote;

        // Custom implementation
        freq => saw.freq;
        velocity * volume => saw.gain;
        env.keyOn();

        <<< "CustomInstrument: noteOn", freq, "Hz at velocity", velocity >>>;
    }

    // Override noteOff
    fun void noteOff() {
        env.keyOff();
        <<< "CustomInstrument: noteOff" >>>;
    }

    // Custom methods
    fun void setFilterCutoff(float freq) {
        freq => filter.freq;
        <<< "Filter cutoff set to:", freq, "Hz" >>>;
    }

    fun void setADSR(dur a, dur d, float s, dur r) {
        a => attack;
        d => decay;
        s => sustain;
        r => release;
        env.set(attack, decay, sustain, release);
        <<< "ADSR set to:", attack/1::ms, "ms", decay/1::ms, "ms", sustain, release/1::ms, "ms" >>>;
    }
}
