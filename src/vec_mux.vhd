LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

PACKAGE vec_mux_p IS
    TYPE vec_mux_args IS ARRAY (NATURAL RANGE <>) OF std_logic_vector;
END PACKAGE;

PACKAGE vec_mux_p BODY IS
END PACKAGE BODY;
LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE vec_mux_p.vec_mux_args;

ENTITY vec_mux IS
    GENERIC (
        inputs : INTEGER := 2;
        size : INTEGER := 7
    );
    PORT (
        args : IN vec_mux_args(0 TO inputs)(size - 1 DOWNTO 0);
        sel : IN NATURAL RANGE 0 TO inputs - 1;
        output : OUT std_logic_vector(size - 1 DOWNTO 0)
    );
END vec_mux;

ARCHITECTURE vec_mux_arch
BEGIN
    output <= args(sel);
END vec_mux_arch;
