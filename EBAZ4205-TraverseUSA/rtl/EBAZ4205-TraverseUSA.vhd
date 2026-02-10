---------------------------------------------------------------------------------
--                        Traverse USA - EBAZ4205
--                           Code from DarFPGA
--
--                         Modified for EBAZ4205 
--                            by pinballwiz.org 
--                               08/02/2026
---------------------------------------------------------------------------------
-- Keyboard inputs :
--   5 : Add coin
--   2 : Start 2 players
--   1 : Start 1 player
--   LEFT Ctrl   : Accelerate
--   RIGHT arrow : Move Right
--   LEFT arrow  : Move Left
--   UP arrow    : Not Used
--   DOWN arrow  : Brake
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity traverse_ebaz4205 is
port(
	clock_50    : in std_logic;
   	I_RESET     : in std_logic;
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
	greenLED 	: out std_logic;
	redLED 	    : out std_logic;
   	ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
	joy         : in std_logic_vector(8 downto 0);
	led         : out std_logic_vector(7 downto 0)
);
end traverse_ebaz4205;
------------------------------------------------------------------------------
architecture struct of traverse_ebaz4205 is
 
 signal clock_36    : std_logic;
 signal clock_24    : std_logic;
 signal clock_18    : std_logic;
 signal clock_9     : std_logic;
 signal clock_7     : std_logic;
 signal clock_3p58  : std_logic;
 --
 signal video_r  : std_logic_vector(2 downto 0);
 signal video_g  : std_logic_vector(2 downto 0);
 signal video_b  : std_logic_vector(1 downto 0);
 --
 signal h_sync   : std_logic;
 signal v_sync	 : std_logic;
 --
 signal reset    : std_logic;
 --
 signal kbd_intr        : std_logic;
 signal kbd_scancode    : std_logic_vector(7 downto 0);
 signal joy_BBBBFRLDU   : std_logic_vector(9 downto 0);
 --
 signal SW_LEFT         : std_logic;
 signal SW_RIGHT        : std_logic;
 signal SW_UP           : std_logic;
 signal SW_DOWN         : std_logic;
 signal SW_FIRE         : std_logic;
 signal SW_BOMB         : std_logic;
 signal SW_COIN         : std_logic;
 signal P1_START        : std_logic;
 signal P2_START        : std_logic;
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
---------------------------------------------------------------------------
component traverse_clocks
port(
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_out3          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;
---------------------------------------------------------------------------
begin

 reset <= not I_RESET;
 greenLED <= '1'; -- turn off leds
 redLED   <= '1';

---------------------------------------------------------------------------
Clocks: traverse_clocks
    port map (
        clk_in1   => clock_50,
        clk_out1  => clock_36,       
        clk_out2  => clock_24,
        clk_out3  => clock_7

    );
---------------------------------------------------------------------------
-- Clocks Divide

process (Clock_36)
begin
 if rising_edge(Clock_36) then
	clock_18  <= not clock_18;
 end if;
end process;
--
process (Clock_18)
begin
 if rising_edge(Clock_18) then
	clock_9  <= not clock_9;
 end if;
end process;
--
process (Clock_7)
begin
 if rising_edge(Clock_7) then
	clock_3p58  <= not clock_3p58;
 end if;
end process;
--------------------------------------------------------------------------
-- input map

 SW_LEFT    <= joy_BBBBFRLDU(2) or not joy(0);
 SW_RIGHT   <= joy_BBBBFRLDU(3) or not joy(1);
 SW_UP      <= joy_BBBBFRLDU(0) or not joy(2);
 SW_DOWN    <= joy_BBBBFRLDU(1) or not joy(3);
 SW_FIRE    <= joy_BBBBFRLDU(4) or not joy(4);
 SW_BOMB    <= joy_BBBBFRLDU(8) or not joy(5);
 SW_COIN    <= joy_BBBBFRLDU(7); -- or not joy(6);
 P1_START   <= joy_BBBBFRLDU(5); -- or not joy(7);
 P2_START   <= joy_BBBBFRLDU(6); -- or not joy(8);
---------------------------------------------------------------------------
-- Main
pm : entity work.traverse_usa
port map (
	reset		 => reset,
	clock_36	 => clock_36,
	clock_24	 => clock_24,
	clock_3p58	 => clock_3p58,
    vga_r		 => video_r,
    vga_g		 => video_g,
    vga_b    	 => video_b,
    video_hs_out => h_sync,
    video_vs_out => v_sync,
	audio_out_l  => O_AUDIO_L,
	audio_out_r	 => O_AUDIO_R,
 	brake1	     => SW_DOWN,
	left1	     => SW_LEFT,
	right1	     => SW_RIGHT,
	accel1	     => SW_FIRE,
    coin1        => SW_COIN,
    start1       => P1_START,
    start2       => P2_START,
    AD           => AD
); 
-------------------------------------------------------------------------
-- vga output

	O_VIDEO_R 	<= video_r;
	O_VIDEO_G 	<= video_g;
	O_VIDEO_B 	<= video_b;
	O_HSYNC     <= h_sync;
	O_VSYNC     <= v_sync;
------------------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_9,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
------------------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk         => clock_9,
  kbdint      => kbd_intr,
  kbdscancode => std_logic_vector(kbd_scancode), 
  joy_BBBBFRLDU  => joy_BBBBFRLDU 
);
------------------------------------------------------------------------------
-- debug

process(reset, clock_24)
begin
  if reset = '1' then
   clock_4hz <= '0';
   counter_clk <= (others => '0');
  else
    if rising_edge(clock_24) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(7 downto 0) <= not AD(14 downto 7);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;
------------------------------------------------------------------------------
end struct;