LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY reg IS
    GENERIC (
        data_width : INTEGER := 8
    );
    PORT (
        reset, enter, clk : IN std_logic;
        data : IN std_logic_vector(data_width - 1 DOWNTO 0);
        data_out : OUT std_logic_vector(data_width - 1 DOWNTO 0)
    );
END reg;

ARCHITECTURE reg_arch OF reg IS
BEGIN
    PROCESS (clk, enter, reset)
    BEGIN
        IF reset = '1' THEN
            data_out <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF enter = '1' THEN
                data_out <= data;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
