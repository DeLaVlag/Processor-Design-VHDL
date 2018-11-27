-- MS : a carry save adder

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

library work;
--use work.mlite_pack.all;

entity csa_adder is
    port (
        ia, ib, ic   : in  std_logic_vector; 
        osum, ocarry : out std_logic_vector
    );
end; --entity adder

Architecture logic Of csa_adder Is
    constant filler : std_logic := '0';
    signal sum, car : std_logic_vector(ia'range);
Begin

    forlab : for index in 0 to ia'length-1 generate
        sum(index)      <= ia(index) XOR ib(index) XOR ic(index);
        car(index)      <= (ic(index) AND (ia(index) OR  ib(index))) OR
                                          (ia(index) AND ib(index));     
    end generate;
    ocarry <= car(ia'range) & filler; -- MS: last bit always zero
    osum   <= filler & sum;                       -- MS: make same length for convenience
End; --architecture logic