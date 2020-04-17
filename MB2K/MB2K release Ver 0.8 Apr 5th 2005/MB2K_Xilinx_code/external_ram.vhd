--
-- External RAM interface
--
-- D.A.Rumball Version 1.0	 31-3-05
--

--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity external_ram is
    
    Port ( clk :      in std_logic;				      -- syatem clock
           rw :       in std_logic;				      -- read/*write
           ce :       in std_logic;					 -- enable for $0000 - $C000

           addr :     in std_logic_vector(15 downto 0);      -- address in from CPU
           map_addr : in std_logic_vector(11 downto 0);       --  map block address in from sysreg

		 data_in :  in std_logic_vector(7 downto 0);	      -- data in from CPU
           data_out : out std_logic_vector(7 downto 0);      -- data out to CPU

    		 ram_addr    : out Std_Logic_Vector(17 downto 0);	 
           ram_wen     : out Std_Logic;					 
           ram_oen     : out Std_Logic;

           ram1_cen    : out Std_Logic;
	      ram1_ubn    : out Std_Logic;
	      ram1_lbn    : out Std_Logic;
           ram1_data   : inout Std_Logic_Vector(15 downto 0);

           ram2_cen    : out Std_Logic;
	      ram2_ubn    : out Std_Logic;
	      ram2_lbn    : out Std_Logic;
           ram2_data   : inout Std_Logic_Vector(15 downto 0) );

end external_ram;

architecture Behavioral of external_ram is

  signal ram1_ce      : std_logic;
  signal ram1_ub      : std_logic;
  signal ram1_lb      : std_logic;
  signal ram2_ce      : std_logic;
  signal ram2_ub      : std_logic;
  signal ram2_lb      : std_logic;
  signal ram_we       : std_logic;
  signal ram_oe       : std_logic;

begin

ext_ram_control: process( clk, addr, rw, ce )

begin
	-- control strobes
	ram_we   <= (not rw) and clk;
	ram_oe   <= rw and clk;
	ram_wen  <= not ram_we;
	ram_oen  <= not ram_oe;

     ram1_ce   <= ce and (not addr(1));
     ram1_ub   <= not addr(0);
     ram1_lb   <= addr(0);
     ram1_cen  <= not ram1_ce;
     ram1_ubn  <= not ram1_ub;
     ram1_lbn  <= not ram1_lb;

     ram2_ce   <= ce and addr(1);
     ram2_ub   <= not addr(0);
     ram2_lb   <= addr(0);
     ram2_cen  <= not ram2_ce;
     ram2_ubn  <= not ram2_ub;
     ram2_lbn  <= not ram2_lb;

-- address partitioning
	if map_addr(11 downto 0) /= 0 then
		ram_addr(17 downto 6) <= map_addr(11 downto 0);
		ram_addr(5 downto 0) <= addr(7 downto 2);
	else
		ram_addr(17 downto 14) <= "0000";
		ram_addr(13 downto 0) <= addr(15 downto 2);
	end if;

-- write data to RAM mux
     if ram_we = '1' and ram1_ce = '1' and ram1_lb = '1' then
		ram1_data(7 downto 0)  <= data_in;
	else
     	ram1_data(7 downto 0)  <= "ZZZZZZZZ";
	end if;

     if ram_we = '1' and ram1_ce = '1' and ram1_ub = '1' then
		ram1_data(15 downto 8) <= data_in;
	else
     	ram1_data(15 downto 8)  <= "ZZZZZZZZ";
	end if;

     if ram_we = '1' and ram2_ce = '1' and ram2_lb = '1' then
		ram2_data(7 downto 0) <= data_in;
	else
     	ram2_data(7 downto 0)  <= "ZZZZZZZZ";
	end if;

     if ram_we = '1' and ram2_ce = '1' and ram2_ub = '1' then
		ram2_data(15 downto 8) <= data_in;
	else
     	ram2_data(15 downto 8)  <= "ZZZZZZZZ";
	end if;

-- read data from RAM mux
	case addr(1 downto 0) is
		when "00" =>
     	data_out <= ram1_data(15 downto 8);
		when "01" =>
     	data_out <= ram1_data(7 downto 0);
		when "10" =>
     	data_out <= ram2_data(15 downto 8);
     	when others =>
     	data_out <= ram2_data(7 downto 0);
     end case;

end process;

end Behavioral;
