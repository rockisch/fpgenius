LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;

ENTITY datapath IS
    PORT (
        R1, R2, E1, E2, E3, E4, SEL, clk_50MHz : IN std_logic;
        input : IN std_logic_vector(3 DOWNTO 0);
        config_input : IN std_logic_vector(7 DOWNTO 0);
        end_fpga, end_user, end_time, win, match : OUT std_logic;
        seq_current, seq_input : OUT std_logic_vector(3 DOWNTO 0);
        hex0, hex1, hex2, hex3, hex4, hex5 : OUT std_logic_vector(6 DOWNTO 0)
    );
END datapath;

ARCHITECTURE datapath_arch OF datapath IS
    SIGNAL clk, clk_3Hz, clk_2Hz, clk_1Hz, clk_05Hz : std_logic;
    SIGNAL s_input, ns_input : std_logic_vector(3 DOWNTO 0);
    SIGNAL config : std_logic_vector(7 DOWNTO 0);
    SIGNAL time_c, fpga_c, round_c, user_c : std_logic_vector(3 DOWNTO 0);
    SIGNAL seq_fpga, seq_user : std_logic_vector(3 DOWNTO 0);
    SIGNAL score : std_logic_vector(7 DOWNTO 0);
    SIGNAL out_fpga, out_user : std_logic_vector(63 DOWNTO 0);

    SIGNAL reg_user_enter, counter_user_enable, end_user_s, win_s : std_logic;
    SIGNAL SEL_I, win_s_i : INTEGER;
    SIGNAL seq1_output, seq2_output, seq3_output, seq4_output : std_logic_vector(3 DOWNTO 0);

    SIGNAL hex5_winner, hex4_winner, hex3_winner, hex2_winner : std_logic_vector(6 DOWNTO 0);
    SIGNAL hex4_decod, hex2_decod, hex1_decod, hex0_decod0, hex0_decod1 : std_logic_vector(6 DOWNTO 0);
