module mux_script_unscript(input script_mode,           // Control signal to select between script and unscript modes
                           input dataIn_ready_script,   // Data input 'ready' signal for script mode
                           input dataIn_bits_script,    // Data input 'bits' signal for script mode
                           input dataIn_bits_unscript,  // Data input 'bits' signal for unscript mode
                           input dataIn_ready_unscript, // Data input 'ready' signal for unscript mode
                           output dataIn_ready,         // Mux output for 'ready' signal
                           output dataIn_bits);         // Mux output for 'bits' signal
    
    // When script_mode is 1, select script data; when 0, select unscript data
    assign dataIn_ready = script_mode ? dataIn_ready_script : dataIn_ready_unscript;
    assign dataIn_bits = script_mode ? dataIn_bits_script : dataIn_bits_unscript;
    
endmodule
