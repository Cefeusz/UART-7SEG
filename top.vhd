library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_uart_7seg is
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        UART_RX      : in  std_logic;
        UART_TX      : out std_logic;
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
        rx_ready_led : out std_logic;               -- Dioda pokazuj?ca flg? gotowo?ci
        rx_data_led  : out std_logic_vector(7 downto 0) -- Diody pokazuj?ce odebrany bajt
    );
end entity;

architecture Behavioral of top_uart_7seg is

    -- Sygna?y ??cz?ce modu? UART z reszt?
    signal rx_data  : std_logic_vector(7 downto 0);
    signal rx_ready : std_logic;

begin

    ----------------------------------------------------------------------------
    -- Instancja modu?u UART
    ----------------------------------------------------------------------------
    uart_inst : entity work.uart
        port map (
            clk      => clk,
            reset    => reset,
            UART_RX  => UART_RX,
            UART_TX  => UART_TX,
            rx_data  => rx_data,
            rx_ready => rx_ready
        );

    ----------------------------------------------------------------------------
    -- Instancja wy?wietlacza 7-segmentowego
    ----------------------------------------------------------------------------
    seven_seg_inst : entity work.seven_seg_display
        port map (
            clk          => clk,
            reset        => reset,
            Segment_A    => Segment_A,
            Segment_B    => Segment_B,
            Segment_C    => Segment_C,
            Segment_D    => Segment_D,
            Segment_E    => Segment_E,
            Segment_F    => Segment_F,
            Segment_G    => Segment_G,
            Segment_D1   => Segment_D1,
            Segment_D2   => Segment_D2,
            Segment_D3   => Segment_D3,
            Segment_D4   => Segment_D4,
            rx_data      => rx_data
        );

    ----------------------------------------------------------------------------
    -- Debugowanie sygna?ów na diodach LED (opcjonalne)
    ----------------------------------------------------------------------------
    -- Tu ju? NIE kasujemy rx_ready w ?adnym procesie.
    -- Sygna? rx_ready jest tylko impulsem 1-taktowym z modu?u UART.
    ----------------------------------------------------------------------------
    rx_ready_led <= rx_ready;
    rx_data_led  <= rx_data;

end architecture;