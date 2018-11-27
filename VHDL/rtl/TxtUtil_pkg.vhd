--====================================================================================================================--
--
--  Title:        Text utilities package
--  file Name:    TxtUtil_pkg.vhd
--  Author:       Olaf van den Berg
--  Date:         Tuesday, February 18, 2014
--
--  Description:  Package with functions related to string/text operations
--
--====================================================================================================================--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package TxtUtil_pkg is

   -- Output to screen
   procedure echo(iText : string);
   procedure echo(iCondition : boolean; iTextIfTrue : string);
   procedure echo(iCondition : boolean; iTextIfTrue : string; iTextIfFalse : string);

   -- Output to screen and file
   procedure echo(iFile : string; iText : string);
   procedure echo(iFile : string; iCondition : boolean; iTextIfTrue : string);
   procedure echo(iFile : string; iCondition : boolean; iTextIfTrue : string; iTextIfFalse : string);

   -- Conversion functions
   pure function Chr(iSl   : std_logic)            return character;
   pure function Chr(iInt  : integer)              return character;

   pure function Str(iSl   : std_logic)            return string;
   pure function Str(iSlv  : std_logic_vector)     return string;
   pure function Str(iBool : boolean)              return string;

   pure function Sl(iChar  : character)            return std_logic;
   pure function Sl(iStr   : string)               return std_logic;

   pure function Slv(iStr  : string)               return std_logic_vector;

   pure function SlvHex(iStr  : string)            return std_logic_vector;
   pure function Hex(iSlv     : std_logic_vector)  return string;

   -- String checking/editing
   pure function Chr2Upper(iChr     : character)   return character;
   pure function Chr2Lower(iChr     : character)   return character;
   pure function Str2Upper(iStr     : string)      return string;
   pure function Str2Lower(iStr     : string)      return string;
   pure function IsSpace(iChr       : character)   return boolean;
   pure function TrimLeading(iStr   : string)      return string;
   pure function IsComment(iStr     : string)      return boolean;
   pure function TrimComment(iStr   : string)      return string;

end package TxtUtil_pkg;

