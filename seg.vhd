library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_seg_display is
    port (
        clk          : in  std_logic; 
        reset        : in  std_logic; 
        Segment_A    : out std_logic;
        Segment_B    : out std_logic;
        Segment_C    : out std_logic;
        Segment_D    : out std_logic;
        Segment_E    : out std_logic;
        Segment_F    : out std_logic;
        Segment_G    : out std_logic;
        Segment_D1   : out std_logic;
        Segment_D2   : out std_logic;
        Segment_D3   : out std_logic;
        Segment_D4   : out std_logic;
        rx_data      : in  std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of seven_seg_display is

    type segment_array is array (0 to 9) of std_logic_vector(6 downto 0);
    constant SEG_PATTERNS : segment_array := (
        "1000000", -- 0
        "1111001", -- 1
        "0100100", -- 2
        "0110000", -- 3
        "0011001", -- 4
        "0010010", -- 5
        "0000010", -- 6
        "1111000", -- 7
        "0000000", -- 8
        "0010000"  -- 9
    );

    signal current_digit : integer range 0 to 3 := 0;
    signal clk_div       : std_logic;                
    signal segments      : std_logic_vector(6 downto 0); 
    signal active_digit  : std_logic_vector(3 downto 0); 
    signal digit_0       : integer range 0 to 9 := 0; 
    signal digit_1       : integer range 0 to 9 := 0;
    signal digit_2       : integer range 0 to 9 := 0;
    signal digit_3       : integer range 0 to 9 := 0;

begin

    ----------------------------------------------------------------------------
    -- Konwersja danych ASCII na cyfr? 0-9 (tylko ostatni znak wy?wietlany)
    ----------------------------------------------------------------------------
    process (rx_data)
    begin
        if unsigned(rx_data) >= 48 and unsigned(rx_data) <= 57 then
            digit_0 <= to_integer(unsigned(rx_data)) - 48; 
        else
            digit_0 <= 0;  -- Je?li poza '0'..'9', to wy?wietla 0
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Podzia? zegara do multipleksowania (przyk?ad: /50_000 = ok. 2 kHz przy 100 MHz)
    ----------------------------------------------------------------------------
    process (clk, reset)
        variable clk_counter : integer := 0;
    begin
        if reset = '1' then
            clk_div <= '0';
            clk_counter := 0;
        elsif rising_edge(clk) then
            if clk_counter = 50000 then
                clk_div <= not clk_div;
                clk_counter := 0;
            else
                clk_counter := clk_counter + 1;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Prze??czanie aktualnie zapalanej cyfry (4-cyfrowy wy?wietlacz multipleksowany)
    ----------------------------------------------------------------------------
    process (clk_div, reset)
    begin
        if reset = '1' then
            current_digit <= 0;
        elsif rising_edge(clk_div) then
            current_digit <= (current_digit + 1) mod 4;
        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Dobór segmentów dla aktualnie wybranego wy?wietlacza
    ----------------------------------------------------------------------------
    process (current_digit, digit_0, digit_1, digit_2, digit_3)
    begin
        segments     <= "1111111";  -- Domy?lnie wygaszone
        active_digit <= "1111";     -- Wszystkie wy??czone

        case current_digit is
            when 0 =>
                active_digit <= "1110"; 
                segments     <= SEG_PATTERNS(digit_0); 
            when 1 =>
                active_digit <= "1101"; 
                segments     <= SEG_PATTERNS(digit_1); 
            when 2 =>
                active_digit <= "1011"; 
                segments     <= SEG_PATTERNS(digit_2); 
            when 3 =>
                active_digit <= "0111"; 
                segments     <= SEG_PATTERNS(digit_3); 
            when others =>
                active_digit <= "1111"; 
                segments     <= "1111111"; 
        end case;
    end process;

    ----------------------------------------------------------------------------
    -- Przypisanie wyj?? do fizycznych segmentów
    ----------------------------------------------------------------------------
    Segment_A <= segments(0);
    Segment_B <= segments(1);
    Segment_C <= segments(2);
    Segment_D <= segments(3);
    Segment_E <= segments(4);
    Segment_F <= segments(5);
    Segment_G <= segments(6);

    Segment_D1 <= active_digit(0);
    Segment_D2 <= active_digit(1);
    Segment_D3 <= active_digit(2);
    Segment_D4 <= active_digit(3);

end architecture;
