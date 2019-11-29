LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY counter IS
    PORT (
        data : IN std_logic_vector(3 DOWNTO 0);
        rst, enable, clk : IN std_logic;
        reached : OUT std_logic;
        count : OUT std_logic_vector(3 DOWNTO 0)
    );
END counter;

ARCHITECTURE counter_arch OF counter IS
    SIGNAL c : std_logic_vector(3 DOWNTO 0);
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            c <= "0000";
        ELSIF rising_edge(clk) THEN
            IF enable = '1' THEN
                c <= c + 1;
            END IF;
        END IF;
    END PROCESS;

    count <= c;
    reached <= '1' WHEN c = data ELSE '0';
END counter_arch;
