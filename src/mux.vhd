LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;

ENTITY mux IS
    GENERIC (
        inputs : INTEGER := 4
    );
    PORT (
        args : IN std_logic_vector(inputs - 1 DOWNTO 0);
        sel : IN NATURAL range 0 TO inputs - 1;
        output : OUT std_logic
    );
END mux;

ARCHITECTURE mux_arch OF mux IS
BEGIN
    output <= args(sel);
END mux_arch;