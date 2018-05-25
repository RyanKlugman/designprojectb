library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bram is
    port (
        clk      : in std_logic;
        write_en : in std_logic;
        addr     : in std_logic_vector(31 downto 0);
        data_in  : in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );
end bram;

architecture Behavioral of bram is

    type ram_t is array (0 to 6143) of std_logic_vector(31 downto 0); -- 2048 * 3
    -- load bram with some good test values (including edge cases)
    -- test values in dec:
    -- 24.2, 53.7, 101.2, 4.444, 90.7, 657.1, 0.0, -33.2, -1000.2, -600.2
    -- expected output in dec:
    -- 132, 140, 148, 128, 148, 255, 128, 120, 0, 8
    -- expected output in hex:
    -- 84, 8c, 94, 80, 94, ff, 80, 78, 0, 8
    signal ram : ram_t := (X"41c1999a", X"4256cccd", X"42ca6666", X"408e353f", X"42b56666",
        X"44244666", X"00000000", X"c204cccd", X"c47a0ccd", X"c4160ccd", others => (others => '0'));
    attribute ram_style: string;
    attribute ram_style of ram : signal is "block";

begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if write_en = '1' then
                ram(to_integer(unsigned(addr))) <= data_in;
            end if;
            data_out <= ram(to_integer(unsigned(addr)));
        end if;
    end process;

end Behavioral;