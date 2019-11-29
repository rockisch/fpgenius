LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE vec_mux_7_p IS
    TYPE vec_mux_t IS ARRAY (NATURAL RANGE <>) OF std_logic_vector(6 DOWNTO 0);
END PACKAGE;

PACKAGE BODY vec_mux_7_p IS
END PACKAGE BODY;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.vec_mux_7_p;

ENTITY vec_mux_7 IS
    GENERIC (
        inputs : NATURAL := 2
    );
    PORT (
        args : IN vec_mux_7_p.vec_mux_t(0 TO inputs);
        sel : IN NATURAL;
        output : OUT std_logic_vector(6 DOWNTO 0)
    );
END vec_mux_7;

ARCHITECTURE vec_mux_7_arch OF vec_mux_7 IS
BEGIN
    OUTPUT <= args(sel);
END vec_mux_7_arch;