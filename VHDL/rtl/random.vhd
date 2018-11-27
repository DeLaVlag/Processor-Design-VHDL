-- MS: got this random generator from : http://vhdlguru.blogspot.nl/2013/08/generating-random-numbers-in-vhdl.html


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;
use work.mlite_pack.all;

entity rand_gen is
    port(
        clk       : in std_logic;
        reset_in  : in std_logic;
        rand_num  : out integer
    );
end rand_gen;

architecture behavior of rand_gen is 
begin

	process(clk, reset_in)

	    variable seed1, seed2: positive;      		-- seed values for random generator
	    variable rand: real;   						-- random real-number value in range 0 to 1.0  
	    variable range_of_rand : real := 10000.0;   -- the range of random values created will be 0 to +1000.
	
	begin

		if reset_in = '1' then
			rand_num <= 0;
	    elsif rising_edge(clk) then
	    	uniform(seed1, seed2, rand);   				-- generate random number
	    	rand_num <= integer(rand*range_of_rand);  	-- rescale to 0..1000, convert integer part 
	    end if;
	
	end process;

end behavior;