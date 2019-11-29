LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY reg IS
    GENERIC (
        data_width : INTEGER := 8
    );
    PORT (
        reset, enter, clk : IN std_logic;
        data : IN std_logic_vector(data_width-1 downto 0);
        output : OUT std_logic_vector(data_width-1 downto 0)
    );
END reg;

ARCHITECTURE reg_arch OF reg IS
BEGIN
    PROCESS (clk, enter, reset)
    BEGIN
        IF reset = '0' THEN
            output <= (OTHERS => '0');
        ELSIF clk'event AND clk = '1' THEN
            IF enter = '1' THEN
                output <= data;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
