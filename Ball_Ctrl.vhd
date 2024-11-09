--module for 640X480 display with a 25MHz clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Pong_Pkg.all;

entity Ball_Ctrl is
    port (
        i_Clk   : in std_logic;
        i_Game_state : in std_logic; -- indicate whether ball is in movement
        i_col_Counter_Div : in std_logic_vector(5 downto 0); --represents coloumn being draw on screen
        i_row_Counter_Div : in std_logic_vector(5 downto 0); --row being drawn on screen
        
        o_Ball_Draw : out std_logic; -- indicates if ball is drawn at given pixel
        o_Ball_X_Pos : out std_logic_vector(5 downto 0); --represents balls x position
        o_Ball_Y_Pos : out std_logic_vector(5 downto 0) --represents balls y position
        
    );
end entity;

architecture rtl of Ball_Ctrl is
    --integer representation of row and col index
    signal w_Col : integer range 0 to 2**i_Col_Count_Div'length := 0;
    signal w_Row : integer range 0 to 2**i_Row_Count_Div'length := 0;
    
    --ball position, used to track movement
    signal r_Ball_X : integer range 0 to 2**i_Col_Count_Div'length := 0;
    signal r_Ball_X_prev : integer range 0 to 2**i_Col_Count_Div'length := 0;
    signal r_Ball_Y : integer range 0 to 2**i_Row_Count_Div'length := 0;
    signal r_Ball_Y_prev : integer range 0 to 2**i_Row_Count_Div'length := 0;

    signal r_Ball_Draw : std_logic := '0'; -- signal to identify if ball should be drawn on screen

    signal r_Ball_Count : integer range 0 to c_Ball_Speed := 0; -- movement counter for speed control
begin
    --converting input counters to integers to make for easier processing
    w_Col <= to_integer(unsigned(i_col_Counter_Div));
    w_Row <= to_integer(unsigned(i_row_Counter_Div));

    p_Move_Ball : process(i_Clk) is
    begin
        if rising_edge(i_Clk) then
            --keeping ball in center if game inactive
            if i_Game_state = '0' then
                r_Ball_X <= c_Game_Width/2;
                r_Ball_Y <= c_Game_Height/2;
                r_Ball_X_prev <= c_Game_Width/2 + 1;
                r_Ball_Y_prev <= c_Game_Height/2 - 1;
                r_Ball_Count <=0; 
            else -- active game
                if r_Ball_Count = c_Ball_Speed then
                    r_Ball_Count <= 0;
                else 
                    r_Ball_Count <= r_Ball_Count + 1;
                end if;

                if r_Ball_Count = c_Ball_Speed then --once ball reaches the speed threshold
                    --store previous positions for direction tracking
                    r_Ball_X_prev <= r_Ball_X;
                    r_Ball_Y_prev <= r_Ball_Y;

                    --X-Position Movement (Cols)
                    if r_Ball_X_prev < r_Ball_X then -- moving right (previous position less than current)
                        if r_Ball_X = c_Game_Width - 1 then -- ball hit right paddle, move left
                            r_Ball_X <= r_Ball_X - 1;
                        else
                            r_Ball_X <= r_Ball_X + 1;
                        end if;
                    elsif r_Ball_X_prev > r_Ball_X then -- ball hit left paddle, move right
                        if r_Ball_X = 0 then
                            r_Ball_X <= r_Ball_X + 1;
                        else
                            r_Ball_X <= r_Ball_X -1;
                        end if;
                    end if;

                    --Y-Position Movement (Rows)
                    if r_Ball_Y_Prev < r_Ball_Y then --ball moving down 
                        if r_Ball_Y = c_Game_Height -1 then -- ball hit bottom, needs to bounce up
                            r_Ball_Y <= r_Ball_Y - 1;
                        else 
                            r_Ball_Y <= r_Ball_Y + 1; --continue moving downards
                        end if;
                    elsif r_Ball_Y_prev > r_Ball_Y then--ball moving upwards
                        if r_Ball_Y = 0 then --ball hit the top of the screen
                            r_Ball_Y <= r_Ball_Y + 1;
                        else 
                            r_Ball_Y <= r_Ball_Y -1; --continue to move up otherwise
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process p_Move_Ball;

    p_Draw_Ball : process(i_Clk) is
    begin
        --check to ensure current pixel is where we want to draw
        if rising_edge(i_Clk) then
            if (w_Col = r_Ball_X and w_Row = r_Ball_Y) then
                r_Ball_Draw <= '1';
            else
                r_Ball_Draw <= '0';
            end if;
        end if;
    end process;

    o_Ball_Draw <= r_Ball_Draw;
    o_Ball_X_Pos <= std_logic_vector(to_unsigned(r_Ball_X, o_Ball_X_Pos'length));
    o_Ball_Y_Pos <= std_logic_vector(to_unsigned(r_Ball_Y, o_Ball_Y_Pos'length));

end architecture;
