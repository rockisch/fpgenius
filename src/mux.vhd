LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY mux IS
    GENERIC (
        inputs : INTEGER := 4;
    );
    PORT (
        args : IN std_logic_vector(inputs - 1 DOWNTO 0);
        sel : IN NATURAL RANGE 0 TO inputs - 1;
        output : OUT std_logic;
    );
END mux;

ARCHITECTURE mux_arch
BEGIN
    output <= args(sel);
END mux_arch;
