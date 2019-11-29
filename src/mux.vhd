LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;

ENTITY mux IS
    PORT (
        arg0 : IN std_logic;
        arg1 : IN std_logic;
        arg2 : IN std_logic;
        arg3 : IN std_logic;
        sel : IN std_logic_vector(1 downto 0);
        data_out : OUT std_logic
    );
END mux;

ARCHITECTURE mux_arch OF mux IS
BEGIN
    data_out <= arg0 WHEN sel = "00" ELSE
        arg1 WHEN sel = "01" ELSE
        arg2 WHEN sel = "10" ELSE
        arg3;
END mux_arch;
