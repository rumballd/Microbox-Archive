--
-- Address decode and CPU read data mux
--
-- D.A.Rumball Version 1.0	 31-3-05
--


-- Address map
		-- external RAM $0000 - $BFFF
	      -- internal RAM $C000 - $DFFF
                  -- MON09 scratch RAM/disk buffer/stack $DE00 - $DFFF
				-- stack space $DE00 - DE7F
				-- disk buffer $DE80 - DF7F
                        -- MON09 scratch RAM $DF80 - $DFFF
		-- ROM/IO space/reset vectors $E000 - $FFFF
			-- reserved	 $E000 - $E6FF
			-- IO space  $E780 - $E7FF
				-- eight I/O space slots (16 bytes each)
					-- system register       $E780
					-- keyboard registers    $E790
					-- ACIA1 registers       $E7A0
					-- external ROM          $E7B0
                         -- map registers         $E7C0
					-- display registers     $E7D0
					-- ACIA2 registers       $E7A0
					-- PROM reader registers $E7F0
			-- ROM       $E800 - FFFF

--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library UNISIM;
use UNISIM.VComponents.all;

entity decode_data_mux is
    Port ( 
    
 -- address and control lines
           addr : in std_logic_vector(15 downto 4); -- processor address
           vma :  in std_logic;				  -- valid address
           rw :   in std_logic;				  -- read/*write

 -- data into mux
           rom_data :     in std_logic_vector(7 downto 0); -- data from ROM
           int_ram_data : in std_logic_vector(7 downto 0); -- data from the internal RAM block
		 ext_ram_data : in std_logic_vector(7 downto 0); -- data from the external RAM block
           sysreg_data :  in std_logic_vector(7 downto 0); -- data from the system register
           keybrd_data :  in std_logic_vector(7 downto 0); -- data from the keyboard registers
           acia_data :    in std_logic_vector(7 downto 0); -- data from the UART registers
											    -- NOTE: dma registers are write only
           display_data : in std_logic_vector(7 downto 0); -- data from the display registers
           prom_data    : in std_logic_vector(7 downto 0); -- data from the prom reader
										   
 -- muxed data to CPU
           cpu_data : out std_logic_vector(7 downto 0); 

 -- address decodes
           rom :     out std_logic;
           int_ram : out std_logic;
           ext_ram : out std_logic;
 -- peripherals
		 sysreg :  out std_logic;
		 keybrd :  out std_logic;
		 acia    : out std_logic;
		 dma  :    out std_logic;
		 display : out std_logic;
		 promrd  : out std_logic

		);
end entity decode_data_mux;

architecture behavioral of decode_data_mux is

begin

addr_decode: process( addr, vma )
				  

--------------------------------------------
-- System address decode and CPU data-in mux
--------------------------------------------

begin
	
	case addr(15 downto 13) is
	
		-- ROM/display ram/IO space/reset vectors $E000 - $FFFF
		when "111" =>
		case addr(12 downto 11) is  
		
			-- display/IO space and ROM $E000 - $F800
			when "00" =>
			case addr(10 downto 7) is

				-- eight I/O space slots
				when "1111" =>
				case addr(6 downto 4) is 

					-- system register $E780
					when "000" =>
					cpu_data <= sysreg_data;
					rom     <= '0';
					int_ram <= '0';
        				ext_ram <= '0';
					sysreg  <= vma;
					keybrd  <= '0';
          			acia    <= '0';
          			dma     <= '0';
          			display <= '0';
          			promrd  <= '0';
										
					-- keyboard registerS $E790
					when "001" =>
					cpu_data <= keybrd_data;
					rom     <= '0';
					int_ram <= '0';
        				ext_ram <= '0';
					sysreg  <= '0';
					keybrd  <= vma;
          			acia    <= '0';
          			dma     <= '0';
          			display <= '0';
          			promrd  <= '0';
										
					-- ACIA registers $E7A0
					when "010" =>
					cpu_data <= acia_data;
					rom     <= '0';
					int_ram <= '0';
        				ext_ram <= '0';
        				sysreg  <= '0';
					keybrd  <= '0';
          			acia    <= vma;
          			dma     <= '0';
          			display <= '0';
           			promrd  <= '0';

					-- DMA registers $E7C0
					when "100" =>
					cpu_data <= x"00";	 -- map registers are read only!
					rom     <= '0';
					int_ram <= '0';
        				ext_ram <= '0';
					sysreg  <= '0';
					keybrd  <= '0';
          			acia    <= '0';
          			dma     <= vma;
          			display <= '0';
					promrd  <= '0';

					-- display registers $E7D0
					when "101" =>
					cpu_data <= display_data;
					rom     <= '0';
					int_ram <= '0';
        				ext_ram <= '0';
        				sysreg  <= '0';
					keybrd  <= '0';
          			acia    <= '0';
          			dma     <= '0';
          			display <= vma;
          			promrd  <= '0';

					-- PROM reader registers $E7F0
					when "111" =>
					cpu_data <= prom_data;
					rom     <= '0';
					int_ram <= '0';
        				ext_ram <= '0';
        				sysreg  <= '0';
					keybrd  <= '0';
          			acia    <= '0';
          			dma     <= '0';
          			display <= '0';
          			promrd  <= vma;

					-- default case (spare IO slots)
					when others =>
					cpu_data <= x"00";
					rom     <= '0';
					int_ram <= '0';
        				ext_ram <= '0';
        				sysreg  <= '0';
					keybrd  <= '0';
          			acia    <= '0';
          			dma     <= '0';
					display <= '0';
          			promrd  <= '0';

				end case;

				-- default case (display ram)	 $E000 - $F780
				when others =>
				cpu_data <= x"00";
				rom     <= '0';
				int_ram <= '0';
        			ext_ram <= '0';
        			sysreg  <= '0';
				keybrd  <= '0';
          		acia    <= '0';
         			dma     <= '0';
          		display <= '0';
           		promrd  <= '0';

			end case;

			-- default case (ROM)  $F800-FFFF
			when others =>
			cpu_data <= rom_data;
			rom     <= vma;
			int_ram <= '0';
     		ext_ram <= '0';
        		sysreg  <= '0';
			keybrd  <= '0';
          	acia    <= '0';
       		dma     <= '0';
          	display <= '0';
           	promrd  <= '0';

		end case;

		-- internal RAM $C000 - $DFFF
		when "110" =>  
			cpu_data <= int_ram_data;
          	rom     <= '0';
			int_ram <= vma;
        		ext_ram <= '0';
     	     sysreg  <= '0';
			keybrd  <= '0';
          	acia    <= '0';
          	dma     <= '0';
          	display <= '0';
           	promrd  <= '0';

		-- default case (external RAM) $0000 - $BFFF
		when others =>	
			cpu_data <= ext_ram_data;
			rom     <= '0';
			int_ram <= '0';
        		ext_ram <= vma;
        		sysreg  <= '0';
			keybrd  <= '0';
          	acia    <= '0';
          	dma     <= '0';
          	display <= '0';
          	promrd  <= '0';

	end case;

end process;

end architecture;
