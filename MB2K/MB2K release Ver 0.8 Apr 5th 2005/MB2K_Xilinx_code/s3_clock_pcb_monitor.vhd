--
-- serial PROM reader from Xilinx app note XAPP694
--
-- D.A.Rumball Version 1.0	 31-3-05
--
--
------------------------------------------------------------------------------------
--
-- Library declarations
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;

entity prom_reader is
    Port (				   
    		--
		-- CPU signals
		--
     	clk      : in  Std_Logic;  				 -- System Clock
     	rst      : in  Std_Logic;   				 -- Reset input (active high)
     	cs       : in  Std_Logic;  				 -- PROM reader select
     	rw       : in  Std_Logic;  				 -- Read / Not Write
     	addr     : in  std_logic_vector(1 downto 0);  -- Register Select
     	rdata    : out Std_Logic_Vector(7 downto 0);  -- Data Bus Out
          --
	     -- external PROM Signals
	     --
          din : in std_logic;						 -- data bit from the PROM
          cclk : out std_logic;	   				 -- cclk to the PROM
          reset_prom : out std_logic	    			 -- OE/RESET to the PROM
		);
    end prom_reader;


architecture Behavioral of prom_reader is

-- Signals for serial PROM reader 
--
signal     prom_data         		: std_logic_vector(7 downto 0);	  -- data out
signal     read_pulse        		: std_logic;		-- +ve read pulse
signal     prom_read_pulse   		: std_logic;		-- -ve read pulse
signal     reset_pulse       		: std_logic;		-- +ve reset pulse
signal     prom_sync_pulse   		: std_logic;		-- -ve sync found pulse
signal     prom_data_ready_pulse 	: std_logic;		-- -ve data ready pulse
signal     prom_sync         		: std_logic;		-- sync found status bit	(bit 0)
signal     prom_data_ready   		: std_logic;		-- data ready status bit	(bit 1)


-- declaration of serial configuration PROM reading interface
--
  component prom_reader_serial
    generic(    length : integer := 5;                      --sync pattern 2^length
             frequency : integer := 12 );                   --system clock speed in MHz
    port(        clock : in std_logic; 
                 reset : in std_logic;                      --active high! (not low as docs)
                  read : in std_logic;                      --active low single cycle pulse
             next_sync : in std_logic;                      --active low single cycle pulse
                   din : in std_logic;
          sync_pattern : in std_logic_vector((2**length) - 1 downto 0);
                  cclk : out std_logic;
                  sync : out std_logic;                     --active low single cycle pulse
            data_ready : out std_logic;                     --active low single cycle pulse
            reset_prom : out std_logic;                     --active high to /OE of PROM (reset when high)
                  dout : out std_logic_vector(7 downto 0));
  end component;

  -- This macro enables data stored afater the Spartan-3 configuration data to be located and then read
  -- sequentially.
  --
begin

  prom_access: prom_reader_serial
  generic map(    length => 5,                      --Synchronisation pattern is 2^5 = 32 bits
               frequency => 12)                     --System clock rate is 50MHz
  port map(        clock => clk,  
                   reset => reset_pulse,            --reset reader and initiates search for sysnc pattern         
                    read => prom_read_pulse,        --active low pulse initiates retrieval of next byte
               next_sync => '1',                    --would be used to find another sync pattern
                     din => din,                    --from XCF02S device
            sync_pattern => X"8F9FAFBF",            --32bit synchronisation pattern is constant in this application
                    cclk => cclk,                   --to XCF02S device
                    sync => prom_sync_pulse,        --active low pulse indicates sync pattern located
              data_ready => prom_data_ready_pulse,  --active low pulse indicates data byte received
              reset_prom => reset_prom,             --to XCF02S device
                    dout => prom_data);             --byte received from serial prom
  --
  prom_interface_logic: process(clk, addr(1 downto 0))
  begin
    
	--Need to 'latch' (synchronously) the status pulses so they can be read by the processor using polling.
     --These are cleared by a prom reset or read.
	if clk'event and clk='1' then

      if prom_read_pulse='0' or rst='1' then
           prom_data_ready <= '0';
        elsif prom_data_ready_pulse='0' then
           prom_data_ready <= '1';
        else
           prom_data_ready <= prom_data_ready;
      end if;

      if prom_read_pulse='0' or rst='1' then
           prom_sync <= '0';
        elsif prom_sync_pulse='0' then
           prom_sync <= '1';
        else
           prom_sync <= prom_sync;
      end if;

	end if;

	  prom_read_pulse <= not read_pulse;

	-- Decode address bit, mux data outputs
   	case addr(1 downto 0) is

		when "00" => 			-- read data byte
		   rdata <= prom_data;
		   read_pulse <= cs; 
		   reset_pulse <= '0';
		   										  
		when "01" => 		     -- read status bits
		   rdata <= "000000" & prom_data_ready & prom_sync;
		   read_pulse <= '0'; 
		   reset_pulse <= '0'; 

		 when "10" => 		     -- reset & start sync search
		   rdata <= x"00";
		   read_pulse <= '0'; 
		   reset_pulse <= cs; 

		 when others => 	     -- default case (save for next sync?)
		   rdata <= x"00";
		   read_pulse <= '0'; 
		   reset_pulse <= '0'; 

	end case;

  end process prom_interface_logic;



------------------------------------------------------------------------------------------------------------------------------------

end Behavioral;
