LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY vec_mux_7 IS
    PORT (
        arg0 : IN std_logic_vector(6 DOWNTO 0);
        arg1 : IN std_logic_vector(6 DOWNTO 0);
        sel : IN std_logic;
        data_out : OUT std_logic_vector(6 DOWNTO 0)
    );
END vec_mux_7;

ARCHITECTURE vec_mux_7_arch OF vec_mux_7 IS
BEGIN
    data_out <= arg0 WHEN sel = '0' ELSE
        arg1;
END vec_mux_7_arch;
