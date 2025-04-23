# gradius3-widgets
- Add display widgets (numeric lives counter, current loop/stage) to Gradius III Arcade (JP).<br />
- Allows stage skip without modifying DIP switches (hold Service button and press 1P Start.  In MAME, hold 7 and press 1).<br />
- Adds pause feature (1P Start).<br />
<br />
Sample Screenshot:<br />
![Clipboard_12-10-2024_02](https://github.com/user-attachments/assets/63dc4518-6ae7-4436-b95c-f1bb700602bf)
<br />
<p>
Instructions (NEW version):<br />
- Copy "945_312.e15" and "945_313.f15" into the "gradius3j" folder.<br />
- Run "patch-new.bat".<br />
- Output will be in the "gradius3j-modded" folder.<br />
<br />
</p>
<p>
Instructions (OLD version):<br />
- Copy "945_s12.e15" and "945_s13.f15" into the "gradius3j" folder.<br />
- Run "patch-old.bat".<br />
- Output will be in the "gradius3j-modded" folder.<br />
<br />
</p>
<p>
Changelog:<br />
04/23/2025: v1.7 - Added back pause feature (fixed on PCB).<br />
04/23/2025: v1.6 - Removed pause feature (caused crashing on PCB).<br />
12/30/2024: v1.5 - Updated batch files to use the next MAME naming convention.<br />  
12/26/2024: v1.4 - Added pause feature.<br />  
12/22/2024: v1.3 - Patch now correctly shows lives using BCD rather than HEX values.<br />
12/21/2024: v1.2 - Patch is now compatible with OLD version and NEW version roms.<br />
12/10/2024: v1.1 - Fix ROM/RAM Check bypass to work on PCB.<br />
12/10/2024: v1.0 - Initial release.<br />
</p>
