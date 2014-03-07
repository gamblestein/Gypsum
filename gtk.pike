/* GTK updater for Windows

The current Pike installer for Windows installs 7.8.700 with GTK 2.12.11
We can instead run 2.24.10 by downloading a bunch of DLLs and plopping them
into the Pike binaries directory, over the top of the existing ones (backing
them up just in case).

As the GTK libraries are licensed in ways that demand source code distribution
(LGPL mainly; I haven't checked every single one of them), it's safer to write
a program that fetches from a remote site, rather than actually redistributing
the code myself and having to carry the source. Unfortunately I can't find any
easy way to download individual DLL files, but I have found a single zip file
that contains all of them - it's twice the size we need, but as that's still
two digits of megabytes, I can't be bothered doing anything smaller. But if
someone wants to devise a system that's smoother and doesn't violate license
terms, be my guest.

This script can happily download someone else's GPL'd or LGPL'd code, from
what I can find; I'm not truly "distributing" the code. It's a bit of a grey
area, though. If I were locking this code down, then someone might well have
a complaint against me for using GPL binaries like this; but I'm hoping that,
even if there is an issue, the fact that the incompatibility is between two
free licenses (Gypsum, including this file, is distributed under the terms of
the MIT license, and I don't intend to (L)GPL this file and make a mess of
that), any problems will be dealt with as bug reports rather than lawyer
letters. My intention is not to violate the GPL, nor to make anything closed
that was open. But for safety's sake, this is just a stub at present.

Usage: /update gtk

It won't actually retain itself anywhere. I could make this 'inherit command',
but what's the point? The command '/update_gtk' is no better than '/update gtk'
and there's no need to keep it in memory :)
*/

//The files we need to fetch
array(string) files=({"freetype6.dll","intl.dll","libatk-1.0-0.dll","libcairo-2.dll","libgdk-win32-2.0-0.dll","libgdk_pixbuf-2.0-0.dll",
	"libgio-2.0-0.dll","libglib-2.0-0.dll","libgmodule-2.0-0.dll","libgobject-2.0-0.dll","libgthread-2.0-0.dll","libgtk-win32-2.0-0.dll",
	"libpango-1.0-0.dll","libpangocairo-1.0-0.dll","libpangoft2-1.0-0.dll","libpangowin32-1.0-0.dll","libpng14-14.dll","zlib1.dll"});

//Place to fetch 'em from, as of 20130304
string url="http://ftp.gnome.org/pub/gnome/binaries/win32/gtk+/2.24/gtk+-bundle_2.24.10-20120208_win32.zip";

void cleanup(object self,int response) {self->destroy();}

void msgresponse(object self,int response)
{
	self->destroy();
	if (response==GTK2.RESPONSE_OK)
		GTK2.MessageDialog(0,GTK2.MESSAGE_INFO,GTK2.BUTTONS_OK,"Currently unimplemented, sorry!")
			->show()->signal_connect("response",cleanup);
}

void create()
{
	if ((string)GTK2.version()=="\2\30\12")
	{
		GTK2.MessageDialog(0,GTK2.MESSAGE_INFO,GTK2.BUTTONS_OK,"Already on GTK 2.24.10, nothing to do.")
			->show()->signal_connect("response",cleanup);
		return;
	}
	GTK2.MessageDialog(0,GTK2.MESSAGE_QUESTION,GTK2.BUTTONS_OK_CANCEL,
		sprintf("Currently you're on %d.%d.%d, and in theory, 2.24.10 is available. Fetch it?",@GTK2.version()))
		->show()
		->signal_connect("response",msgresponse);
}