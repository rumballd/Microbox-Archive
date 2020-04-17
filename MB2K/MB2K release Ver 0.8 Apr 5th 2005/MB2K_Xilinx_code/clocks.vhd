--
-- Clock generation for the system clock and display pixel clock
-- from the on board 50MHz clock. 
-- D.A.Rumball Version 1.0	 31-3-05
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity clocks is
    Port ( clk50M :  in std_logic;		 -- master 50MHz clock
           pixclk :  out std_logic;      -- displayclock 25MHz
           sysclk :  out std_logic       -- CPU and system clock 25MHz
	    );	 
end clocks;

architecture Behavioral of clocks is

signal clk_count : std_logic_vector(1 downto 0);	    -- 2 bit counter for system and vdu pixelclock

begin
 
-- global buffers for clocks
vdu_clk_buffer : BUFG port map(
    i => clk_count(0),
    o => pixclk
    );
	 	 
cpu_clk_buffer : BUFG port map(
    i => clk_count(0),
    o => sysclk
    );
	 
--------------------------------------------------- 
-- CPU/system clock (12.5MHz) and VDU clock (25MHz)
---------------------------------------------------
clocks : process( clk50M, clk_count )

begin

   if clk50M'event and clk50M ='0' then
	   clk_count <= clk_count + 1;
   end if;

end process;

end Behavioral;
