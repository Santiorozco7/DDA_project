----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2023 08:19:34 AM
-- Design Name: 
-- Module Name: datapath - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
    Port ( data_in : in STD_LOGIC_VECTOR (23 downto 0);
           data_out : out STD_LOGIC_VECTOR (23 downto 0);
           sel_mux : in STD_LOGIC;
           en_r : in STD_LOGIC;
           clk: in std_logic;
           rst: in std_logic
           );
end entity;

architecture rtl of datapath is

component reg is
	generic (N	:integer:=8 );
	
port(
        clk: in 		std_logic;
        en: in std_logic;
        rst: in           std_logic;
        clr: in           std_logic;
        d: in 		std_logic_vector(N-1 downto 0);
        q: out	std_logic_vector(N-1 downto 0)
	);
end component;

component barrel_shifter is
    port (
        data_in  : in  std_logic_vector(23 downto 0);
        shift    : in  std_logic_vector(4 downto 0);
        data_out : out std_logic_vector(23 downto 0)
    );
end component;

component add_sub is	
    port(
        data_in, shifter: in    std_logic_vector(23 downto 0);
        signo:   in    std_logic;
        data_out: out  std_logic_vector(23 downto 0)   
	);
end component;

component rom is
    port(
    clk  : in  std_logic;
    addr : in  std_logic_vector(4 downto 0);
    data : out std_logic_vector(23 downto 0)
    );
end component;

--signals of mux
signal mux_rx_out,mux_ry_out,mux_rz_out: std_logic_vector(23 downto 0);

--signals of reg
signal reg_x_out,reg_y_out,reg_z_out: std_logic_vector(23 downto 0);

--signals of add_sub
signal add_sub_x_out,add_sub_y_out,add_sub_z_out: std_logic_vector(23 downto 0);
signal bit_signo, not_bit_signo: std_logic;

--signals of barrel shifter
signal shift_x_out, shift_y_out: std_logic_vector(23 downto 0);
signal n_shift: std_logic_vector(4 downto 0);

--signal of rom
signal rom_out: std_logic_vector(23 downto 0);
signal addr: std_logic_vector(4 downto 0);

begin

-- The r X mutiplexer
mux_rx_out<=add_sub_x_out(23 downto 0) when (sel_mux='0') else data_in;

-- The remainder register
regx: reg 
    generic map(N=>24)
    port map(
    clk=>clk,
    rst=>rst,
    clr=>'0',
    en=>en_r,
    d=>mux_rx_out,
    q=>reg_x_out
    );

-- The r Y mutiplexer
mux_ry_out<=add_sub_y_out(23 downto 0) when (sel_mux='0') else data_in;

-- The remainder register
regy: reg 
    generic map(N=>24)
    port map(
    clk=>clk,
    rst=>rst,
    clr=>'0',
    en=>en_r,
    d=>mux_ry_out,
    q=>reg_y_out
    );
    
-- The r Z mutiplexer
mux_rz_out<=add_sub_z_out(23 downto 0) when (sel_mux='0') else data_in;

-- The remainder register
regz: reg 
    generic map(N=>24)
    port map(
    clk=>clk,
    rst=>rst,
    clr=>'0',
    en=>en_r,
    d=>mux_rz_out,
    q=>reg_z_out
    );

rom0: rom port map(
    clk=>clk,
    addr=>addr,
    data=>rom_out
);

barrelshifterx: barrel_shifter port map (
    data_in  => reg_x_out,
    shift    => n_shift,
    data_out => shift_x_out
);
   
barrelshiftery: barrel_shifter port map (
    data_in  => reg_y_out,
    shift    => n_shift,
    data_out => shift_y_out
);
    
add_subx: add_sub port map (
    data_in => reg_x_out,
    shifter => shift_y_out,
    signo => reg_z_out(23),
    data_out => add_sub_x_out
);

bit_signo<=reg_z_out(23);
not_bit_signo<=not(bit_signo);


add_suby: add_sub port map (
    data_in => reg_y_out,
    shifter => shift_x_out,
    signo => not_bit_signo,
    data_out => add_sub_y_out
);
 
add_subz: add_sub port map (
    data_in => data_in,
    shifter => rom_out,
    signo => reg_z_out(23),
    data_out => add_sub_z_out
);

end rtl;
