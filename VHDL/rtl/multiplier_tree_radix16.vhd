--====================================================================================================================--
--  Title:        Multiplier tree radix 16
--  File Name:    multiplier_tree_radix16.vhd
--  Author:       MS
--  Date:         11-06-17
--
--  Description:  This is a part of a design of a faster multiplier. More specific, it describes
--					the tree part of a radix 16 multiplier. It is only a combinatorical design.
--====================================================================================================================--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mlite_pack.all;

entity multiplier_tree_radix16 is
	generic ( INPUT_SMALLEST_SIZE : POSITIVE := 32 ); 
    port(
            ia     : in  std_logic_vector(INPUT_SMALLEST_SIZE-1 downto 0);
            i2a	   : in  std_logic_vector(INPUT_SMALLEST_SIZE   downto 0);
			i4a	   : in  std_logic_vector(INPUT_SMALLEST_SIZE+1 downto 0);
			i8a	   : in  std_logic_vector(INPUT_SMALLEST_SIZE+2 downto 0);
			ioldsum: in  std_logic_vector(INPUT_SMALLEST_SIZE+2 downto 0);
			ioldcar: in  std_logic_vector(INPUT_SMALLEST_SIZE+2 downto 0);
			osumm  : out std_logic_vector(INPUT_SMALLEST_SIZE+5 downto 0);
			ocar   : out std_logic_vector(INPUT_SMALLEST_SIZE+5 downto 0)
    );
end entity multiplier_tree_radix16;


Architecture logic Of multiplier_tree_radix16 Is

    signal a : 					std_logic_vector(INPUT_SMALLEST_SIZE+2 downto 0) := (others=> '0');
    signal a2: 					std_logic_vector(INPUT_SMALLEST_SIZE+2 downto 0) := (others=> '0');
    signal a4: 					std_logic_vector(INPUT_SMALLEST_SIZE+2 downto 0) := (others=> '0');
    signal a8: 					std_logic_vector(INPUT_SMALLEST_SIZE+2 downto 0) := (others=> '0');
	signal output_csa_sum_1: 	std_logic_vector(INPUT_SMALLEST_SIZE+3 downto 0) := (others=> '0');
	signal output_csa_car_1: 	std_logic_vector(INPUT_SMALLEST_SIZE+3 downto 0) := (others=> '0');
	signal output_csa_sum_2: 	std_logic_vector(INPUT_SMALLEST_SIZE+3 downto 0) := (others=> '0');
	signal output_csa_car_2: 	std_logic_vector(INPUT_SMALLEST_SIZE+3 downto 0) := (others=> '0');
	signal output_csa_sum_3: 	std_logic_vector(INPUT_SMALLEST_SIZE+4 downto 0) := (others=> '0');
	signal output_csa_car_3: 	std_logic_vector(INPUT_SMALLEST_SIZE+4 downto 0) := (others=> '0');
    signal sum1_to_csa3    :    std_logic_vector(INPUT_SMALLEST_SIZE+4 downto 0) := (others=> '0');

	component csa_adder Port (
        ia, ib, ic   : in  std_logic_vector;
        osum, ocarry : out std_logic_vector
    );
    end component;

begin

 ----------------------------------------------------------------------------------------------
 -- Combinatorics
 ----------------------------------------------------------------------------------------------
 -- MS: assign port to signals because direct use in port map is not permitted
 a 	          <= "000" & ia;
 a2	          <= "00"  & i2a;
 a4	          <= "0"   & i4a;
 a8	          <= i8a;
 sum1_to_csa3 <= "0"   & output_csa_sum_1;   -- MS: please notice

----------------------------------------------------------------------------------------------
-- Instantiations
----------------------------------------------------------------------------------------------  
lbl_csa_1 : csa_adder 
port map(
    ia      => a,
    ib      => a2,
    ic      => a4,
    osum    => output_csa_sum_1,
    ocarry  => output_csa_car_1
);


lbl_csa_2 : csa_adder 
port map(
    ia      => i8a,
    ib      => ioldsum,
    ic      => ioldcar,
    osum    => output_csa_sum_2,
    ocarry  => output_csa_car_2
);

lbl_csa_3 : csa_adder 
port map(
    ia      => output_csa_car_1,
    ib      => output_csa_sum_2,
    ic      => output_csa_car_2,
    osum    => output_csa_sum_3,
    ocarry  => output_csa_car_3
);

lbl_csa_4 : csa_adder 
port map(
    ia      => output_csa_sum_3,
    ib      => output_csa_car_3,
    ic      => sum1_to_csa3, --sum1_to_csa3,  -- MS: please notice
    osum    => osumm,
    ocarry  => ocar
);

end architecture logic;
