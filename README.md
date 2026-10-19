# COAL-Assignment-work# x86 Text Viewport & Keyword Highlighter

A 16-bit x86 Assembly program (NASM) designed for DOSBox that renders a bordered text viewport directly via VGA text-mode memory (`0xB800`). It supports automatic line wrapping, custom window scrolling, real-time keyword search and highlighting, and a dynamic status bar.

## Author
* **Name:** Abdul Moiz
* **Roll Number:** 25L-0522

---

## Features

* **Direct VGA Memory Manipulation:** Interfaces directly with segment `0xB800` for fast screen clearing, border rendering, and text output.
* **Custom Double-Line Frame:** Draws a centered viewport box from `(Row 3, Col 8)` to `(Row 21, Col 71)` using extended ASCII box-drawing characters (`0xCD`, `0xBA`, `0xC9`, `0xBB`, `0xC8`, `0xBC`).
* **Auto-Centered Title Bar:** Calculates string length dynamically to center the header on Row 4 with custom color attributes.
* **Multi-Line Text Rendering & Wrapping:** Parses newline characters (`10` / `\n`) and automatically wraps lines exceeding 60 characters per row to keep text strictly inside the viewport boundaries.
* **Windowed Scrolling (`scroll_window_up`):** Scrolls a defined rectangular subregion up by `n` rows without disturbing the surrounding frame or title bar.
* **Keyword Search & Highlight (`find_and_highlight`):** Scans the active viewport buffer for a target substring, applies a blinking/highlighted attribute (`0xCE`) to every match, and tracks the total match count.
* **Dynamic Status Bar:** Displays the total number of keyword matches found alongside the current viewport status on Row 23.

---

## Architecture & Subroutines

| Subroutine | Parameters (Stack) | Description |
| :--- | :--- | :--- |
| `getOffset` | `row`, `col` | Calculates the linear VGA byte offset: `(row * 80 + col) * 2` and returns it in `AX`. |
| `clearScreen` | *None* | Fills all 2,000 character cells on the 80x25 screen with blank spaces (`0x0720`). |
| `drawFrame` | *None* | Renders the double-lined rectangular border on the screen. |
| `drawTitle` | `offset`, `attr` | Measures the null-terminated title string and prints it centered on Row 4. |
| `drawText` | `offset`, `attr` | Prints the paragraph inside the frame starting at `(Row 6, Col 10)` with 60-column wrapping. |
| `scroll_window_up` | `top`, `left`, `bottom`, `right`, `n` | Shifts rows within the specified coordinates up by `n` lines and clears the vacated bottom rows. |
| `find_and_highlight`| `string`, `attr` | Scans the viewport video memory for matches of `string`, highlights them with `attr`, and increments `[matches]`. |
| `printNum` | `num`, `offset` | Converts a 16-bit integer into ASCII digits and writes them to video memory. |
| `drawStatus` | *None* | Renders `Total Matches Found: [X] | Viewport Status: ACTIVE` at the bottom of the screen. |

---

## Prerequisites

* **Assembler:** [NASM](https://www.nasm.us/) (Netwide Assembler)
* **Emulator:** [DOSBox](https://www.dosbox.com/) (0.74-3 or compatible)

---

## How to Assemble & Run

1. **Clone the repository** or save the source code as `viewport.asm`.
2. **Mount your directory** inside DOSBox:
   ```dos
   mount c C:\path\to\your\folder
   c:
