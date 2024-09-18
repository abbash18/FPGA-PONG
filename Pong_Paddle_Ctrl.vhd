--Module controls paddle movement, incrementing paddle position on y-axis depending on button press
--Designed for 640 x 480 with 25 MHz clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Pong_Pkg.all;

entity Pong_Paddle_Ctrl is
    generic (
        g_Player_Paddle_X: integer -- specifies X-Position of paddle for player 1 or 2
    );
    port (
        i_Clk : in std_logic;
        
        --represent current column and row drawn on screen (divided by 16 due to reduced resolution)
        i_Col_Count_Div : in std_logic_vector(5 downto 0);
        i_Row_Count_Div : in std_logic_vector(5 downto 0);

        --input paddle control 
        i_Paddle_Up : in std_logic;
        i_Paddle_Dn : in std_logic;

        o_Draw_Paddle : out std_logic;
        o_Paddle_Y : out std_logic_vector(5 downto 0);

    );
end entity;

architecture rtl of Pong_Paddle_Ctrl is

    --integer representation of down to counters (easier to deal with conceptually)
    signal w_Col_Index : integer range 0 to 2**i_Col_Count_Div'length := 0;
    signal w_Row_Index : integer range 0 to 2**i_Row_Count_Div'length := 0;

    signal w_paddle_move_en : std_logic;--enables paddle movement when button pressed
    
    signal paddle_speed_counter : integer range 0 to c_Paddle_Speed := 0;
    --y position of paddle, goes up to max height of screen
    signal r_Paddle_Y : integer range 0 to c_Game_Height - c_Paddle_Height - 1 := 0;

    signal r_Draw_Paddle : std_logic := '0'; 

begin

    w_Col_Index <= to_integer(unsigned(i_Col_Count_Div));
    w_Row_Index <= to_integer(unsigned(i_Row_Count_Div));  

    --using xor to turn on ONLY when down or up movement is detected (button pressed)
    w_paddle_move_en <= i_Paddle_Up xor i_Paddle_Dn;

    p_Move_Paddles : process (i_Clk) is
    begin
        if rising_edge(i_Clk) then
            --only moves after it reaches the required number of cycles, slowing down paddle movement
            --makes sure the game is manageable
            if w_paddle_move_en = '1' then --check for button press
                if paddle_speed_counter = c_Paddle_Speed then --only moves after it reaches the required number of cycles, slowing down paddle movement
                    paddle_speed_counter <= 0;
                else
                    paddle_speed_counter <= paddle_speed_counter+1;
                end if;
            else
                paddle_speed_counter <= 0;
            end if;
            
            --paddle movement
            if (i_Paddle_Up = '1' and paddle_speed_counter = c_Paddle_Speed) then --up button press
                if r_Paddle_Y /= 0 then--makes sure paddle isn't at the top of the screen, doesn't move if it is
                  r_Paddle_Y <= r_Paddle_Y - 1; --moves it up one index
                end if;

            elsif (i_Paddle_Dn = '1' and paddle_speed_counter = c_Paddle_Speed) then --if down button pressed
                if r_Paddle_Y /= c_Game_Height-c_Paddle_Height-1 then --ensures paddle is not at the bottom of the screen
                  r_Paddle_Y <= r_Paddle_Y + 1; 
                end if; 
              end if;
            end if;
          end process p_Move_Paddles;

        --process for moving paddles onto the board
    p_Draw_Paddles : process (i_Clk) is
    begin
        if rising_edge(i_Clk) then
            if (i_Col_Count_Div = g_Player_Paddle_X and i_Row_Count_Div >= r_Paddle_Y and i_Row_Count_Div <=r_Paddle_Y + c_Paddle_Height) then
                r_Draw_Paddle <='1';
            else
                r_Draw_Paddle <='0';
            end if;
        end if;
    end process;

    o_Draw_Paddle <= r_Draw_Paddle; --tells high level module whether to draw pixel or not
    o_Paddle_Y <= std_logic_vector(to_unsigned(r_Paddle_Y, o_Paddle_Y'length)); --provides Y position of paddle as a std_logic_vector for compatibility

end architecture;
