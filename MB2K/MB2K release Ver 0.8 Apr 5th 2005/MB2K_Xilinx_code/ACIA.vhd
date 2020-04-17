--
-- Simple ACIA - based on the Xilinx reference design with
-- 'psuedo 6850' status bits. Data format is always 16x clock, 8bits, 1stop bit, no parity
-- D.A.Rumball Version 1.0	 31-3-05
--
--
-- Library declarations
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
library unisim;
use unisim.vcomponents.all;
--
------------------------------------------------------------------------------------
--
--
entity ACIA is
    Port (              
     	-- buss interface signals
		clk      : in  Std_Logic;  -- System Clock
     	rst      : in  Std_Logic;  -- Reset input (active high)
     	cs       : in  Std_Logic;  -- Chip Select
     	rw       : in  Std_Logic;  -- Read / Not Write
     	addr     : in  Std_Logic_Vector(1 downto 0); -- Register Select address
     	datain   : in  Std_Logic_Vector(7 downto 0); -- Data Bus In 
     	dataout  : out Std_Logic_Vector(7 downto 0); -- Data Bus Out

		-- ACIA Signals
     	RxD      : in  Std_Logic;   -- Receive Data
     	TxD      : out Std_Logic;   -- Transmit Data
  	  	baudx16  : out Std_Logic   -- 16x baud rate clock out
		);
end ACIA;
--

architecture Behavioral of ACIA is
--
-- declarations
--
-- UART transmitter with integral 16 byte FIFO buffer
--
component uart_tx
	Port (            
		data_in          : in  std_logic_vector(7 downto 0);
		write_buffer     : in  std_logic;
		reset_buffer     : in  std_logic;
		en_16_x_baud     : in  std_logic;
		serial_out       : out std_logic;
		buffer_full      : out std_logic;
		buffer_half_full : out std_logic;
		clk              : in  std_logic
		);
end component;
--
-- UART Receiver with integral 16 byte FIFO buffer
--
component uart_rx
	Port (            
		serial_in           : in  std_logic;
		data_out            : out std_logic_vector(7 downto 0);
		read_buffer         : in  std_logic;
		reset_buffer        : in  std_logic;
		en_16_x_baud        : in  std_logic;
		buffer_data_present : out std_logic;
		buffer_full         : out std_logic;
		buffer_half_full    : out std_logic;
		clk                 : in  std_logic
		);
end component;

--
-- Signals
--
signal     baud_count      : integer range 0 to 8192 :=0;
signal     baudreg         : Std_Logic_Vector(12 downto 0); 

signal     rxdata          : Std_Logic_Vector(7 downto 0);   

signal     en_16_x_baud    : std_logic;

signal     write_to_uart   : std_logic;
signal     tx_full         : std_logic;
signal     tx_half_full    : std_logic;

signal     read_from_uart  : std_logic;
signal     rx_data_present : std_logic;
signal     rx_full         : std_logic;
signal     rx_half_full    : std_logic;

-- Start of circuit description
begin

-- Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
-- Each contains an embedded 16-byte FIFO buffer.
--
transmit: uart_tx port map 
	(
	data_in 			=> datain, 
	write_buffer 		=> write_to_uart,
	reset_buffer 		=> rst,
	en_16_x_baud 		=> en_16_x_baud,
	serial_out 		=> TxD,
	buffer_full 		=> tx_full,
	buffer_half_full 	=> tx_half_full,
	clk 				=> clk 
	);

receive: uart_rx port map 
	(            
	serial_in 		=> RxD,
     data_out 			=> rxdata,
     read_buffer 		=> read_from_uart,
     reset_buffer 		=> rst,
     en_16_x_baud 		=> en_16_x_baud,
     buffer_data_present => rx_data_present,
     buffer_full 		=> rx_full,
     buffer_half_full 	=> rx_half_full,
     clk 				=> clk 
	);  
  

-----------------------------------------------------------------------------
-- decode and data mux
-----------------------------------------------------------------------------

ACIA_decode:  process(cs, rw, addr)
begin

case addr(1 downto 0) is 

	when "00" =>				        -- status register (read only)
		write_to_uart        <= '0';
		read_from_uart       <= '0';
		dataout              <= "000" & rx_full & rx_half_full 
		                              & tx_half_full & not tx_full 
					               & rx_data_present;

     when "01" =>				
		if rw = '0' then		        -- data register write
			write_to_uart   <= cs;
			read_from_uart  <= '0';
			dataout         <= x"00";
		else
			write_to_uart   <= '0';	   -- data register read
          	read_from_uart  <= cs;
			dataout         <= rxdata;
		end if;

     when others =>
         	write_to_uart        <= '0';
		read_from_uart       <= '0';
		dataout              <= x"00";

end case;

end process;

-- Set baud rate for the ACIA
-- The baud rate is set by loading a divisor into the hi and lo baud rate regs
--	baud rate	   16xf	  div
--	---------	  -------   ----
--      300         4800   5208
--	  1200	    19200	  1302
--	  2400	    38400	   651
--	  4800	    76800	   326
--	  9600	   153600	   163
--	 19200	   307200	    81
--    38400       614400	    41
--    57600	   921600     27
--

-- baud clock register
baud_register: process (clk, rst)
begin
	if rst = '1' then   
		baudreg <= "0000000000000";
	elsif (clk'event and clk ='0') then 
		if (addr(1) = '1' and cs = '1') then 
			if addr(0) = '0' then
				baudreg(12 downto 8) <= datain(4 downto 0);
			else
				baudreg(7 downto 0)  <= datain;
			end if;
		else
			baudreg <= baudreg;
		end if; 
	end if;

end process;

baud_timer: process(clk)
begin
	if clk'event and clk='1' then
		if baud_count = baudreg then
			baud_count <= 0;
			en_16_x_baud <= '1';
		else
			baud_count <= baud_count + 1;
			en_16_x_baud <= '0';
		end if;
	end if;

baudx16 <= en_16_x_baud;

end process baud_timer;

end; --===================== End of architecture =======================--
