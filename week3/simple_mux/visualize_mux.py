#!/usr/bin/env python3
"""
Visualizer for 4-digit multiplexer output.
Parses simulation output and creates an interactive pygame GUI.
"""

import re
import sys
from collections import defaultdict

try:
    import pygame
    HAS_PYGAME = True
except ImportError:
    HAS_PYGAME = False
    print("pygame not installed. Install with: pip install pygame", file=sys.stderr)

def parse_simulation_output(text):
    """
    Parse the simulation output and extract timing information.
    Returns list of (time_ns, digit_select, hex_value, note) tuples.
    """
    events = []
    lines = text.strip().split('\n')
    
    # Skip header lines
    for line in lines:
        # Match lines like "125000000 |      0111           |    0     | Digit 0"
        match = re.search(r'(\d+)\s*\|\s*([01]{4})\s*\|\s*(\d+)\s*\|\s*(.*)', line)
        if match:
            time_ns = int(match.group(1))
            digit_select = match.group(2)
            hex_val = int(match.group(3))
            note = match.group(4).strip()
            events.append((time_ns, digit_select, hex_val, note))
    
    return events

def digit_select_to_index(digit_select_bits):
    """Convert 4-bit digit_select to active digit index (0-3)."""
    # digit_select is active low, one-hot encoded
    # 0111 = digit 0, 1011 = digit 1, 1101 = digit 2, 1110 = digit 3
    patterns = {
        '0111': 0,
        '1011': 1,
        '1101': 2,
        '1110': 3,
    }
    return patterns.get(digit_select_bits, None)

