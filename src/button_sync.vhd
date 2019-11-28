LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

ENTITY button_sync IS
	PORT (
		KEY0, KEY1, KEY2, KEY3, CLK : IN std_logic;
		BTN0, BTN1, BTN2, BTN3 : OUT std_logic
	);
END button_sync;

ARCHITECTURE button_sync_arch OF button_sync IS
	TYPE STATES IS (EsperaApertar, SaidaAtiva, EsperaSoltar);
	SIGNAL btn0state, btn1state, btn2state, btn3state : STATES := EsperaApertar;
	SIGNAL btn0next, btn1next, btn2next, btn3next : STATES := EsperaApertar;
BEGIN
	PROCESS (clk)
	BEGIN
		IF clk'event AND clk = '1' THEN -- Resposta na transicao positiva do clock
			btn0state <= btn0next;
			btn1state <= btn1next;
			btn2state <= btn2next;
			btn3state <= btn3next;
		END IF;
	END PROCESS;

	PROCESS (key0, btn0state)
	BEGIN
		CASE btn0state IS
			WHEN EsperaApertar =>
				IF key0 = '0' THEN
					btn0next <= SaidaAtiva;
				ELSE
					btn0next <= EsperaApertar;
				END IF;
				btn0 <= '1';
			WHEN SaidaAtiva =>
				IF key0 = '0' THEN
					btn0next <= EsperaSoltar;
				ELSE
					btn0next <= EsperaApertar;
				END IF;
				btn0 <= '0';
			WHEN EsperaSoltar =>
				IF key0 = '0' THEN
					btn0next <= EsperaSoltar;
				ELSE
					btn0next <= EsperaApertar;
				END IF;
				btn0 <= '1';
		END CASE;
	END PROCESS;

	PROCESS (key1, btn1state)
	BEGIN
		CASE btn1state IS
			WHEN EsperaApertar =>
				IF key1 = '0' THEN
					btn1next <= SaidaAtiva;
				ELSE
					btn1next <= EsperaApertar;
				END IF;
				btn1 <= '1';
			WHEN SaidaAtiva =>
				IF key1 = '0' THEN
					btn1next <= EsperaSoltar;
				ELSE
					btn1next <= EsperaApertar;
				END IF;
				btn1 <= '0';
			WHEN EsperaSoltar =>
				IF key1 = '0' THEN
					btn1next <= EsperaSoltar;
				ELSE
					btn1next <= EsperaApertar;
				END IF;
				btn1 <= '1';
		END CASE;
	END PROCESS;

	PROCESS (key2, btn2state)
	BEGIN
		CASE btn2state IS
			WHEN EsperaApertar =>
				IF key2 = '0' THEN
					btn2next <= SaidaAtiva;
				ELSE
					btn2next <= EsperaApertar;
				END IF;
				btn2 <= '1';
			WHEN SaidaAtiva =>
				IF key2 = '0' THEN
					btn2next <= EsperaSoltar;
				ELSE
					btn2next <= EsperaApertar;
				END IF;
				btn2 <= '0';
			WHEN EsperaSoltar =>
				IF key2 = '0' THEN
					btn2next <= EsperaSoltar;
				ELSE
					btn2next <= EsperaApertar;
				END IF;
				btn2 <= '1';
		END CASE;
	END PROCESS;

	PROCESS (key3, btn3state)
	BEGIN
		CASE btn3state IS
			WHEN EsperaApertar =>
				IF key3 = '0' THEN
					btn3next <= SaidaAtiva;
				ELSE
					btn3next <= EsperaApertar;
				END IF;
				btn3 <= '1';
			WHEN SaidaAtiva =>
				IF key3 = '0' THEN
					btn3next <= EsperaSoltar;
				ELSE
					btn3next <= EsperaApertar;
				END IF;
				btn3 <= '0';
			WHEN EsperaSoltar =>
				IF key3 = '0' THEN
					btn3next <= EsperaSoltar;
				ELSE
					btn3next <= EsperaApertar;
				END IF;
				btn3 <= '1';
		END CASE;
	END PROCESS;
END button_sync_arch;
