 -- ROM Inference on array

-- File: roms_1.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rom is
    port(
    clk  : in  std_logic;
    addr : in  std_logic_vector(4 downto 0);
    data : out std_logic_vector(23 downto 0)
    );
end rom;

architecture rtl of rom is

type rom_type is array (0 to 23) of std_logic_vector(23 downto 0);

signal ROM : rom_type := (X"001FFF", X"0012E3", X"0009FB", X"000511", X"00028B", X"000145", X"0000A2", X"000051", X"000028", 
X"000014", X"00000A", X"000005", X"000002", X"000001", X"000000", X"000000", X"000001", X"000000", X"000000", X"000000", 
X"000055", X"000000", X"000000", X"000000");

attribute rom_style : string;
attribute rom_style of ROM : signal is "block";

begin

    process(clk)
    begin
        if rising_edge(clk) then
        data <= ROM(conv_integer(addr));
        end if;
    end process;

end rtl; 
