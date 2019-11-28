LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY top IS
    PORT (
        CLOCK_50 : IN std_logic;
        KEYS : IN std_logic_vector(3 DOWNTO 0);
        SW : IN std_logic_vector(9 DOWNTO 0);
        LEDR : OUT std_logic_vector(9 DOWNTO 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT std_logic_vector(7 DOWNTO 0)
    );
END top;

ARCHITECTURE top_arch IS
    COMPONENT datapath IS
        PORT (
            R1, R2, E1, E2, E3, E4, SEL, clk_50MHz : IN std_logic;
            input : IN std_logic_vector(3 DOWNTO 0);
            config : IN std_logic_vector(7 DOWNTO 0);
            end_fpga, end_user, end_time, win, match : OUT std_logic;
            seq_current, seq_input : OUT std_logic_vector(3 DOWNTO 0);
            hex0, hex1, hex2, hex3, hex4, hex5 : OUT std_logic_vector(6 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT control IS
        PORT (
            enter, rst, end_fpga, end_user, end_time, win, match, clk : IN std_logic;
            R1, R2, E1, E2, E3, E4, SEL : OUT std_logic;
        );
    END COMPONENT;

    SIGNAL R1, R2, E1, E2, E3, E4, SEL : std_logic;
    SIGNAL end_fpga, end_user, end_time, win, match : std_logic;
BEGIN
    DATAPATH : datapath
    PORT MAP(
        R1, R2, E1, E2, E3, E4, SEL,
        clk_50MHz => CLOCK_50,
        input => KEYS,
        config => SW(9 DOWNTO 2),
        end_fpga, end_user, end_time, win, match,
        seq_current => LEDR(3 DOWNTO 0);
        seq_input => LEDR(9 DOWNTO 6);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
    );

    CONTROL : control
    PORT MAP(
        enter => SW(0),
        rst => SW(1),
        end_fpga, end_user, end_time, win, match,
        clk => CLOCK_50,
        R1, R2, E1, E2, E3, E4, SEL
    );
END top_arch;
