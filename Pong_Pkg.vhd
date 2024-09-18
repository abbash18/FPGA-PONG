library ieee;
use ieee.std_logic_1164.all;

package Pong_Pkg is

    --||Constants||

    -- width and height of gameboard
    constant c_Game_Width : integer := 40;
    constant c_Game_Height : integer := 30;

    -- Max Score Limit
    constant c_Score_Limit : integer := 9;

    -- paddle height
    constant c_Paddle_Height : integer := 6;

    -- paddle movement speed
    constant c_Paddle_Speed : integer := 1250000;

    -- ball speed
    constant c_Ball_Speed : integer := 1250000;

    -- Column index for player 1 and 2 paddles
    constant c_Paddle_Col_Location_P1 : integer := 0;
    constant c_Paddle_Col_Location_P2 : integer := c_Game_Width - 1;

    component Pong_Paddle_Ctrl is
        generic (
            g_Player_Paddle_x : integer
        );
        port (
            i_Clk : in std_logic;
        
            -- represent current column and row drawn on screen (divided by 16 due to reduced resolution)
            i_Col_Count_Div : in std_logic_vector(5 downto 0);
            i_Row_Count_Div : in std_logic_vector(5 downto 0);

            -- input paddle control 
            i_Paddle_Up : in std_logic;
            i_Paddle_Dn : in std_logic;

            o_Draw_Paddle : out std_logic;
            o_Paddle_Y : out std_logic_vector(5 downto 0);
        );
    end component Pong_Paddle_Ctrl;

    component Ball_Ctrl is
        port (
            i_Clk   : in std_logic;
            i_Game_state : in std_logic;
            i_col_Counter_Div : in std_logic_vector(5 downto 0);
            i_row_Counter_Div : in std_logic_vector(5 downto 0);
            
            o_Ball_Draw : out std_logic;
            o_Ball_X_Pos : out std_logic_vector(5 downto 0);
            o_Ball_Y_Pos : out std_logic_vector(5 downto 0);
        );
    end component Ball_Ctrl;

end package Pong_Pkg;
