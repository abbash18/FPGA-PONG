library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Pong_Pkg.all;

entity Pong_Draw is
    generic(
        g_Col_Tot : integer;
        g_Row_Tot : integer;
        g_Cols_Active : integer;
        g_Rows_Active : integer;
        g_Vid_Width : integer
    );
    port (
        --main clock
        i_Clk : in std_logic;

        --VGA inputs
        i_HSync : in std_logic;
        i_VSync : in std_logic;

        i_start : in std_logic; --start flag

        --paddle movement
        i_P1_Up : in std_logic;
        i_P1_Down: in std_logic;
        i_P2_Up : in std_logic;
        i_P2_Down: in std_logic;

        --output to VGA monitor
        o_HSync : out std_logic;
        o_VSync : out std_logic;
        o_Red_Video : out std_logic_vector(g_Vid_Width-1 downto 0);
        o_Blu_Video : out std_logic_vector(g_Vid_Width-1 downto 0);
        o_Grn_Video : out std_logic_vector(g_Vid_Width-1 downto 0)
    );
end entity;

architecture rtl of Pong_Draw is
    type t_Game_States is (s_idle, s_active, s_P1_Win, s_P2_Win, s_Cleanup);

    signal r_State : t_Game_States := s_idle;

    --Sync signals for VGA display
    signal w_HSync : std_logic;
    signal w_VSync : std_logic;

    --counters for row and column
    signal w_Col_Count : std_logic_vector(9 downto 0);
    signal w_Row_Count : std_logic_vector(9 downto 0);

    --divided counters for 40x30 downscaling
    signal w_Col_Count_Div : std_logic_vector(5 downto 0);
    signal w_Row_Count_Div : std_logic_vector(5 downto 0);

    signal w_draw_P1 : std_logic;
    signal w_draw_P2 : std_logic;
    signal w_draw_ball : std_logic;
    signal w_draw_All : std_logic;

    signal w_ball_x : std_logic_vector(5 downto 0);
    signal w_ball_y : std_logic_vector(5 downto 0);
    signal w_P1_Y: std_logic_vector(5 downto 0);
    signal w_P2_Y : std_logic_vector (5 downto 0);

    signal w_Active : std_logic;

    signal w_P1_Paddle_Top : unsigned(5 downto 0);
    signal w_P1_Paddle_Bottom : unsigned(5 downto 0);
    signal w_P2_Paddle_Top : unsigned(5 downto 0);
    signal w_P2_Paddle_Bottom : unsigned(5 downto 0);

    signal P1_Score : integer range 0 to c_Score_Limit := 0;
    signal P2_Score : integer range 0 to c_Score_Limit := 0;

