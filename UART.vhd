library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    port (
        clk      : in  std_logic;  -- Zegar systemowy
        reset    : in  std_logic;  -- Reset
        UART_RX  : in  std_logic;  -- Wej?cie odbiornika UART
        UART_TX  : out std_logic;  -- Wyj?cie nadajnika UART (niewykorzystany w tym przyk?adzie?)
        rx_data  : out std_logic_vector(7 downto 0); -- Odebrane dane UART
        rx_ready : out std_logic                  -- Flaga: dane gotowe (impuls)
    );
end entity;

architecture Behavioral of uart is

    ----------------------------------------------------------------------------
    -- Parametry UART
    ----------------------------------------------------------------------------
    constant BAUD_RATE    : integer := 9600;
    constant CLK_FREQ     : integer := 100_000_000; -- 100 MHz
    constant CLKS_PER_BIT : integer := CLK_FREQ / BAUD_RATE;

    ----------------------------------------------------------------------------
    -- Sygna?y odbiornika UART
    ----------------------------------------------------------------------------
    signal rx_clk_count     : integer range 0 to CLKS_PER_BIT := 0;
    signal rx_bit_index     : integer range 0 to 7 := 0;
    signal rx_shift_reg     : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_state         : std_logic := '0'; 
    signal rx_data_internal : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_ready_internal: std_logic := '0';

begin
    ----------------------------------------------------------------------------
    -- Proces odbiornika UART
    ----------------------------------------------------------------------------
    process (clk, reset)
    begin
        if reset = '1' then
            rx_ready_internal <= '0';
            rx_clk_count      <= 0;
            rx_bit_index      <= 0;
            rx_shift_reg      <= (others => '0');
            rx_data_internal  <= (others => '0');
            rx_state          <= '0';

        elsif rising_edge(clk) then

            case rx_state is

                when '0' => 
                    -- Oczekiwanie na bit startu (linia RX = 0)
                    if UART_RX = '0' then
                        rx_state     <= '1';
                        -- Ustawienie licznika tak, by próbka nast?pi?a w po?owie bitu startu
                        rx_clk_count <= CLKS_PER_BIT / 2;  
                    end if;

                when '1' =>
                    -- Odbiór danych (8 bitów)
                    if rx_clk_count = CLKS_PER_BIT then
                        rx_clk_count <= 0;

                        -- Odczyt kolejnego bitu
                        rx_shift_reg(rx_bit_index) <= UART_RX;

                        if rx_bit_index = 7 then
                            -- Odebrano pe?ny bajt
                            rx_state          <= '0';
                            rx_data_internal  <= rx_shift_reg;
                            rx_ready_internal <= '1';   -- Wygeneruj impuls gotowo?ci
                        else
                            rx_bit_index <= rx_bit_index + 1;
                        end if;
                    else
                        rx_clk_count <= rx_clk_count + 1;
                    end if;

                when others =>
                    rx_state <= '0';

            end case;

            -- Krótki (1-taktowy) impuls rx_ready
            if rx_ready_internal = '1' then
                rx_ready_internal <= '0';
            end if;

        end if;
    end process;

    ----------------------------------------------------------------------------
    -- Wyj?cia modu?u
    ----------------------------------------------------------------------------
    rx_data  <= rx_data_internal;
    rx_ready <= rx_ready_internal;

    -- Nadajnik UART (UART_TX) mo?na zaimplementowa? wg potrzeb 
    UART_TX <= '1';  -- Tu np. ustawiony w stan spoczynku (idle = '1')

end architecture;
