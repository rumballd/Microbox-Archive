--
-- System register and map registers
-- D.A.Rumball Version 1.0	 31-3-05
--


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;


entity system_regs is
   port ( 
   		-- bus signals
   		a0       : in    std_logic; 
          clk      : in    std_logic; 
          rst      : in    std_logic; 
          rw       : in    std_logic; 
          datain   : in    std_logic_vector (7 downto 0); 

		-- enables
		mapr     : in    std_logic; 
          sysr     : in    std_logic;
		
		-- misc system bits out
          mapout   : out   std_logic_vector (11 downto 0);  
          bell     : out   std_logic; 	   -- buzzer enable
          scl      : out   std_logic; 	   -- I2C buss clock line
          sda      : out   std_logic; 	   -- I2C buss data line
          spare    : out   std_logic	   -- DWISOTT
	   );
end system_regs;

architecture BEHAVIORAL of system_regs is

-- registers
signal sysreg 	    : std_logic_vector(3 downto 0);	-- system register
signal mapreg 	    : std_logic_vector(11 downto 0);	-- map register
signal baudreg	    : std_logic_vector(12 downto 0);	-- baud clock gen register

begin

-- system register
process (clk, rst)
begin
	if rst = '1' then   
		sysreg <= "0000";
	elsif (clk'event and clk ='1') then 
		if (sysr = '1' and rw = '0') then 
			sysreg <= datain(3 downto 0);
		else
			sysreg <= sysreg;
		end if; 
	end if;

bell  <= sysreg(3);
spare <= sysreg(2);
scl   <= sysreg(1);
sda   <= sysreg(0);

end process;

-- map register
process (clk, rst)
begin
	if rst = '1' then   
		mapreg <= "000000000000";
	elsif (clk'event and clk ='1') then 
		if (mapr = '1' and rw = '0') then 
			if a0 = '0' then
				mapreg(11 downto 8) <= datain(3 downto 0);
			else
				mapreg(7 downto 0)  <= datain;
			end if;
		else
			mapreg <= mapreg;
		end if; 
	end if;

mapout <= mapreg;

end process;
 
end BEHAVIORAL;