class SevenSegmentDisplay:
    """Simple 7-segment display renderer."""
    def __init__(self, x, y, size=50):
        self.x = x
        self.y = y
        self.size = size
        self.segments = {
            'a': (x + size//2, y),                    # top
            'b': (x + size, y + size//2),             # top-right
            'c': (x + size, y + size + size//2),      # bottom-right
            'd': (x + size//2, y + 2*size),           # bottom
            'e': (x, y + size + size//2),             # bottom-left
            'f': (x, y + size//2),                    # top-left
            'g': (x + size//2, y + size),             # middle
        }
    
    def draw(self, surface, value, active=False, color=(100, 200, 100)):
        """Draw 7-segment with the given hex value (0-9)."""
        # Define which segments are on for each digit (0-9)
        patterns = {
            0: 'abcdef',
            1: 'bc',
            2: 'abdeg',
            3: 'abcdg',
            4: 'bcfg',
            5: 'acdfg',
            6: 'acdefg',
            7: 'abc',
            8: 'abcdefg',
            9: 'abcdfg',
        }
        
        on_segments = set(patterns.get(value % 10, ''))
        
        # Draw segments
        seg_color = (255, 100, 0) if active else (100, 100, 100)
        thickness = 4 if active else 3
        
        for seg_name, pos in self.segments.items():
            if seg_name in on_segments:
                color = (255, 200, 0) if active else (255, 150, 0)
            else:
                color = (80, 80, 80)
            
            if seg_name == 'a':  # top
                pygame.draw.line(surface, color, (self.x + 10, self.y + 5), 
                               (self.x + self.size - 10, self.y + 5), thickness)
            elif seg_name == 'b':  # top-right
                pygame.draw.line(surface, color, (self.x + self.size - 5, self.y + 10),
                               (self.x + self.size - 5, self.y + self.size - 10), thickness)
            elif seg_name == 'c':  # bottom-right
                pygame.draw.line(surface, color, (self.x + self.size - 5, self.y + self.size + 10),
                               (self.x + self.size - 5, self.y + 2*self.size - 10), thickness)
            elif seg_name == 'd':  # bottom
                pygame.draw.line(surface, color, (self.x + 10, self.y + 2*self.size - 5),
                               (self.x + self.size - 10, self.y + 2*self.size - 5), thickness)
            elif seg_name == 'e':  # bottom-left
                pygame.draw.line(surface, color, (self.x + 5, self.y + self.size + 10),
                               (self.x + 5, self.y + 2*self.size - 10), thickness)
            elif seg_name == 'f':  # top-left
                pygame.draw.line(surface, color, (self.x + 5, self.y + 10),
                               (self.x + 5, self.y + self.size - 10), thickness)
            elif seg_name == 'g':  # middle
                pygame.draw.line(surface, color, (self.x + 10, self.y + self.size - 2),
                               (self.x + self.size - 10, self.y + self.size + 2), thickness)

def visualize_pygame(events):
    """Create interactive pygame visualization."""
    if not HAS_PYGAME:
        print("pygame required for GUI visualization", file=sys.stderr)
        return
    
    pygame.init()
    
    # Window setup
    WIDTH, HEIGHT = 1000, 400
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("4-Digit Multiplexer Visualizer")
    clock = pygame.time.Clock()
    font_big = pygame.font.Font(None, 48)
    font_small = pygame.font.Font(None, 32)
    
    # Create 4 seven-segment displays
    displays = [
        SevenSegmentDisplay(100 + i*200, 100, size=80)
        for i in range(4)
    ]
    
    # Simulation state
    event_idx = 0
    digit_values = [0, 0, 0, 0]
    active_digit = 0
    paused = False
    frame_count = 0
    
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE:
                    paused = not paused
                elif event.key == pygame.K_n:
                    event_idx = (event_idx + 1) % len(events)
                    paused = True
                elif event.key == pygame.K_p:
                    event_idx = (event_idx - 1) % len(events)
                    paused = True
                elif event.key == pygame.K_r:
                    event_idx = 0
                    digit_values = [0, 0, 0, 0]
                    paused = True
        
        # Update simulation
        if not paused and event_idx < len(events):
            frame_count += 1
            if frame_count > 30:  # ~30 frames per event at 60 FPS
                frame_count = 0
                time_ns, digit_select, hex_val, note = events[event_idx]
                active_idx = digit_select_to_index(digit_select)
                
                if active_idx is not None:
                    digit_values[active_idx] = hex_val
                    active_digit = active_idx
                
                event_idx += 1
        
        # Draw
        screen.fill((20, 20, 30))
        
        # Draw displays
        for i, display in enumerate(displays):
            is_active = (i == active_digit) if event_idx < len(events) else False
            display.draw(screen, digit_values[i], active=is_active)
            
            # Label
            label = font_small.render(f"D{i}", True, (150, 150, 200))
            screen.blit(label, (120 + i*200, 300))
        
        # Draw status
        if paused:
            status = "PAUSED"
            color = (255, 100, 100)
        else:
            status = f"PLAYING {event_idx}/{len(events)}"
            color = (100, 255, 100)
        
        status_text = font_small.render(status, True, color)
        screen.blit(status_text, (50, 20))
        
        # Instructions
        instr_font = pygame.font.Font(None, 24)
        instructions = [
            "SPACE: Play/Pause | N: Next | P: Previous | R: Reset | Q: Quit"
        ]
        for i, instr in enumerate(instructions):
            instr_surf = instr_font.render(instr, True, (150, 150, 150))
            screen.blit(instr_surf, (50, 350))
        
        pygame.display.flip()
        clock.tick(60)
    
    pygame.quit()

def visualize_ascii(events):
    """Create ASCII visualization of digit display over time."""
    pass  # Removed for brevity

def main():
    # Parse arguments
    use_gui = '--gui' in sys.argv or (HAS_PYGAME and '--text' not in sys.argv)
    input_file = None
    
    for arg in sys.argv[1:]:
        if not arg.startswith('--'):
            input_file = arg
            break
    
    # Read input
    if input_file:
        with open(input_file, 'r') as f:
            text = f.read()
    else:
        text = sys.stdin.read()
    
    events = parse_simulation_output(text)
    
    if not events:
        print("Error: Could not parse simulation output", file=sys.stderr)
        sys.exit(1)
    
    print(f"Parsed {len(events)} events from simulation", file=sys.stderr)
    
    # Launch GUI or text visualization
    if use_gui:
        if HAS_PYGAME:
            print("Launching pygame GUI...", file=sys.stderr)
            visualize_pygame(events)
        else:
            print("pygame not available, use --text for text output", file=sys.stderr)
            sys.exit(1)
    else:
        # Text-based output
        print("\n" + "="*70)
        print("4-DIGIT MULTIPLEXER STATE TABLE")
        print("="*70 + "\n")
        print(f"{'Time (ns)':>12} | {'Digit Sel':>10} | {'Active':>7} | {'Display Value':>14} | {'Note':>20}")
        print("-"*70)
        
        digit_display = [0, 0, 0, 0]
        for time_ns, digit_select, hex_val, note in events:
            active_idx = digit_select_to_index(digit_select)
            if active_idx is not None:
                digit_display[active_idx] = hex_val
            display_str = f"[{digit_display[0]}{digit_display[1]}{digit_display[2]}{digit_display[3]}]"
            active_str = f"D{active_idx}" if active_idx is not None else "N/A"
            print(f"{time_ns:12d} | {digit_select:>10} | {active_str:>7} | {display_str:>14} | {note:>20}")
        
        print("\n" + "="*70)
        print("4-DIGIT MULTIPLEXER ANIMATION (Frame by Frame)")
        print("="*70 + "\n")
        
        digit_values = {0: '-', 1: '-', 2: '-', 3: '-'}
        for idx, (time_ns, digit_select, hex_val, note) in enumerate(events):
            active_idx = digit_select_to_index(digit_select)
            if active_idx is not None:
                digit_values[active_idx] = str(hex_val)
            
            print(f"Frame {idx+1} @ Time {time_ns/1e6:.2f} ms")
            print("┌──────────────────┐")
            print(f"│  {digit_values[0]} {digit_values[1]} {digit_values[2]} {digit_values[3]}  │  (7-seg Input)")
            print(f"│  [D{active_idx}]  │  Active Digit" if active_idx is not None else "│  [--]  │  Active Digit")
            print("└──────────────────┘")
            print(f"  {note}\n")

if __name__ == '__main__':
    main()
