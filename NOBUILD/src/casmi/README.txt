CASMI - Create A Stress Map Interactively with the World Stress Map Data Base Release 2004

CASMI version 1.1, Copyright (C) 2004  Oliver Heidbach and Jens Höhne

This program is free software; you can redistribute it and/or modify it under 
the terms of the GNU General Public License as published by the Free Software 
Foundation; either version 2 of the License, or (at your option) any later 
version. This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more 
details. 

You should have received a copy of the GNU General Public License along with 
this program; if not, write to the Free Software Foundation, Inc., 59 Temple 
Place - Suite 330, Boston, MA  02111-1307, USA. 

For comments and contact please write an e-mail to oliver.heidbach@gpi.uni-karlruhe.de or 

Oliver Heidbach
Geophysical Institute, Karlsruhe University
Hertzstr. 16
76187 Karlsruhe
Germany

Please reference the software as:

Heidbach, O. and J. Höhne (2004): CASMI - An interactive software tool for stress 
map plotting using the 2004 release of the World Stress Map data base (available 
online at www.world-stress-map.org) 

and the World Stress Map database release 2004 as: 

Reinecker, J., O. Heidbach, M. Tingay, P. Connolly, and B. Müller (2004): The 2004 
release of the World Stress Map (available online at www.world-stress-map.org) 



System Requirements and Installation Procedure

Casmi is written in Perl/Tk. It uses then a set of csh and awk
scripts, which will in turn use GMT.  
For the development we used the following versions:

- Perl: Version 5.6.1
- Tk: Version 800.023  (which is the perl-module TK.pm)
- GMT: Version 3.4.1
- convert, ps2pdf to display the map

If on your system older versions of Perl, Tk or GMT are provided, the effects
can't be predicted. The ``convert'' program from Image Magick is
necessary to display 
your map in Casmi. You can also view the created map through
ghostview (gs casmi-output.ps).

Bug Reports can be sent to: oliver.heidbach@gpi.uni-karlsruhe.de


Installing Casmi

It is assumed that all gmtcommands
are in your search path, such that <GMT command> will work. It is also
necessary that you have convert installed. This is used to
convert the ps files to gif which can be displayed by Casmi.
You then do the following:

- Unpack the tar ball:  tar -xvzf casmi.tar.gz
- Move into the casmi directory: cd casmi
- Run the configure script: csh ./configure_script

You will be asked, where your executable Perl and csh are.
- You activate Casmi by typing <full path>/casmi.pl

You can of course link this to something shorter or put it into your
$PATH variable like on bash: export PATH=$PATH:<path_to_casmi>.

