### Pong on FPGA | *VHDL, Digital Logic, VGA Signal, Embedded Systems*

**Mar. 2024 – June 2024**





This project involves the design and implementation of a fully functioning **Pong game** on an **FPGA**. By leveraging **VHDL** for hardware description, the game was developed to interact with a **VGA display**, where paddles and a ball respond to real-time inputs, demonstrating proficiency in digital logic design, hardware-software integration, and signal processing.

### Design Approach

![image](https://github.com/user-attachments/assets/f1f849ba-07be-4a12-9d9c-ff8dbda6816a)


Diagram of Design Flow from NANDLAND.com

The development of the Pong game on FPGA followed a **hierarchical design methodology**, starting with basic logic elements and progressively integrating them to achieve the final working game.

- **Basic Gates and Flip-Flops:** Used for the core logic in controlling ball movement, boundary detection, and paddle control.
- **Counters and Timers:** Implemented counters to manage time intervals for game updates and frame synchronization with the VGA display.
- **Debouncing Circuits:** Designed circuits to ensure stable user input through buttons and switches, reducing errors caused by mechanical bouncing.
- **Finite State Machine (FSM):** Constructed a FSM to manage game states (e.g., start, play, win, reset), ensuring smooth transitions between game modes.
- **VGA Controller:** Developed a custom controller to generate signals for the VGA display, managing resolution and pixel placement.
- **Integrated System:** Combined the above modules to form the complete Pong game, capable of real-time gameplay and responsive controls.

---

### Major Components:

### 1. VGA Signal Controller

The **VGA controller** was designed to interface the FPGA with a VGA monitor, converting game data into graphical signals displayed on the screen. The controller supports 640x480 resolution and updates at a 60Hz refresh rate.

- **Signal Timing:** Generates the necessary horizontal and vertical sync signals to manage display frames.
- **Pixel Data Control:** Maps the game elements (paddles, ball) to pixel positions on the screen, ensuring smooth movement.
- **Resolution Management:** Adjusts timing parameters to achieve stable display across different refresh rates.

### 2. Ball and Paddle Logic

The **Ball and Paddle Logic** governs the movement of the game elements on the screen, detecting collisions and responding to player inputs.

- **Collision Detection:** Real-time monitoring of ball-paddle interactions and wall collisions, adjusting direction and speed accordingly.
- **Paddle Control:** User inputs control paddle movement, with debouncing circuits ensuring smooth transitions.
- **Speed and Directional Control:** Adjusts ball speed and trajectory based on collision points to add complexity to gameplay.

### 3. Finite State Machine (FSM)

The **FSM** controls the overall game logic, managing the transition between different game states such as start, play, score, and reset.

- **Game States:** Defines distinct states (e.g., game start, ball serve, score update) and transitions based on game events.
- **Real-Time Update:** Synchronizes game logic with VGA signals to provide consistent gameplay without glitches.

---

### Project Complexity:

The Pong on FPGA project represents a blend of **real-time digital logic design**, **VGA signal processing**, and **game theory implementation**. The modular design allowed for efficient debugging and testing of individual components before integrating them into the final system.

### Technologies and Skills:

- **VHDL (VHSIC Hardware Description Language):** Used to describe the hardware behavior of the Pong game.
- **Finite State Machine Design:** Implemented a FSM to manage game transitions and logic.
- **Signal Processing:** Developed VGA signal controller for real-time display on a 640x480 monitor.
- **Digital Logic:** Utilized combinational and sequential logic to control game elements and inputs.
- **Embedded Systems:** Applied low-level hardware and system integration to create a functional and interactive game on an FPGA.

### Key Accomplishments:

- Designed and implemented a real-time Pong game on an FPGA, achieving fluid gameplay and responsive controls.
- Developed a VGA controller capable of rendering the game on a monitor at 640x480 resolution.
- Demonstrated expertise in VHDL, FSMs, and signal processing for embedded systems development.

---

This version provides a thorough breakdown of the **Pong on FPGA** project, emphasizing its modular design and key components, while maintaining technical depth similar to the Hack Computer description.
