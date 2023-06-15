# Battleship for NES

Simple 1 or 2-player Battleship game for NES.

## Build the ROM

To build the ROM, you will need the following tools installed and available in your `PATH`:

- [cc65 (for ca65 and ld65)](https://cc65.github.io/getting-started.html)
- [neschr](https://github.com/spencerjbeckwith/neschr)
- [FamiStudio](https://famistudio.org/)
  - If you are using Linux, you will need to install the `FamiStudio.exe` binary as the Flatpak installation doesn't appear to allow CLI usage. Here are the steps I followed to make the `famistudio` command available from my terminal:
    - First, install [Mono](https://www.mono-project.com/download/stable/#download-lin-ubuntu).
    - Now, download and extract the [FamiStudio binary](https://github.com/BleuBleu/FamiStudio/releases/download/4.0.6/FamiStudio406-LinuxAMD64.zip)
    - Copy the extracted folder to a location on your path, for example:
      - `sudo mkdir /usr/bin/famistudio-bin`
      - `sudo cp -r famistudio-bin /usr/bin/famistudio-bin`
    - Add a script to your path called `famistudio` with the following contents:

        ```sh
        #!/bin/sh
        mono /usr/bin/famistudio-bin/FamiStudio.exe "$@"
        ```

    - Now make this script executable:
      - `sudo chmod +x /usr/bin/famistudio`
    - Verify it worked by running `famistudio -?`
    - And if you _really_ wanna be a cool kid - create `/usr/share/applications/famistudio.desktop` so you can open `.fms` files through your file system:

        ```desktop
        [Desktop Entry]
        Encoding=UTF-8
        Version=4.0.6
        Type=Application
        Terminal=False
        Exec=famistudio %F
        Name=FamiStudio
        MimeType=application/octet-stream
        Icon=/usr/bin/famistudio-bin/famistudio.png
        ```

      - And if you want the icon to show up, [download it](https://github.com/BleuBleu/FamiStudio/blob/master/FamiStudio/Resources/Icons/FamiStudio.iconset/icon_128x128.png) and put it at `/usr/bin/famistudio-bin/famistudio.png` or another location as you set in `famistudio.desktop`.

Once these tools are installed, run `make`. Running `make clean` will remove all output files.

If `make` does not succeed, try changing the parameters at the top of the Makefile to using the correct binaries for your system.
