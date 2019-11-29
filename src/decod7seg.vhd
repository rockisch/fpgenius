LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY decod7seg IS
    PORT (
        data : IN std_logic_vector(3 DOWNTO 0);
        output : OUT std_logic_vector(6 DOWNTO 0)
    );
END decod7seg;

ARCHITECTURE decod7seg_arch OF decod7seg IS
BEGIN
    output <= "1000000" WHEN data = "0000" ELSE
        "1111001" WHEN data = "0001" ELSE
        "0100100" WHEN data = "0010" ELSE
        "0110000" WHEN data = "0011" ELSE
        "0011001" WHEN data = "0100" ELSE
        "0010010" WHEN data = "0101" ELSE
        "0000010" WHEN data = "0110" ELSE
        "1111000" WHEN data = "0111" ELSE
        "0000000" WHEN data = "1000" ELSE
        "0010000" WHEN data = "1001" ELSE
        "0001000" WHEN data = "1010" ELSE
        "0000111" WHEN data = "1011" ELSE
        "1000110" WHEN data = "1100" ELSE
        "1011110" WHEN data = "1101" ELSE
        "0000110" WHEN data = "1110" ELSE
        "0001110";
END ARCHITECTURE;
