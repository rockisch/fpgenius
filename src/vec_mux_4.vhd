LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY vec_mux_4 IS
    PORT (
        arg0 : IN std_logic_vector(3 DOWNTO 0);
        arg1 : IN std_logic_vector(3 DOWNTO 0);
        arg2 : IN std_logic_vector(3 DOWNTO 0);
        arg3 : IN std_logic_vector(3 DOWNTO 0);
        sel : IN std_logic_vector(1 downto 0);
        data_out : OUT std_logic_vector(3 DOWNTO 0)
    );
END vec_mux_4;

ARCHITECTURE vec_mux_4_arch OF vec_mux_4 IS
BEGIN
    data_out <= arg0 WHEN sel = "00" ELSE
        arg1 WHEN sel = "01" ELSE
        arg2 WHEN sel = "10" ELSE
        arg3;
END vec_mux_4_arch;