package body TxtUtil_pkg is

   --=================================================================================================================--
   -- Output a string to the stdout buffer (simulation console)
   --=================================================================================================================--
   procedure echo(iText : string) is
      variable vLine : line;
   begin
      write(vLine, (">: " & iText));
      writeline(output, vLine);
   end procedure echo;

   --=================================================================================================================--
   -- Output a string to the stdout buffer when condition is true
   --=================================================================================================================--
   procedure echo(iCondition : boolean; iTextIfTrue : string) is
   begin
      if (iCondition) then
         echo(iTextIfTrue);
      end if;
   end procedure echo;

   --=================================================================================================================--
   -- Output a string to the stdout buffer when condition is true, else output another string
   --=================================================================================================================--
   procedure echo(iCondition : boolean; iTextIfTrue : string; iTextIfFalse : string) is
   begin
      if (iCondition) then
         echo(iTextIfTrue);
      else
         echo(iTextIfFalse);
      end if;
   end procedure echo;

   --=================================================================================================================--
   -- Output a string to the stdout buffer (simulation console) and to a specified file
   --=================================================================================================================--
   procedure echo(iFile : string; iText : string) is
      file     vFile        : text;
      variable vLine        : line;
      variable vFileStatus  : file_open_status;
   begin
      file_open(vFileStatus,vFile,iFile,APPEND_MODE);
      if (vFileStatus = OPEN_OK) then
         write(vLine, (">: " & iText));
         writeline(output, vLine);
         write(vLine, (">: " & iText));
         writeline(vFile, vLine);
         file_close(vFile);
      else
         write(vLine, ("FAILED TO WRITE TO file " & iFile));
         writeline(output, vLine);
      end if;
   end procedure echo;

   --=================================================================================================================--
   -- Output a string to the stdout buffer and file when condition is true
   --=================================================================================================================--
   procedure echo(iFile : string; iCondition : boolean; iTextIfTrue : string) is
   begin
      if (iCondition) then
         echo(iFile, iTextIfTrue);
      end if;
   end procedure echo;

   --=================================================================================================================--
   -- Output a string to the stdout buffer and file when condition is true, else output another string
   --=================================================================================================================--
   procedure echo(iFile : string; iCondition : boolean; iTextIfTrue : string; iTextIfFalse : string) is
   begin
      if (iCondition) then
         echo(iFile, iTextIfTrue);
      else
         echo(iFile, iTextIfFalse);
      end if;
   end procedure echo;

   --=================================================================================================================--
   -- Convert a std_logic signal to an ascii character
   --=================================================================================================================--
   pure function Chr(iSl   : std_logic) return character is
      variable vChar : character;
   begin
      case iSl is
         when 'U'  =>  vChar := 'U';
         when 'X'  =>  vChar := 'X';
         when '0'  =>  vChar := '0';
         when '1'  =>  vChar := '1';
         when 'Z'  =>  vChar := 'Z';
         when 'W'  =>  vChar := 'W';
         when 'L'  =>  vChar := 'L';
         when 'H'  =>  vChar := 'H';
         when '-'  =>  vChar := '-';
      end case;
      return vChar;
   end function Chr;

   --=================================================================================================================--
   -- Convert an integer value to an ascii character (only up to hexadecimal)
   --=================================================================================================================--
   pure function Chr(iInt  : integer) return character is
      variable vChar : character;
   begin
      case iInt is
         when  0     =>  vChar := '0';
         when  1     =>  vChar := '1';
         when  2     =>  vChar := '2';
         when  3     =>  vChar := '3';
         when  4     =>  vChar := '4';
         when  5     =>  vChar := '5';
         when  6     =>  vChar := '6';
         when  7     =>  vChar := '7';
         when  8     =>  vChar := '8';
         when  9     =>  vChar := '9';
         when 10     =>  vChar := 'A';
         when 11     =>  vChar := 'B';
         when 12     =>  vChar := 'C';
         when 13     =>  vChar := 'D';
         when 14     =>  vChar := 'E';
         when 15     =>  vChar := 'F';
         when others =>  vChar := '?';
      end case;
      return vChar;
   end function Chr;

   --=================================================================================================================--
   -- Convert a std_logic value into a single character string
   --=================================================================================================================--
   pure function Str(iSl   : std_logic) return string is
      variable vStr : string(1 downto 1);
   begin
      vStr(1) := Chr(iSl);
      return vStr;
   end function Str;

   --=================================================================================================================--
   -- Convert a std_logic_vector into a string representing std_logic bits
   --=================================================================================================================--
   pure function Str(iSlv : std_logic_vector) return string is
      variable vStr : string(iSlv'HIGH + 1 downto iSlv'LOW + 1) := (others => 'X');
   begin
      for I in iSlv'RANGE loop
         vStr(I+1) := Chr(iSlv(I));
      end loop;
      return vStr;
   end function Str;

   --=================================================================================================================--
   -- Convert a boolean into a string
   --=================================================================================================================--
   pure function Str(iBool : boolean) return string is
   begin
      if (iBool) then
         return "true";
      else
         return "false";
      end if;
   end function Str;

   --=================================================================================================================--
   -- Convert a character into a std_logic value
   --=================================================================================================================--
   pure function Sl(iChar : character) return std_logic is
      variable vSl : std_logic;
   begin
      case iChar is
         when 'U'    =>  vSl := 'U';
         when 'X'    =>  vSl := 'X';
         when '0'    =>  vSl := '0';
         when '1'    =>  vSl := '1';
         when 'Z'    =>  vSl := 'Z';
         when 'W'    =>  vSl := 'W';
         when 'L'    =>  vSl := 'L';
         when 'H'    =>  vSl := 'H';
         when '-'    =>  vSl := '-';
         when others =>  vSl := 'X';
      end case;
      return vSl;
   end function Sl;

   --=================================================================================================================--
   -- Convert a single character string into a std_logic value
   --=================================================================================================================--
   pure function Sl(iStr   : string) return std_logic is
   begin
      return Sl(iStr(iStr'LOW));
   end function Sl;

   --=================================================================================================================--
   -- Convert a string representing std_logic bits into a std_logic_vector
   --=================================================================================================================--
   pure function Slv(iStr : string) return std_logic_vector is
      variable vSlv : std_logic_vector(iStr'RANGE) := (others => 'X');
   begin
      for I in iStr'RANGE loop
         vSlv(I) := Sl(iStr(I));
      end loop;
      return vSlv;
   end function Slv;

   --=================================================================================================================--
   -- Convert a hexadecimal string to a std_logic_vector
   --=================================================================================================================--
   pure function SlvHex(iStr : string) return std_logic_vector is
      variable vSlv         : std_logic_vector(iStr'LENGTH * 4 - 1 downto 0);
      variable vSlvFourBit  : std_logic_vector(3 downto 0);
   begin
      for I in iStr'LENGTH downto 1 loop
         case iStr(I) is
            when '0'    => vSlvFourBit := "0000";
            when '1'    => vSlvFourBit := "0001";
            when '2'    => vSlvFourBit := "0010";
            when '3'    => vSlvFourBit := "0011";
            when '4'    => vSlvFourBit := "0100";
            when '5'    => vSlvFourBit := "0101";
            when '6'    => vSlvFourBit := "0110";
            when '7'    => vSlvFourBit := "0111";
            when '8'    => vSlvFourBit := "1000";
            when '9'    => vSlvFourBit := "1001";
            when 'a'    => vSlvFourBit := "1010";
            when 'A'    => vSlvFourBit := "1010";
            when 'b'    => vSlvFourBit := "1011";
            when 'B'    => vSlvFourBit := "1011";
            when 'c'    => vSlvFourBit := "1100";
            when 'C'    => vSlvFourBit := "1100";
            when 'd'    => vSlvFourBit := "1101";
            when 'D'    => vSlvFourBit := "1101";
            when 'e'    => vSlvFourBit := "1110";
            when 'E'    => vSlvFourBit := "1110";
            when 'f'    => vSlvFourBit := "1111";
            when 'F'    => vSlvFourBit := "1111";
            when 'u'    => vSlvFourBit := (others => 'U');
            when 'U'    => vSlvFourBit := (others => 'U');
            when 'x'    => vSlvFourBit := (others => 'X');
            when 'X'    => vSlvFourBit := (others => 'X');
            when 'z'    => vSlvFourBit := (others => 'Z');
            when 'Z'    => vSlvFourBit := (others => 'Z');
            when 'w'    => vSlvFourBit := (others => 'W');
            when 'W'    => vSlvFourBit := (others => 'W');
            when 'l'    => vSlvFourBit := (others => 'L');
            when 'L'    => vSlvFourBit := (others => 'L');
            when 'h'    => vSlvFourBit := (others => 'H');
            when 'H'    => vSlvFourBit := (others => 'H');
            when '-'    => vSlvFourBit := (others => '-');
            when others => vSlvFourBit := (others => 'X');
         end case;
         vSlv(I*4 - 1 downto I*4 - 4) := vSlvFourBit;
      end loop;
      return vSlv;
   end function SlvHex;

   --=================================================================================================================--
   -- Convert a descending std_logic_vector to a descending hexadecimal string
   --=================================================================================================================--
   pure function Hex(iSlv : std_logic_vector) return string is
      variable vHexLen      : integer;
      -- Add 3 to extend non-multiples of 4 bits by zero
      variable vLongSlv     : std_logic_vector(iSlv'LEFT + 3 downto 0) := (others => '0');
      variable vHexStr      : string(iSlv'LENGTH/4+1 downto 1);
      variable vSlvFourBit  : std_logic_vector(3 downto 0);
   begin
      vHexLen := (iSlv'LENGTH / 4);

      if ( ((iSlv'LENGTH) mod 4) /= 0) then
         vHexLen := vHexLen + 1;
      end if;

      vLongSlv(iSlv'LEFT downto 0) := iSlv;

      for I in (vHexLen - 1) downto 0 loop
         vSlvFourBit := vLongSlv( ((I*4)+3) downto (I*4) );
         case vSlvFourBit is
            when "0000" => vHexStr(I + 1) := '0';
            when "0001" => vHexStr(I + 1) := '1';
            when "0010" => vHexStr(I + 1) := '2';
            when "0011" => vHexStr(I + 1) := '3';
            when "0100" => vHexStr(I + 1) := '4';
            when "0101" => vHexStr(I + 1) := '5';
            when "0110" => vHexStr(I + 1) := '6';
            when "0111" => vHexStr(I + 1) := '7';
            when "1000" => vHexStr(I + 1) := '8';
            when "1001" => vHexStr(I + 1) := '9';
            when "1010" => vHexStr(I + 1) := 'A';
            when "1011" => vHexStr(I + 1) := 'B';
            when "1100" => vHexStr(I + 1) := 'C';
            when "1101" => vHexStr(I + 1) := 'D';
            when "1110" => vHexStr(I + 1) := 'E';
            when "1111" => vHexStr(I + 1) := 'F';
            when "ZZZZ" => vHexStr(I + 1) := 'z';
            when "UUUU" => vHexStr(I + 1) := 'u';
            when "XXXX" => vHexStr(I + 1) := 'x';
            when others => vHexStr(I + 1) := '?';
         end case;
      end loop;
      return vHexStr(vHexLen downto 1);
   end function Hex;

   --=================================================================================================================--
   -- Make a single character UPPER case
   --=================================================================================================================--
   pure function Chr2Upper(iChr     : character)   return character is
      variable vChar : character;
   begin
      case iChr is
         when 'a'    => vChar := 'A';
         when 'b'    => vChar := 'B';
         when 'c'    => vChar := 'C';
         when 'd'    => vChar := 'D';
         when 'e'    => vChar := 'E';
         when 'f'    => vChar := 'F';
         when 'g'    => vChar := 'G';
         when 'h'    => vChar := 'H';
         when 'i'    => vChar := 'I';
         when 'j'    => vChar := 'J';
         when 'k'    => vChar := 'K';
         when 'l'    => vChar := 'L';
         when 'm'    => vChar := 'M';
         when 'n'    => vChar := 'N';
         when 'o'    => vChar := 'O';
         when 'p'    => vChar := 'P';
         when 'q'    => vChar := 'Q';
         when 'r'    => vChar := 'R';
         when 's'    => vChar := 'S';
         when 't'    => vChar := 'T';
         when 'u'    => vChar := 'U';
         when 'v'    => vChar := 'V';
         when 'w'    => vChar := 'W';
         when 'x'    => vChar := 'X';
         when 'y'    => vChar := 'Y';
         when 'z'    => vChar := 'Z';
         when others => vChar := iChr;
      end case;
      return vChar;
   end function Chr2Upper;

   --=================================================================================================================--
   -- Make a single character lower case
   --=================================================================================================================--
   pure function Chr2Lower(iChr     : character)   return character is
      variable vChar : character;
   begin
      case iChr is
         when 'A'    => vChar := 'a';
         when 'B'    => vChar := 'b';
         when 'C'    => vChar := 'c';
         when 'D'    => vChar := 'd';
         when 'E'    => vChar := 'e';
         when 'F'    => vChar := 'f';
         when 'G'    => vChar := 'g';
         when 'H'    => vChar := 'h';
         when 'I'    => vChar := 'i';
         when 'J'    => vChar := 'j';
         when 'K'    => vChar := 'k';
         when 'L'    => vChar := 'l';
         when 'M'    => vChar := 'm';
         when 'N'    => vChar := 'n';
         when 'O'    => vChar := 'o';
         when 'P'    => vChar := 'p';
         when 'Q'    => vChar := 'q';
         when 'R'    => vChar := 'r';
         when 'S'    => vChar := 's';
         when 'T'    => vChar := 't';
         when 'U'    => vChar := 'u';
         when 'V'    => vChar := 'v';
         when 'W'    => vChar := 'w';
         when 'X'    => vChar := 'x';
         when 'Y'    => vChar := 'y';
         when 'Z'    => vChar := 'z';
         when others => vChar := iChr;
      end case;
      return vChar;
   end function Chr2Lower;

   --=================================================================================================================--
   -- Make an entire string UPPER case
   --=================================================================================================================--
   pure function Str2Upper(iStr     : string)      return string is
      variable vString : string(iStr'RANGE);
   begin
      for I in vString'RANGE loop
         vString(I) := Chr2Upper(iStr(I));
      end loop;
      return vString;
   end function Str2Upper;

   --=================================================================================================================--
   -- Make an entire string lower case
   --=================================================================================================================--
   pure function Str2Lower(iStr     : string)      return string is
      variable vString : string(iStr'RANGE);
   begin
      for I in vString'RANGE loop
         vString(I) := Chr2Lower(iStr(I));
      end loop;
      return vString;
   end function Str2Lower;

   --=================================================================================================================--
   -- Check whether the character is a space or not
   --=================================================================================================================--
   pure function IsSpace(iChr         : character)   return boolean is
   begin
      if (iChr = ' ' OR iChr = HT) then
         return true;
      else
         return false;
      end if;
   end function IsSpace;

   --=================================================================================================================--
   -- Trim the leading (leftmost) spaces of a string
   --=================================================================================================================--
   pure function TrimLeading(iStr   : string)      return string is
      variable vString  : string(iStr'RANGE);
      variable vFirst   : positive := 1;
   begin
      for I in vString'RANGE loop
         vString(I) := ' ';
      end loop;

      for I in iStr'RANGE loop
         if (NOT IsSpace(iStr(I))) then
            vFirst := I;
            exit;
         end if;
      end loop;

      if (iStr'ASCENDING) then
         for I in 1 to vString'LENGTH - (vFirst-1) loop
            vString(I) := iStr(vFirst + I - 1);
         end loop;
      else
         for I in vFirst downto 1 loop
            vString(I + (vString'LEFT - vFirst)) := iStr(I);
         end loop;
      end if;
      return vString;
   end function TrimLeading;

   --=================================================================================================================--
   -- Check if a string is starting with a # character indicating it's a comment
   --  # character can be preceded by spaces, which will be stripped
   --=================================================================================================================--
   pure function IsComment(iStr     : string)      return boolean is
      variable vString : string(iStr'RANGE);
   begin
      vString := TrimLeading(iStr);
      if (vString(vString'LEFT) = '#') then
         return true;
      else
         return false;
      end if;
   end function IsComment;

   --=================================================================================================================--
   -- Scan if there is a comment character ('#') somewhere in the string and trim (make space) everything
   --  that comes after
   --=================================================================================================================--
   pure function TrimComment(iStr   : string)      return string is
      variable vString : string(iStr'RANGE);
      variable vCmtIdx : integer := 0;
   begin
      for I in vString'RANGE loop
         vString(I) := ' ';
      end loop;

      for I in iStr'RANGE loop
         if (iStr(I) = '#') then
            vCmtIdx := I;
            exit;
         end if;
      end loop;

      if (vCmtIdx = 0) then
         return iStr;
      end if;

      if (iStr'ASCENDING) then
         for I in 1 to vCmtIdx-1 loop
            vString(I) := iStr(I);
         end loop;
      else
         for I in vString'LEFT downto vCmtIdx+1 loop
            vString(I) := iStr(I);
         end loop;
      end if;

      return vString;
   end function TrimComment;

end package body TxtUtil_pkg;