begin
    Sync_To_Count_inst : entity work.Sync_To_Count
        generic map (
            g_Col_Tot => g_Col_Tot,
            g_Row_Tot => g_Row_Tot
        )
        port map (
            i_Clk => i_Clk,
            i_HSync => i_HSync,
            i_VSync => i_VSync,
            o_HSync => w_HSync,
            o_VSync => w_VSync,
            o_Col_Count => w_Col_Count,
            o_Row_Count => w_Row_Count
        );
    
    p_Reg_Sync : process(i_Clk) 
    begin
        if rising_edge(i_Clk) then
            o_VSync <= w_VSync;
            o_HSync <= w_HSync;
        end if;
    end process p_Reg_Sync;
    
    -- Dividing by 16 by dropping r LSBs (done for 40x30 downscaling)
    w_Col_Count_Div <= w_Col_Count(w_Col_Count'left downto 4);
    w_Row_Count_Div <= w_Row_Count(w_Row_Count'left downto 4);

    -- Instantiating P1 Paddle
    Paddle_P1_inst : Pong_Paddle_Ctrl
        generic map(
            g_Player_Paddle_X => c_P1_Paddle_X
        )
        port map (
            i_Clk => i_Clk,
            i_Col_Count_Div => w_Col_Count_Div,
            i_Row_Count_Div => w_Row_Count_Div,
            i_Paddle_Up => i_P1_Up,
            i_Paddle_Dn => i_P1_Down,
            o_Draw_paddle => w_draw_P1,
            o_Paddle_Y => w_P1_Y
        );

    -- Instantiating P2 Paddle
    Paddle_P2_inst : Pong_Paddle_Ctrl
        generic map(
            g_Player_Paddle_X => c_P2_Paddle_X
        )
        port map (
            i_Clk => i_Clk,
            i_Col_Count_Div => w_Col_Count_Div,
            i_Row_Count_Div => w_Row_Count_Div,
            i_Paddle_Up => i_P2_Up,
            i_Paddle_Dn => i_P2_Down,
            o_Draw_paddle => w_draw_P2,
            o_Paddle_Y => w_P2_Y
        );
    
    -- Instantiating ball and draw
    Ball_Inst : Ball_Ctrl
        port map (
            i_Clk => i_Clk,
            i_Game_state => w_Active,
            i_col_Counter_Div => w_Col_Count_Div,
            i_row_Counter_Div => w_Row_Count_Div,
            o_Ball_Draw => w_draw_ball,
            o_Ball_X_Pos => w_ball_x,
            o_Ball_Y_Pos => w_ball_y
        );

    -- Creating signals for the top and bottom paddle positions of both players. Used to check for collisions and drawing purposes
    w_P1_Paddle_Bottom <= unsigned(w_P1_Y);
    w_P1_Paddle_Top <= w_P1_Paddle_Bottom + to_unsigned(c_Paddle_Height, w_P1_Paddle_Bottom'length);

    w_P2_Paddle_Bottom <= unsigned(w_P2_Y);
    w_P2_Paddle_Top <= w_P2_Paddle_Bottom + to_unsigned(c_Paddle_Height, w_P2_Paddle_Bottom'length);

    -- State machine for game flow
    p_SM_Main : process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            case r_State is
                -- Idle state until game starts
                when s_idle =>
                    if i_start = '1' then
                        r_State <= s_active;
                    end if;
                
                -- Active game state
                when s_active =>
                    -- Conditions to check if ball has hit either side of P1 or P2, resulting in someone gaining a point
                    if w_ball_x = std_logic_vector(to_unsigned(0, w_ball_x'length)) then -- Ball on the left wall
                        if unsigned(w_ball_y) > w_P1_Paddle_Top or unsigned(w_ball_y) < w_P1_Paddle_Bottom then
                            r_State <= s_P2_Win; -- P2 wins
                        end if;
                    elsif w_ball_x = std_logic_vector(to_unsigned(c_Game_Width - 1, w_ball_x'length)) then -- Ball on the right wall
                        if unsigned(w_ball_y) > w_P2_Paddle_Top or unsigned(w_ball_y) < w_P2_Paddle_Bottom then
                            r_State <= s_P1_Win; -- P1 wins
                        end if;
                    end if;

                -- Increment score for P1 when they win unless max score is reached
                when s_P1_Win =>
                    if P1_Score = c_Score_Limit then
                        P1_Score <= 0;
                    else
                        P1_Score <= P1_Score + 1;
                    end if;
                    r_State <= s_Cleanup; -- Restarting positions
                
                -- Increment score for P2 when they win unless max score is reached
                when s_P2_Win =>
                    if P2_Score = c_Score_Limit then
                        P2_Score <= 0;
                    else
                        P2_Score <= P2_Score + 1;
                    end if;
                    r_State <= s_Cleanup; -- Restarting positions

                when s_Cleanup =>
                    r_State <= s_idle;
                
                when others =>
                    r_State <= s_idle;
                
            end case;
        end if;
    end process;
    
    -- Game active flag set only when the game is in the active state
    w_Active <= '1' when r_State = s_active else '0';

    w_draw_All <= w_draw_ball or w_draw_P1 or w_draw_P2;

    -- Telling the game to send appropriate values to RGB color outputs to draw white at pixels with paddles or ball, black otherwise
    o_Red_Video <= (others => '1') when w_draw_All = '1' else (others => '0');
    o_Grn_Video <= (others => '1') when w_draw
