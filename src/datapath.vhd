LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

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
    COMPONENT clocks IS
        PORT (
        reset, clk_50MHz : IN std_logic;
        clk_3Hz : OUT std_logic
        clk_2Hz : OUT std_logic;
        clk_1Hz : OUT std_logic;
        clk_05Hz : OUT std_logic;
    END COMPONENT;

    COMPONENT button_sync IS
        PORT (
            KEY0, KEY1, KEY2, KEY3, CLK : IN std_logic;
            BTN0, BTN1, BTN2, BTN3 : OUT std_logic
        );
    END COMPONENT;

    COMPONENT mux IS
        GENERIC (
            inputs : INTEGER
        );
        PORT (
            args : IN std_logic_vector(inputs - 1 DOWNTO 0);
            sel : IN NATURAL RANGE 0 TO inputs - 1;
            output : OUT std_logic
        )
    END COMPONENT;

    COMPONENT vec_mux IS
        GENERIC (
            inputs : INTEGER;
            size : INTEGER
        );
        PORT (
            args : IN vec_mux_args(0 TO inputs)(size - 1 DOWNTO 0);
            sel : IN NATURAL RANGE 0 TO inputs - 1;
            output : OUT std_logic_vector(size - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT seq1 IS
        PORT (
            address : IN std_logic_vector(3 DOWNTO 0);
            output : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT seq2 IS
        PORT (
            address : IN std_logic_vector(3 DOWNTO 0);
            output : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT seq3 IS
        PORT (
            address : IN std_logic_vector(3 DOWNTO 0);
            output : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT seq4 IS
        PORT (
            address : IN std_logic_vector(3 DOWNTO 0);
            output : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT counter IS
        PORT (
            rst, enable, clk : IN std_logic;
            data : IN std_logic_vector(3 DOWNTO 0);
            reached : OUT std_logic;
            count : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT reg IS
        GENERIC (
            data_width : INTEGER;
        );
        PORT (
            reset, enter, clk : IN std_logic;
            data : IN std_logic_vector(data_width);
            output : OUT std_logic_vector(data_width)
        );
    END COMPONENT;

    COMPONENT decod7seg IS
        PORT (
            data : IN std_logic_vector(3 DOWNTO 0);
            output : OUT std_logic_vector(6 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk, clk_3Hz, clk_2Hz, clk_1Hz, clk_05Hz : std_logic;
    SIGNAL s_input, ns_input : std_logic_vector(3 DOWNTO 0);
    SIGNAL config : std_logic_vector(7 DOWNTO 0);
    SIGNAL time_c, fpga_c, round, user_c : std_logic_vector(3 DOWNTO 0);
    SIGNAL seq_fpga, seq_user : std_logic_vector(3 DOWNTO 0);
    SIGNAL score : std_logic_vector(7 DOWNTO 0);
    SIGNAL out_fpga, out_user : std_logic_vector(63 DOWNTO 0);

    SIGNAL hex5_winner, hex4_winner, hex3_winner, hex2_winner : std_logic_vector(6 DOWNTO 0);
    SIGNAL hex4_decod, hex2_decod, hex1_decod, hex0_decod0, hex0_decod1 : std_logic_vector(6 DOWNTO 0);
BEGIN
    ---- INTERNAL ----
    CLOCKS : clocks
    PORT MAP(
        reset => R1,
        clk_50MHz,
        clk_3Hz,
        clk_2Hz,
        clk_1Hz,
        clk_05Hz
    );

    BUTTON_SYNC : button_sync
    PORT MAP(
        input(0), input(1), input(2), input(3),
        clk_50MHz,
        s_input(0), s_input(1), s_input(2), s_input(3)
    );

    ns_input <= NOT s_input;

    CLOCK_MUX : mux
    PORT MAP(
        args => (clk_05Hz, clk_1Hz, clk_2Hz, clk_3Hz),
        sel => config(7 DOWNTO 6),
        output => clk
    );

    REG_CONFIG : reg
    PORT MAP(
        reset => R1,
        enter => E1,
        clk => clk_50MHz,
        data => config_input,
        output => config
    );

    REG_FPGA : reg
    PORT MAP(
        reset => R2,
        enter => E3
        clk => clk,
        data => seq_fpga & out_fpga(63 DOWNTO 4),
        output => out_fpga
    );

    REG_USER : reg
    PORT MAP(
        reset => R2,
        enter => s_input /= "0000" AND E2 = '1',
        clk => clk_50MHz,
        data => ns_button & out_user(63 DOWNTO 4),
        output => out_user
    );

    score <= "00000000";

    match <= end_user = '1' AND out_fpga = out_fpga;

    ---- CONTROL COMMUNICATION ----
    COUNTER_TIME : counter
    PORT MAP(
        rst => R2,
        enable => E2,
        clk => clk_1Hz,
        data => "1010",
        reached => end_time,
        count => time_c
    );

    COUNTER_ROUND : counter
    PORT MAP(
        rst => R1,
        enable => E4,
        clk => clk_50MHz,
        reached => win,
        count => round
    );

    COUNTER_FPGA : counter
    PORT MAP(
        rst => R2,
        enable => E3,
        clk => clk,
        data => round,
        reached => end_fpga,
        count => fpga_c
    );

    SEQ1 : seq1
    PORT MAP(
        address : fpga_c,
        output : seq1_output
    );

    SEQ1 : seq2
    PORT MAP(
        address : fpga_c,
        output : seq2_output
    );

    SEQ1 : seq3
    PORT MAP(
        address : fpga_c,
        output : seq3_output
    );

    SEQ1 : seq4
    PORT MAP(
        address : fpga_c,
        output : seq4_output
    );

    SEQ_MUX : vec_mux
    GENERIC MAP(
        inputs => 4,
        size => 4
    )
    PORT MAP(
        args(0) => seq1_output,
        args(1) => seq2_output,
        args(2) => seq3_output,
        args(3) => seq4_output,
        sel => config(5 DOWNTO 4),
        output => seq_fpga
    );

    COUNTER_USER : counter
    PORT MAP(
        rst => R2,
        enable => s_input /= "0000" AND E2 = '1',
        clk => clk_50MHz,
        reached => end_user,
        count => user_c
    );

    ---- OUTPUTS ----
    seq_current <= out_fpga(63 DOWNTO 60);
    seq_input <= input;

    -- HEX5
    HEX5_WINNER : mux
    PORT MAP(
        args(0) => "", -- F
        args(1) => "", -- U
        sel => win,
        output => hex5_winner
    );

    HEX5_MUX : mux
    PORT MAP(
        args(0) => "", -- L
        args(1) => hex5_winner,
        sel => SEL,
        output => hex5
    );

    -- HEX4
    HEX4_WINNER : mux
    PORT MAP(
        args(0) => "", -- P
        args(1) => "", -- S
        sel => win,
        output => hex4_winner
    );

    HEX4_DECOD : decod7seg
    PORT MAP(
        data => "00" & config;
        output => hex4_decod
    );

    HEX4_MUX : mux
    PORT MAP(
        args(0) => hex4_decod,
        args(1) => hex4_winner,
        sel => SEL,
        output => hex4
    );

    -- HEX3
    HEX3_WINNER : mux
    PORT MAP(
        args(0) => "", -- g
        args(1) => "", -- E
        sel => win,
        output => hex3_winner
    );

    HEX3_MUX : mux
    PORT MAP(
        args(0) => "", -- t
        args(1) => hex3_winner,
        sel => SEL,
        output => hex3
    );

    -- HEX2
    HEX2_WINNER : mux
    PORT MAP(
        args(0) => "", -- A
        args(1) => "", -- r
        sel => win,
        output => hex2_winner
    );

    HEX2_DECOD : decod7sed
    PORT MAP(
        data => time_c,
        output => hex2_decod
    );

    HEX2_MUX : mux
    PORT MAP(
        args(0) => hex2_decod,
        args(1) => hex2_winner,
        sel => SEL,
        output => hex2
    );

    -- HEX1
    HEX1_DECOD decod7seg
    PORT MAP(
        data => score(7 DOWNTO 4),
        output => hex1_decod
    );

    HEX1_MUX : mux
    PORT MAP(
        args(0) => "", -- r
        args(1) => hex1_decod,
        sel => SEL,
        output => hex1
    );

    -- HEX0
    HEX0_DECOD0 : decod7seg
    PORT MAP(
        data => round,
        output => hex0_decod0
    );

    HEX0_DECOD1 : decod7seg
    PORT MAP(
        data => score(3 DOWNTO 0),
        output => hex0_decod1
    );

    HEX0_MUX : mux
    PORT MAP(
        args(0) => hex0_decod0,
        args(1) => hex0_decod1,
        sel => SEL,
        output => hex0
    );
END datapath_arch;
