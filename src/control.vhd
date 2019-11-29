LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY control IS
    PORT (
        enter, rst, end_fpga, end_user, end_time, win, match, clk : IN std_logic;
        R1, R2, E1, E2, E3, E4, SEL : OUT std_logic
    );
END control;

ARCHITECTURE control_arch OF control IS
    TYPE states_type IS (START, SETUP, PLAY_FPGA, PLAY_USER, CHECK, NEXT_ROUND, RESULT);
    SIGNAL state : states_type;
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF (rst = '1') THEN
            state <= START;
        ELSIF rising_edge(clk) THEN
            CASE state IS
                WHEN START =>
                    state <= SETUP;
                WHEN SETUP =>
                    IF enter = '1' THEN
                        state <= PLAY_FPGA;
                    END IF;
                WHEN PLAY_FPGA =>
                    IF end_fpga = '1' THEN
                        state <= PLAY_USER;
                    END IF;
                WHEN PLAY_USER =>
                    IF end_time = '1' THEN
                        state <= RESULT;
                    ELSIF end_user = '1' THEN
                        state <= CHECK;
                    END IF;
                WHEN CHECK =>
                    IF match = '1' THEN
                        state <= NEXT_ROUND;
                    ELSE
                        state <= RESULT;
                    END IF;
                WHEN NEXT_ROUND =>
                    IF win = '1' THEN
                        state <= RESULT;
                    ELSE
                        state <= PLAY_FPGA;
                    END IF;
                WHEN RESULT =>
                    state <= RESULT;
                WHEN OTHERS =>
                    state <= START;
            END CASE;
        END IF;
    END PROCESS;

    R1 <= '1' WHEN state = START ELSE
        '0';
    R2 <= '1' WHEN state = START OR state = NEXT_ROUND ELSE
        '0';

    E1 <= '1' WHEN state = SETUP ELSE
        '0';
    E2 <= '1' WHEN state = PLAY_USER ELSE
        '0';
    E3 <= '1' WHEN state = PLAY_FPGA ELSE
        '0';
    E4 <= '1' WHEN state = NEXT_ROUND AND win = '0' ELSE
        '0';

    SEL <= '1' WHEN state = RESULT ELSE
        '0';
END ARCHITECTURE;
