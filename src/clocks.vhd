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
    SIGNAL clk_05Hz_s, clk_1Hz_s, clk_2Hz_s, clk_3Hz_s : std_logic;
BEGIN
    PROCESS (clk_50MHz, reset)
        VARIABLE count : INTEGER;
        CONSTANT count_05Hz : INTEGER := 50000000;
        CONSTANT count_1Hz : INTEGER := 25000000;
        CONSTANT count_2Hz : INTEGER := 12500000;
        CONSTANT count_3Hz : INTEGER := 6250000;
    BEGIN
        IF reset = '0' THEN
            count := 0;
        ELSIF clk_50MHz'event AND clk_50MHz = '1' THEN
            count := count + 1;

            IF count REM count_05Hz = 0 THEN
                clk_05Hz_s <= NOT clk_05Hz_s;
                clk_1Hz_s <= NOT clk_1Hz_s;
                clk_2Hz_s <= NOT clk_1Hz_s;
                clk_3Hz_s <= NOT clk_3Hz_s;
                count := 0;
            ELSIF count REM count_1Hz = 0 THEN
                clk_1Hz_s <= NOT clk_1Hz_s;
                clk_2Hz_s <= NOT clk_1Hz_s;
                clk_3Hz_s <= NOT clk_3Hz_s;
            ELSIF count REM count_2Hz = 0 THEN
                clk_2Hz_s <= NOT clk_2Hz_s;
                clk_3Hz_s <= NOT clk_3Hz_s;
            ELSIF count REM count_3Hz = 0 THEN
                clk_3Hz_s <= NOT clk_3Hz_s;
            END IF;
        END IF;
    END PROCESS;

    clk_05Hz <= clk_05Hz_s;
    clk_1Hz <= clk_1Hz_s;
    clk_2Hz <= clk_2Hz_s;
    clk_3Hz <= clk_3Hz_s;
END ARCHITECTURE;
