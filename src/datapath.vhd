LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.Numeric_Std.ALL;

ENTITY datapath IS
    PORT (
        R1, R2, E1, E2, E3, E4, SEL, clk_50MHz : IN std_logic;
        button_input : IN std_logic_vector(3 DOWNTO 0);
        setup_input : IN std_logic_vector(7 DOWNTO 0);
        end_fpga, end_user, end_time, win, match : OUT std_logic;
        seq_current, seq_input : OUT std_logic_vector(3 DOWNTO 0);
        hex0, hex1, hex2, hex3, hex4, hex5 : OUT std_logic_vector(6 DOWNTO 0)
    );
END datapath;

ARCHITECTURE datapath_arch OF datapath IS
    COMPONENT clocks IS
        PORT (
            reset, clk_50MHz : IN std_logic;
            clk_3Hz : OUT std_logic;
            clk_2Hz : OUT std_logic;
            clk_1Hz : OUT std_logic;
            clk_05Hz : OUT std_logic
        );
    END COMPONENT;

    COMPONENT button_sync IS
        PORT (
            KEY0, KEY1, KEY2, KEY3, CLK : IN std_logic;
            BTN0, BTN1, BTN2, BTN3 : OUT std_logic
        );
    END COMPONENT;

    COMPONENT mux IS
        PORT (
            arg0 : IN std_logic;
            arg1 : IN std_logic;
            arg2 : IN std_logic;
            arg3 : IN std_logic;
            sel : IN std_logic_vector(1 DOWNTO 0);
            data_out : OUT std_logic
        );
    END COMPONENT;

    COMPONENT vec_mux_4 IS
        PORT (
            arg0 : IN std_logic_vector(3 DOWNTO 0);
            arg1 : IN std_logic_vector(3 DOWNTO 0);
            arg2 : IN std_logic_vector(3 DOWNTO 0);
            arg3 : IN std_logic_vector(3 DOWNTO 0);
            sel : IN std_logic_vector(1 DOWNTO 0);
            data_out : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT vec_mux_7 IS
        PORT (
            arg0 : IN std_logic_vector(6 DOWNTO 0);
            arg1 : IN std_logic_vector(6 DOWNTO 0);
            sel : IN std_logic;
            data_out : OUT std_logic_vector(6 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT seq1 IS
        PORT (
            address : IN std_logic_vector(3 DOWNTO 0);
            data_out : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT seq2 IS
        PORT (
            address : IN std_logic_vector(3 DOWNTO 0);
            data_out : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT seq3 IS
        PORT (
            address : IN std_logic_vector(3 DOWNTO 0);
            data_out : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT seq4 IS
        PORT (
            address : IN std_logic_vector(3 DOWNTO 0);
            data_out : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT counter IS
        PORT (
            data : IN std_logic_vector(3 DOWNTO 0);
            rst, enable, clk : IN std_logic;
            reached : OUT std_logic;
            count : OUT std_logic_vector(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT reg IS
        GENERIC (
            data_width : INTEGER := 8
        );
        PORT (
            reset, enter, clk : IN std_logic;
            data : IN std_logic_vector(data_width - 1 DOWNTO 0);
            data_out : OUT std_logic_vector(data_width - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT decod7seg IS
        PORT (
            data : IN std_logic_vector(3 DOWNTO 0);
            data_out : OUT std_logic_vector(6 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk, clk_3Hz, clk_2Hz, clk_1Hz, clk_05Hz : std_logic;
    SIGNAL sync_buttons, nsync_buttons : std_logic_vector(3 DOWNTO 0);
    SIGNAL setup : std_logic_vector(7 DOWNTO 0);
    SIGNAL time_c, fpga_c, round_c, user_c : std_logic_vector(3 DOWNTO 0);
    SIGNAL seq_fpga, seq_user : std_logic_vector(3 DOWNTO 0);
    SIGNAL score : std_logic_vector(7 DOWNTO 0);
    SIGNAL out_fpga, out_user : std_logic_vector(63 DOWNTO 0);

    SIGNAL user_action, end_user_s, win_s : std_logic;
    SIGNAL seq1_output, seq2_output, seq3_output, seq4_output : std_logic_vector(3 DOWNTO 0);

    SIGNAL reg_fpga_in, reg_user_in : std_logic_vector(63 DOWNTO 0);
    SIGNAL hex4_0_block_in : std_logic_vector(3 DOWNTO 0);

    SIGNAL hex5_1_out, hex4_0_out, hex4_1_out, hex3_1_out, hex2_0_out, hex2_1_out, hex1_1_out, hex0_0_out, hex0_1_out : std_logic_vector(6 DOWNTO 0);
BEGIN
    --- BITES ZA DUSTO ---
    CLOCKS_CHOICE : clocks
    PORT MAP(
        reset => R1,
        clk_50MHz => clk_50MHz,
        clk_3Hz => clk_3Hz,
        clk_2Hz => clk_2Hz,
        clk_1Hz => clk_1Hz,
        clk_05Hz => clk_05Hz
    );

    CLOCK_MUX : mux
    PORT MAP(
        arg0 => clk_05Hz,
        arg1 => clk_1Hz,
        arg2 => clk_2Hz,
        arg3 => clk_3Hz,
        sel => setup(7 DOWNTO 6),
        data_out => clk
    );

    --- SMASH ---
    BUTTON_SYNC_BLOCK : button_sync
    PORT MAP(
        button_input(0), button_input(1), button_input(2), button_input(3),
        clk_50MHz,
        sync_buttons(0), sync_buttons(1), sync_buttons(2), sync_buttons(3)
    );

    nsync_buttons <= NOT sync_buttons;
    user_action <= '1' WHEN E2 = '1' AND (nsync_buttons(0) = '1' OR nsync_buttons(1) = '1' OR nsync_buttons(2) = '1' OR nsync_buttons(3) = '1') ELSE
        '0';

    --- TIK TAK ---
    COUNTER_TIME : counter
    PORT MAP(
        data => "1010",
        rst => R2,
        enable => E2,
        clk => clk_1Hz,
        reached => end_time,
        count => time_c
    );

    COUNTER_ROUND : counter
    PORT MAP(
        data => setup(3 DOWNTO 0),
        rst => R1,
        enable => E4,
        clk => clk_50MHz,
        reached => win_s,
        count => round_c
    );

    win <= win_s;

    COUNTER_FPGA : counter
    PORT MAP(
        data => round_c,
        rst => R2,
        enable => E3,
        clk => clk,
        reached => end_fpga,
        count => fpga_c
    );

    COUNTER_USER : counter
    PORT MAP(
        data => round_c,
        rst => R2,
        enable => user_action,
        clk => clk_50MHz,
        reached => end_user_s,
        count => user_c
    );

    end_user <= end_user_s;

    --- SEQUENCE ---
    SEQ1_BLOCK : seq1
    PORT MAP(
        address => fpga_c,
        data_out => seq1_output
    );

    SEQ2_BLOCK : seq2
    PORT MAP(
        address => fpga_c,
        data_out => seq2_output
    );

    SEQ3_BLOCK : seq3
    PORT MAP(
        address => fpga_c,
        data_out => seq3_output
    );

    SEQ4_BLOCK : seq4
    PORT MAP(
        address => fpga_c,
        data_out => seq4_output
    );

    SEQ_MUX : vec_mux_4
    PORT MAP(
        arg0 => seq1_output,
        arg1 => seq2_output,
        arg2 => seq3_output,
        arg3 => seq4_output,
        sel => setup(5 DOWNTO 4),
        data_out => seq_fpga
    );

    --- VAULT ---
    REG_SETUP : reg
    PORT MAP(
        reset => R1,
        enter => E1,
        clk => clk_50MHz,
        data => setup_input,
        data_out => setup
    );

    reg_fpga_in <= seq_fpga & out_fpga(63 DOWNTO 4);
    REG_FPGA : reg
    GENERIC MAP(
        data_width => 64
    )
    PORT MAP(
        reset => R2,
        enter => E3,
        clk => clk,
        data => reg_fpga_in,
        data_out => out_fpga
    );

    reg_user_in <= nsync_buttons & out_user(63 DOWNTO 4);
    REG_USER : reg
    GENERIC MAP(
        data_width => 64
    )
    PORT MAP(
        reset => R2,
        enter => user_action,
        clk => clk_50MHz,
        data => reg_user_in,
        data_out => out_user
    );

    --- EXTRA SHIT ---
    score <= std_logic_vector(unsigned(setup(7 DOWNTO 6) & "000000") + unsigned(round_c & "00") + unsigned(setup(5 DOWNTO 4)));
    match <= '1' WHEN end_user_s = '1' AND out_fpga = out_user ELSE
        '0';

    --- LIGHTSABERS OUT ---
    seq_current <= out_fpga(63 DOWNTO 60);
    seq_input <= button_input;

    --- HEXS HELL ---
    -- HEX5
    HEX5_1_MUX : vec_mux_7
    PORT MAP(
        arg0 => "0001110", -- F
        arg1 => "1000001", -- U
        sel => win_s,
        data_out => hex5_1_out
    );

    HEX5_MUX : vec_mux_7
    PORT MAP(
        arg0 => "1000111", -- L
        arg1 => hex5_1_out,
        sel => SEL,
        data_out => hex5
    );

    -- HEX4
    hex4_0_block_in <= "00" & setup(7 DOWNTO 6);
    HEX4_0_BLOCK : decod7seg
    PORT MAP(
        data => hex4_0_block_in,
        data_out => hex4_0_out
    );

    HEX4_1_MUX : vec_mux_7
    PORT MAP(
        arg0 => "0001100", -- P
        arg1 => "0010010", -- S
        sel => win_s,
        data_out => hex4_1_out
    );

    HEX4_MUX : vec_mux_7
    PORT MAP(
        arg0 => hex4_0_out,
        arg1 => hex4_1_out,
        sel => SEL,
        data_out => hex4
    );

    -- HEX3
    HEX3_1_MUX : vec_mux_7
    PORT MAP(
        arg0 => "0000100", -- g
        arg1 => "0000110", -- E
        sel => win_s,
        data_out => hex3_1_out
    );

    HEX3_MUX : vec_mux_7
    PORT MAP(
        arg0 => "0000111", -- t
        arg1 => hex3_1_out,
        sel => SEL,
        data_out => hex3
    );

    -- HEX2
    HEX2_0_BLOCK : decod7seg
    PORT MAP(
        data => time_c,
        data_out => hex2_0_out
    );

    HEX2_1_MUX : vec_mux_7
    PORT MAP(
        arg0 => "1001000", -- A
        arg1 => "0101111", -- r
        sel => win_s,
        data_out => hex2_1_out
    );

    HEX2_MUX : vec_mux_7
    PORT MAP(
        arg0 => hex2_0_out,
        arg1 => hex2_1_out,
        sel => SEL,
        data_out => hex2
    );

    -- HEX1
    HEX1_1_BLOCK : decod7seg
    PORT MAP(
        data => score(7 DOWNTO 4),
        data_out => hex1_1_out
    );

    HEX1_MUX : vec_mux_7
    PORT MAP(
        arg0 => "0101111", -- r
        arg1 => hex1_1_out,
        sel => SEL,
        data_out => hex1
    );

    -- HEX0
    HEX0_0_BLOCK : decod7seg
    PORT MAP(
        data => round_c,
        data_out => hex0_0_out
    );

    HEX0_1_BLOCK : decod7seg
    PORT MAP(
        data => score(3 DOWNTO 0),
        data_out => hex0_1_out
    );

    HEX0_MUX : vec_mux_7
    PORT MAP(
        arg0 => hex0_0_out,
        arg1 => hex0_1_out,
        sel => SEL,
        data_out => hex0
    );
END datapath_arch;
