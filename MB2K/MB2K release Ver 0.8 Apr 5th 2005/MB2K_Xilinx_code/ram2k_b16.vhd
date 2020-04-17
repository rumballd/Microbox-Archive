----------------------------------------------------------------
-- Generic 2K RAM
----------------------------------------------------------------

library IEEE, UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use UNISIM.vcomponents.all;

entity ram_2k is
    Port (
     clk   : in  std_logic;
	rst   : in  std_logic;
	cs    : in  std_logic;
	rw    : in  std_logic;
     addr  : in  std_logic_vector (10 downto 0);
     rdata : out std_logic_vector (7 downto 0);
     wdata : in  std_logic_vector (7 downto 0)
    );

end ram_2k;

architecture rtl of ram_2k is

   signal dp : std_logic_vector(0 downto 0);	-- loop parity bit output to input
   signal we  : std_logic;

begin
   
   RAM_0 : RAMB16_S9
   generic map (
      
	 INIT => X"000", --  Value of output RAM registers at startup
      SRVAL => X"000", --  Ouput value upon SSR assertion
      WRITE_MODE => "WRITE_FIRST" --  WRITE_FIRST, READ_FIRST or NO_CHANGES
	 
	 )

   port map (
      DO => rdata,                -- 8-bit Data Output
      DOP => dp,                  -- 1-bit parity Output
      ADDR => addr(10 downto 0),   -- 11-bit Address Input
      CLK => clk,                  -- Clock
      DI => wdata,                 -- 8-bit Data Input
      DIP => dp,                  -- 1-bit parity Input
      EN => cs,                   -- RAM Enable Input
      SSR => rst,                  -- Synchronous Set/Reset Input
      WE => we                     -- Write Enable Input
   );
   -- End of RAMB16_S9_inst instantiation

my_char_rom : process ( rw )

begin
	 we    <= not rw;
end process;

end architecture rtl;

