# Max-Payne-Fix-Windows-10
To Fix the sound and limit FPS to 60:

0. Go to Control Panel>Programs>Programs and Features>Turn Windows Features on or off>Legacy Components>Enable Direct Play and .NET 3.5 Framework support

1. Put all the files into the C:\Program Files (x86)\Steam\steamapps\common\Max Payne

2. Run the MaxBatch bat file

3. For sound fix just launch the C option and wait for the files to convert

4. Type E to exit the script.

5. (Optional) To avoid seeing white texture shapes in game leave the Texture color depth at 16 bits and Antialiasing on off when configuring graphics options.

# (Optional) Bonus maximize difficulty settings via registry
0. Launch the game at least once and play the tutorial level for a bit.Exit
1. Start Menu->Run and type in regedit. Press Enter. 
2. Go to HKEY_CURRENT_USER->Software->Remedy Entertainment->Max Payne. 
3. Click on the 'Game Level' folder, and some items will appear on the right side of the screen. 
4. Right-Click and select New-DWORD Value 
5. Double-Click on the entry you just made and set the value to 1. 
6. Rename the entries to the following:
* hell for Dead On Arrival mode
* nightmare for Hard-Broiled mode
* timedmode for New York Minute mode

NB! This fix needs to be used on a clean/fresh version of Max Payne installed it will not work with a bunch of other stuff installed because of API conflicts(software layer),same as any other fix
1. Uninstall Max Payne
2. Delete the Max Payne folder in C:\Program Files (x86)\Steam\steamapps\common\
3. Download all the files in the repo
4. Copy Paste into C:\Program Files (x86)\Steam\steamapps\common\Max Payne
4. Run the MaxBatch file again
5. Press C wait for files to convert then E
6. Launch game


# Enjoy the game,credit goes to Darkje for the Sound Patch creation and ThirteenAG for the wrapper creation visit his website for more goodies:https://thirteenag.github.io/wfp!
# Thanks goes to gimalaji_blake for setting it up,testing and configuring the wrapper to be recognized by the game and setiing the FPS limit.
Enjoy!
# gimalaji_blake
