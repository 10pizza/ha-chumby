# Display Reverse Engineering Notes

Scope: Chumby Classic / Ironforge display hardware and framebuffer behavior; the
Chumby Wiki identifies Chumby Classic as Ironforge. [[source](https://wiki.chumby.com/index.php?title=Devices)]
Each finding is linked to a source. Unverified details are listed under
[Unknowns](#unknowns).

## Sourced Findings

| Area | Finding | Source |
| --- | --- | --- |
| Display hardware | Chumby Classic hardware uses a DataImage 320 x 240, 16 bpp TFT display with touchscreen. | [Chumby Wiki: Hacking hardware for chumby](https://wiki.chumby.com/index.php?title=Hacking_hardware_for_chumby#What.27s_in_a_chumby_classic.3F) |
| Device-table display spec | The Chumby Classic device table lists a 320 x 240 x 16 TFT with touchscreen. | [Chumby Wiki: Devices](https://wiki.chumby.com/index.php?title=Devices) |
| Framebuffer device concept | The Chumby `/dev` page describes `/dev/fb` as video memory where writes draw pixels on the screen. | [Chumby Wiki: Chumby device settings information on /dev](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fdev) |
| Framebuffer sample project | The Chumby `/dev` page links `fbwrite-1.0.tar.gz` under the Ironforge source tree as a framebuffer example. | [Chumby Wiki: Chumby device settings information on /dev](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fdev) |
| IMX framebuffer proc control | `/proc/driver/imxfb/enable` controls whether framebuffer 0 is displayed or framebuffer 1 is composited with framebuffer 0. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Framebuffer alpha control | `/proc/driver/imxfb/alpha` contains a hexadecimal alpha value for framebuffer 1 transparency over framebuffer 0. | [Chumby Wiki: Chumby device settings information on /proc](https://wiki.chumby.com/index.php?title=Chumby_device_settings_information_on_%2Fproc) |
| Framebuffer CGI enablement | The hidden Control Panel includes `FB CGI`, which enables frame buffer access through `/dev/fb` content via CGI. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Hidden_screen_in_Control_Panel) |
| Framebuffer CGI script | Framebuffer CGI capture can be started from the command line with `/usr/chumby/scripts/fb_cgi.sh`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Using_a_browser_to_see_what.27s_on_your_chumby) |
| Framebuffer CGI endpoints | The widget framebuffer is exposed as `/cgi-bin/custom/fb0` and the Control Panel overlay framebuffer is exposed as `/cgi-bin/custom/fb1`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Accessing_the_contents_of_the_frame_buffers) |
| `imgtool` draw/capture | `imgtool` can draw an image to the Chumby screen or capture the screen to an image file. | [Chumby Wiki: Chumby Software Applications, Scripts and Tools](https://wiki.chumby.com/index.php?title=Chumby_Software_Applications%2C_Scripts_and_Tools) |
| `imgtool` framebuffer selection | `imgtool --fb=0` targets the widget framebuffer and `imgtool --fb=1` targets the Control Panel framebuffer. | [Chumby Wiki: Chumby Software Applications, Scripts and Tools](https://wiki.chumby.com/index.php?title=Chumby_Software_Applications%2C_Scripts_and_Tools) |
| `imgtool` formats | `imgtool` options document `jpg` and `png` formats, with the page noting PNG capture was not supported on the author's version. | [Chumby Wiki: Chumby Software Applications, Scripts and Tools](https://wiki.chumby.com/index.php?title=Chumby_Software_Applications%2C_Scripts_and_Tools) |
| Bootloader splash conversion | Bootloader splash replacement examples draw an image, then read raw framebuffer data with `dd if=/dev/fb0 ... bs=640 count=240`. | [Chumby Wiki: Chumby tricks](https://wiki.chumby.com/index.php?title=Chumby_tricks#Bootloader_Screens) |
| Flash widget display size | Chumby ActionScript examples use a `320:240:12` Flash header for a simple widget. | [Chumby Wiki: Actionscript](https://wiki.chumby.com/index.php?title=Actionscript) |
| Flash Lite runtime | Ironforge widget development documentation says widgets target Adobe Flash Lite 3.1, with Flash Lite Player 3.1.5 as of November 2009. | [Chumby Wiki: Developing widgets for chumby](https://wiki.chumby.com/index.php?title=Developing_widgets_for_chumby) |

## Unknowns

- Exact framebuffer node names present on stock HW 3.7 firmware.
- Exact pixel byte order used by `/dev/fb0` on HW 3.7.
- Exact stride and line padding for each framebuffer.
- Exact refresh rate and practical redraw limits outside Flash Lite.
- Exact LCD controller timing values.
- Exact backlight control path for HW 3.7.
- Whether SDL2 is available or buildable on the stock Classic userspace.
- Whether direct framebuffer rendering conflicts with the stock Control Panel watchdog.