BEGIN
    ---- DUMB CONVERSIONS -----
    SEL_I <= 1 WHEN SEL = '1' ELSE
        0;
    win <= win_s;
    win_s_i <= 1 WHEN win_s = '1' ELSE
        0;

    ---- INTERNAL ----
    CLOCKS_CHOICE : ENTITY work.clocks
        PORT MAP(
            reset => R1,
            clk_50MHz => clk_50MHz,
            clk_3Hz => clk_3Hz,
            clk_2Hz => clk_2Hz,
            clk_1Hz => clk_1Hz,
            clk_05Hz => clk_05Hz
        );

    BUTTON_SYNC_BLOCK : ENTITY work.button_sync
        PORT MAP(
            input(0), input(1), input(2), input(3),
            clk_50MHz,
            s_input(0), s_input(1), s_input(2), s_input(3)
        );

    ns_input <= NOT s_input;

    CLOCK_MUX : ENTITY work.mux
        PORT MAP(
            args => (clk_05Hz, clk_1Hz, clk_2Hz, clk_3Hz),
            sel => to_integer(unsigned(config(7 DOWNTO 6))),
            output => clk
        );

    REG_CONFIG : ENTITY work.reg
        PORT MAP(
            reset => R1,
            enter => E1,
            clk => clk_50MHz,
            data => config_input,
            output => config
        );

    REG_FPGA : ENTITY work.reg
        GENERIC MAP(
            data_width => 64
        )
        PORT MAP(
            reset => R2,
            enter => E3,
            clk => clk,
            data => seq_fpga & out_fpga(63 DOWNTO 4),
            output => out_fpga
        );

    reg_user_enter <= '1' WHEN (NOT s_input = "0000") AND E2 = '1' ELSE
        '0';

    REG_USER : ENTITY work.reg
        GENERIC MAP(
            data_width => 64
        )
        PORT MAP(
            reset => R2,
            enter => reg_user_enter,
            clk => clk_50MHz,
            data => ns_input & out_user(63 DOWNTO 4),
            output => out_user
        );

    score <= std_logic_vector(unsigned(config(7 DOWNTO 6) & "000000") + unsigned(round_c & "00") + unsigned(config(5 DOWNTO 4)));

    match <= '1' WHEN end_user_s = '1' AND out_fpga = out_user ELSE
        '0';

    ---- CONTROL COMMUNICATION ----
    COUNTER_TIME : ENTITY work.counter
        PORT MAP(
            rst => R2,
            enable => E2,
            clk => clk_1Hz,
            data => "1010",
            reached => end_time,
            count => time_c
        );

    COUNTER_ROUND : ENTITY work.counter
        PORT MAP(
            rst => R1,
            enable => E4,
            clk => clk_50MHz,
            data => config(3 DOWNTO 0),
            reached => win_s,
            count => round_c
        );

    COUNTER_FPGA : ENTITY work.counter
        PORT MAP(
            rst => R2,
            enable => E3,
            clk => clk,
            data => round_c,
            reached => end_fpga,
            count => fpga_c
        );

    SEQ1_BLOCK : ENTITY work.seq1
        PORT MAP(
            address => fpga_c,
            output => seq1_output
        );

    SEQ2_BLOCK : ENTITY work.seq2
        PORT MAP(
            address => fpga_c,
            output => seq2_output
        );

    SEQ3_BLOCK : ENTITY work.seq3
        PORT MAP(
            address => fpga_c,
            output => seq3_output
        );

    SEQ4_BLOCK : ENTITY work.seq4
        PORT MAP(
            address => fpga_c,
            output => seq4_output
        );

    SEQ_MUX : ENTITY work.vec_mux_4
        GENERIC MAP(
            inputs => 4
        )
        PORT MAP(
            args(0) => seq1_output,
            args(1) => seq2_output,
            args(2) => seq3_output,
            args(3) => seq4_output,
            sel => to_integer(unsigned(config(5 DOWNTO 4))),
            output => seq_fpga
        );

    counter_user_enable <= '1' WHEN (NOT s_input = "0000");

    COUNTER_USER : ENTITY work.counter
        PORT MAP(
            rst => R2,
            enable => counter_user_enable,
            clk => clk_50MHz,
            data => round_c,
            reached => end_user_s,
            count => user_c
        );

    end_user <= end_user_s;

    ---- OUTPUTS ----
    seq_current <= out_fpga(63 DOWNTO 60);
    seq_input <= input;

    -- HEX5
    HEX5_WINNER_MUX : ENTITY work.vec_mux_7
        PORT MAP(
            args(0) => "0000000", -- F
            args(1) => "0000000", -- U
            sel => win_s_i,
            output => hex5_winner
        );

    HEX5_MUX : ENTITY work.vec_mux_7
        PORT MAP(
            args(0) => "0000000", -- L
            args(1) => hex5_winner,
            sel => SEL_I,
            output => hex5
        );

    -- HEX4
    HEX4_WINNER_MUX : ENTITY work.vec_mux_7
        PORT MAP(
            args(0) => "0000000", -- P
            args(1) => "0000000", -- S
            sel => win_s_i,
            output => hex4_winner
        );

    HEX4_DECOD_BLOCK : ENTITY work.decod7seg
        PORT MAP(
            data => "00" & config(7 downto 6),
            output => hex4_decod
        );

    HEX4_MUX : ENTITY work.vec_mux_7
        PORT MAP(
            args(0) => hex4_decod,
            args(1) => hex4_winner,
            sel => SEL_I,
            output => hex4
        );

    -- HEX3
    HEX3_WINNER_MUX : ENTITY work.vec_mux_7
        PORT MAP(
            args(0) => "0000000", -- g
            args(1) => "0000000", -- E
            sel => win_s_i,
            output => hex3_winner
        );

    HEX3_MUX : ENTITY work.vec_mux_7
        PORT MAP(
            args(0) => "0000000", -- t
            args(1) => hex3_winner,
            sel => SEL_I,
            output => hex3
        );

    -- HEX2
    HEX2_WINNER_MUX : ENTITY work.vec_mux_7
        PORT MAP(
            args(0) => "0000000", -- A
            args(1) => "0000000", -- r
            sel => win_s_i,
            output => hex2_winner
        );

    HEX2_DECOD_BLOCK : ENTITY work.decod7seg
        PORT MAP(
            data => time_c,
            output => hex2_decod
        );

    HEX2_MUX : ENTITY work.vec_mux_7
        PORT MAP(
            args(0) => hex2_decod,
            args(1) => hex2_winner,
            sel => SEL_I,
            output => hex2
        );

    -- HEX1
    HEX1_DECOD_BLOCK : ENTITY work.decod7seg
        PORT MAP(
            data => score(7 DOWNTO 4),
            output => hex1_decod
        );

    HEX1_MUX : ENTITY work.vec_mux_7
        PORT MAP(
            args(0) => "0000000", -- r
            args(1) => hex1_decod,
            sel => SEL_I,
            output => hex1
        );

    -- HEX0
    HEX0_DECOD0_BLOCK : ENTITY work.decod7seg
        PORT MAP(
            data => round_c,
            output => hex0_decod0
        );

    HEX0_DECOD1_BLOCK : ENTITY work.decod7seg
        PORT MAP(
            data => score(3 DOWNTO 0),
            output => hex0_decod1
        );

    HEX0_MUX : ENTITY work.vec_mux_7
        PORT MAP(
            args(0) => hex0_decod0,
            args(1) => hex0_decod1,
            sel => SEL_I,
            output => hex0
        );
END datapath_arch;