-- LIBRARY IEEE;

-- USE IEEE.std_logic_1164.ALL;

-- PACKAGE vec_mux_p IS
--     TYPE vec_mux_t IS ARRAY (NATURAL RANGE <>, NATURAL RANGE <>) OF std_logic_vector;
-- END PACKAGE;

-- PACKAGE BODY vec_mux_p IS
-- END PACKAGE BODY;

-- LIBRARY IEEE;
-- USE IEEE.std_logic_1164.ALL;
-- USE IEEE.numeric_std.ALL;
-- USE work.vec_mux_p;

-- ENTITY vec_mux IS
--     GENERIC (
--         inputs : NATURAL := 2;
--         size : NATURAL := 7
--     );
--     PORT (
--         args : IN vec_mux_p.vec_mux_t(0 TO inputs)(size - 1 DOWNTO 0);
--         sel : IN std_logic_vector(inputs - 1 DOWNTO 0);
--         output : OUT std_logic_vector(size - 1 DOWNTO 0)
--     );
-- END vec_mux;

-- ARCHITECTURE vec_mux_arch OF vec_mux IS
-- BEGIN
--     output <= args(to_integer(unsigned(sel)));
-- END vec_mux_arch;