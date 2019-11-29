LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY clocks IS
    PORT (
        reset, clk_50MHz : IN std_logic;
        clk_05Hz : OUT std_logic;
        clk_1Hz : OUT std_logic;
        clk_2Hz : OUT std_logic;
        clk_3Hz : OUT std_logic
    );
END clocks;

ARCHITECTURE clocks_arch OF clocks IS
    SIGNAL count_05Hz, count_1Hz, count_2Hz, count_3Hz : INTEGER := 0;
BEGIN
    PROCESS (clk_50MHz, reset)
    BEGIN
        IF reset = '1' THEN
            count_05Hz <= 0;
            count_1Hz <= 0;
            count_2Hz <= 0;
            count_3Hz <= 0;
        ELSIF rising_edge(clk_50MHz) THEN
            count_05Hz <= count_05Hz + 1;
            count_1Hz <= count_1Hz + 1;
            count_2Hz <= count_2Hz + 1;
            count_3Hz <= count_3Hz + 1;

            IF count_05Hz = 8 THEN
                count_05Hz <= 0;
                clk_05Hz <= '1';
            ELSE
                clk_05Hz <= '0';
            END IF;

            IF count_1Hz = 6 THEN
                count_1Hz <= 0;
                clk_1Hz <= '1';
            ELSE
                clk_1Hz <= '0';
            END IF;

            IF count_2Hz = 4 THEN
                count_2Hz <= 0;
                clk_2Hz <= '1';
            ELSE
                clk_2Hz <= '0';
            END IF;

            -- IF count_3Hz = 6250000 THEN
            IF count_3Hz = 2 THEN
                count_3Hz <= 0;
                clk_3Hz <= '1';
            ELSE
                clk_3Hz <= '0';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
