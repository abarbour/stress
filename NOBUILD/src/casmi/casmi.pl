#!/usr/bin/perl -w

##############################################################
## CASMI - Create A Stress Map Interactively with the 
## World Stress Map Data Base Release 2008
##
## CASMI version 2.0 Copyright (C) 2008  
## Oliver Heidbach, Daniel Kurfeß & Jens Höhne
##
## This program is free software; you can redistribute it 
## and/or modify it under the terms of the GNU General 
## Public License as published by the Free Software Foundation;
## either version 2 of the License, or (at your option) any 
## later version. This program is distributed in the hope that 
## it will be useful, but WITHOUT ANY WARRANTY; without even 
## the implied warranty of MERCHANTABILITY or FITNESS FOR A 
## PARTICULAR PURPOSE.  See the GNU General Public License for 
## more details. You should have received a copy of the GNU 
## General Public License along with this program; if not, 
## write to the Free Software Foundation, Inc., 59 Temple 
## Place - Suite 330, Boston, MA  02111-1307, USA. 
##
## For comments and contact please write an e-mail to 
## oliver.heidbach@gpi.uni-karlsruhe.de or 
##
## Oliver Heidbach
## Geophysical Institute, Karlsruhe University
## Hertzstr. 16
## 76187 Karlsruhe
## Germany
##############################################################

package casmi;

use strict;
use warnings;

use File::Basename;
use File::Copy;
use Cwd;
use Tk;
require Tk::LabEntry;


# the $Bin Variable contains the path to the executable tk2.pl
use FindBin qw($Bin $RealBin);
use lib "$FindBin::Bin";
# resolve possible links
$Bin = $RealBin;
require "$Bin/Process.pm";

my ($startdir, $DEBUG, $ms24_messages);
$ms24_messages = "There aren't no messages until you press 'Make Map' \n";
$startdir = Cwd::cwd();

$DEBUG = 0;  # if DEBUG = 1 print stuff

##################################################
## Windows                                      ##
## Deklaration in main, so that we can test     ##
## for existance and don't open it twice        ##
##################################################
my ($range_w, $proj_extra_var_w, $map_attributes_w, $topography_w,
    $map_title_w, $map_info_w, $overview_map_w, $stress_data1_w,
    $symbols_stress1_w, $stress_legend_w, $user_stress_w,
    $user_symbols_stress_w, $page_settings_w, $change_files_directories_w,
    $change_gmt_defaults_w, $gmt_messages_w,
    # extras on extra line
    $plot_smooth_data_w, $plot_gridded_smooth_w,
    $plot_smooth_traj_w, $plate_motions_w, $other_data_w, $cmt_w,
   );

###################################################
#          Initalisierung vom hash               ##
###################################################
my %mailvarhash  = (
		   'PsName'       => 'casmi-output',
 		   'c1_lat'       => '28',    # Range + Proj W.
 		   'c2_lat'       => '52',
		   'c1_lon'       => '8',
 		   'c2_lon'       => '42',
 		   'ProjectionName' => 'Mercator',
 		   'MapShape'     => 'bounded',
		   'lon_pro'      => 'default', # proj_extra_var
		   'lat_pro'      => 'default',
		   'stan1_pro'    => 'default',
		   'stan2_pro'    => 'default',
		   'CentralMerid' => 'default',
		   'Rivers'       => 'n',
		   'Coastlines'   => 'y',
		   'PlotMapTitle' => 'n',     # Map Title
		   'MapTitle'     => '"Example Title"',
		   'MapTitleFontS'=> '16',
		   'MapTitleFontC'=> '0/0/0',
		   'MapTitleLoc'  => 'above',
		   'GridLinesLon' => '0',     # Map Info
		   'GridLinesLat' => '0',
		   'GridAnnotLon'=> '10',
		   'GridAnnotLat' => '5',
		   'SimpleMapScale'=> 'n',
		   'ScaleLength'  => '200',
		   'ScalePosition' => 'default',
		   'PlotInfoString'=> 'n',
		   'Insert' => 'n',     # Overview Map
		   'PosInsert' => 'll',
		   'InsertWidth' => 'default',
		   'ShowPolitInsert' => 'n',
		   'c1i_lon' => '-2',
		   'c2i_lon' => '52',
		   'c1i_lat' => '18',
		   'c2i_lat' => '62',
		   'ContinFillInsert' => '245/245/245',
		   'OceanFillInsert' => '220/245/255',
		   'CoastlineInsert' => '1/0/0/0',
		   'MapColorInsert' => '250/250/250',
		   'PolitBoundInsert' => '1/125/0/125',
		    
		   'Stress1Type'    => 'user_defined',  # stress_data1
		   'S1TypeFMS' => 'y',
		   'S1TypeFMA' => 'y',
		   'S1TypeFMF' => 'y',
		   'S1TypeBO' => 'y',
		   'S1TypeOC' => 'y',
		   'S1TypeHF' => 'y',
		   'S1TypeGI' => 'y',
		   'S1TypeDIF' => 'y',
		   'S1TypeBS' => 'y',
                   'S1_Regimes' => 'user_defined',      # regimes
                   'S1_Regime_TF' => 'y',
                   'S1_Regime_TS' => 'y',
                   'S1_Regime_SS' => 'y',
                   'S1_Regime_NS' => 'y',
                   'S1_Regime_NF' => 'y',
                   'S1_Regime_U' => 'y',
		   'S1_BoundaryEvents_exclude_all' => 'user_defined',
		   'S1_BoundaryEvents_exclude_reg' => 'user_defined',
		   'S1_BoundaryEvents_exclude_PBE' => 'user_defined',
                   'S1_CTF_exclude_all' => 'n',            #CTF
                   'S1_CTF_exclude_all_distance' => '200',
                   'S1_CTF_exclude_SS' => 'n',
                   'S1_CTF_exclude_SS_distance' => '200',
		   'S1_CTF_exclude_PBE_events' => 'y',
                   'S1_CRB_exclude_all' => 'n',            #CRB
                   'S1_CRB_exclude_all_distance' => '200',
                   'S1_CRB_exclude_NF' => 'n',
                   'S1_CRB_exclude_NF_distance' => '200',
		   'S1_CRB_exclude_PBE_events' => 'y',
                   'S1_CCB_exclude_all' => 'n',            #CCB
                   'S1_CCB_exclude_all_distance' => '200',
                   'S1_CCB_exclude_TF' => 'n',
                   'S1_CCB_exclude_TF_distance' => '200',
		   'S1_CCB_exclude_PBE_events' => 'y',
                   'S1_OTF_exclude_all' => 'n',            #OTF
                   'S1_OTF_exclude_all_distance' => '200',
                   'S1_OTF_exclude_SS' => 'n',
                   'S1_OTF_exclude_SS_distance' => '200',
		   'S1_OTF_exclude_PBE_events' => 'y',
                   'S1_OSR_exclude_all' => 'n',            #OSR
                   'S1_OSR_exclude_all_distance' => '200',
                   'S1_OSR_exclude_NF' => 'n',
                   'S1_OSR_exclude_NF_distance' => '200',
		   'S1_OSR_exclude_PBE_events' => 'y',
                   'S1_OCB_exclude_all' => 'n',            #OCB
                   'S1_OCB_exclude_all_distance' => '200',
                   'S1_OCB_exclude_TF' => 'n',
                   'S1_OCB_exclude_TF_distance' => '200',
		   'S1_OCB_exclude_PBE_events' => 'y',
                   'S1_SUB_exclude_all' => 'n',            #SUB
                   'S1_SUB_exclude_all_distance' => '200',
                   'S1_SUB_exclude_TF' => 'n',
                   'S1_SUB_exclude_TF_distance' => '200',
		   'S1_SUB_exclude_PBE_events' => 'y',
		   'Stress1Quality' => 'user_defined',  #Quality
		   'S1QualA' => 'y',
		   'S1QualB' => 'y',
		   'S1QualC' => 'y',
		   'S1QualD' => 'n',      
		   'S1QualE' => 'n',      
		   'S1DepthTop'   => '0',     
                   'S1DepthBot'   => '40',
		   'Stress1Depth' => 'all',
		   
		   'Stress2Data'  => 'no',             # user_stress_data
		   'Stress2Type'    => 'user_defined',  
		   'S2TypeFMS' => 'y',
		   'S2TypeFMA' => 'y',
		   'S2TypeFMF' => 'y',
		   'S2TypeBO' => 'y',
		   'S2TypeOC' => 'y',
		   'S2TypeHF' => 'y',
		   'S2TypeGI' => 'y',
		   'S2TypeDIF' => 'y',
		   'S2TypeBS' => 'y',
                   'S2_Regimes' => 'user_defined',      # regimes
                   'S2_Regime_TF' => 'y',
                   'S2_Regime_TS' => 'y',
                   'S2_Regime_SS' => 'y',
                   'S2_Regime_NS' => 'y',
                   'S2_Regime_NF' => 'y',
                   'S2_Regime_U' => 'y',
		   'Stress2Quality' => 'user_defined',  #Quality
		   'S2QualA' => 'y',
		   'S2QualB' => 'y',
		   'S2QualC' => 'y',
		   'S2QualD' => 'n',      
		   'S2QualE' => 'n',      
		   'S2DepthTop'   => '0',     
                   'S2DepthBot'   => '40',
		   'Stress2Depth' => 'all',

		   'DataSet' => 'i',   # from map attributes
		   'DataSize'=> '10000',        
		   'DataLevel'=> 2,
		   'Coastlines' => 'y',
		   'CoastPenSize' => 3,
		   'CoastPenColor' => '0/0/0',
		   'OceanFill' => '190/210/255',
		   'ContinentFill' => '250',
		   'Rivers' => 'n',
		   'RiverPenSize' => 2,
		   'RiverPenColor' => '190/210/255',
		   'PoliticalBounds' => 'y',
		   'PolitBoPenSize' => '2',
		   'PolitBoPenColor' => '200/0/200',
		   'PlateBounds' => 'y',
		   'PlaBoPenSiz' => '10',
		   'PlaBoPenCol' => '100/100/100',
		   'Topography' => 'n',       #topgraphy
		   'TopoIllum' => 'n',
		   'TopoIllumAng' => '90',
		   'TopoIllumNorm' => 't0.75',
		   'GridScale' => 'n',
		   'GridScaleOri' => 'h',
		   'GridScaleLen' => 3,
		   'GridScaleWid' => '0.3',
		   'GridScaleX' => '3',
		   'GridScaleY' => '3',
		   'GridScaleLab' => '"Topography"',
		   'GridScaleSpac' => '-L',
		   'GridScaleFil' => 'no',
		   'Contour' => 'n',
		   'ContourInterval' => 200,
		   'ContourAnnot' => 500,
		   'ContourPen' => '4/255/0/0/ta',
		   
		   'Stress1DataSize' => 'middle',  # symbols_stress1
		   'Stress1DataColor' => 'default',
		   'Stress1DataLen' => 'middle',
		   'Stress1DataT' => 'middle',
		   'Stress1SC' => 'n',
		   'S1DataQASize' => '0.3',
		   'S1DataQBSize' => '0.24',
		   'S1DataQCSize' => '0.18',
		   'S1DataQDSize' => '0.12',
		   'S1DataQESize' => '0.12',
		   'S1DataQALen' => '0.9',
		   'S1DataQBLen' => '0.7',
		   'S1DataQCLen' => '0.5',
		   'S1DataQDLen' => '0.3',
		   'S1DataQELen' => '0.1',
		   'S1DataTFColor' => '0/0/200',
		   'S1DataNFColor' => '200/0/0',
		   'S1DataSSColor' => '0/200/0',
		   'S1DataUColor'  => '0/0/0',
		   'S1QualAT' => '4',
		   'S1QualBT' => '4',
		   'S1QualCT' => '4',
		   'S1QualDT' => '4',
		   'S1QualET' => '4',
		   'Stress1SCCol' => '0/0/0',
		   'Stress1SCFontSiz' => '6',

		   'Stress2DataSize' => 'middle',  # user_symbols_stress
		   'Stress2DataColor' => 'default',
		   'Stress2DataLen' => 'middle',
		   'Stress2DataT' => 'middle',
		   'Stress2SC' => 'n',
		   'S2DataQASize' => '0.3',
		   'S2DataQBSize' => '0.24',
		   'S2DataQCSize' => '0.18',
		   'S2DataQDSize' => '0.12',
		   'S2DataQESize' => '0.12',
		   'S2DataQALen' => '0.9',
		   'S2DataQBLen' => '0.7',
		   'S2DataQCLen' => '0.5',
		   'S2DataQDLen' => '0.3',
		   'S2DataQELen' => '0.1',
		   'S2DataTFColor' => '0/0/200',
		   'S2DataNFColor' => '200/0/0',
		   'S2DataSSColor' => '0/200/0',
		   'S2DataUColor'  => '0/0/0',
		   'S2QualAT' => '4',
		   'S2QualBT' => '4',
		   'S2QualCT' => '4',
		   'S2QualDT' => '4',
		   'S2QualET' => '4',
		   'Stress2SCCol' => '0/0/0',
		   'Stress2SCFontSiz' => '6',
		   
		   'StressLegend' => 'y',   #Stess Legend
		   'PosStressLegend' => 'ur',
		   'SizeStressLegend' => 'middle',
		   'StressLegBackgr' => '255/255/255',
		   'DepthIntLeg' => 'n',

		   'PaperSize' => 'A4',  # page_settings
		   'PaperWidth' => '',
		   'PaperHeight' => '',
		   'PaperOrientation' => 'Portrait',
		   'LeftMargin' => '0.7',
		   'BottomMargin' => '1.',
		   'BBoxFrame' => 'n',
		   'BBoxFrameCol' => '-W2/0/0/0',
		   'BBoxFilCol' => '',
		   'PlotWidth' => 'default',

		   'TEMP' => '$HOME/.casmi-Temp/',
		   'TEMP1' => '$HOME/.casmi-Temp1/',
		   'TEMP2' => '$HOME/.casmi-Temp2/',
		   'SCRIPTS' => "$Bin/ScriptsRel2.4", # extras
		   'Stress1Data' => "$Bin/DATA/wsm.dat",
		   'PlaBoData' => "$Bin/DATA/BIRD_plate_boundaries.dat",
		   'TopoFile' => "$Bin/DATA/dtm5.grd",
		   'TopoCptFile' => "$Bin/DATA/topo_col.cpt",
		   'NOFOOTHER' => 'no',
		   'OVERLAY'   => 'no',

		   'DOTS_PER_INCH' => '600',  # change_gmt_defaults
		   'MEASURE_UNIT' => 'cm',
		   'BASEMAP_TYPE' => 'plain',
		   'ANOT_FONT_SIZE' => '14p',
		   'FRAME_WIDTH' => '0.075i',
		   'FRAME_PEN'  => '1.25p',
		   'PAGE_COLOR' => '255/255/255',
		   'LABEL_FONT_SIZE' => '14p',

		    'SmoothData' => 'n',  # smooth
		    'SmSmData'   => "$startdir/casmi-smooth.sdat",
		    'SmSmDataLen' => 'tiny',
		    'SmSmDataCol' => '0/0/0',
		    'SmSmDataT'   => '0.001',
		    'SmInfo'      => 'n',

		    'SmoothGridmap' => 'n',
		    'SmGridData'    => "$startdir/casmi-smooth.grdm",
		    'SmGridDataLen' => 'tiny',
		    'SmGridDataT'   => '0.01',
		    'SmGridDataCol' => '-W1/255/0/0',

		    'SmoothTraj'    => 'n',
		    'SmTrajData'    => "$startdir/casmi-smooth.trjs",
		    'SmTrajDataSize'=> '1',
		    'SmTrajDataCol' => '255/0/0',
		    
		    'PlateMotions'  => 'y',  # plate_motions
		    'MotionPlates'  => 4,
		    'MotionArrow'  => 'n', # if y, binary relmotion would be called
		    'MotionTraj'    => 'n',
		    'MotionTrajInc' => 5,
		    'MotionTrajPen' => 1,
		    'MotionTrajCol' => '0to',

		    'Points'        => '0', # Points, Earthquake Data => other_data
		    'Point1Data'    => "$Bin/DATA/example_point_data.dat",
		    'Point1Symbol'  => 'c0.09',
		    'Point1SymbPenSiz' => '4',
		    'Point1SymbPenCol' => '0',
		    'Point1SymbFilCol' => '100',
		    'Point1SymbFilCpt' => 'no',
		    'Point1SymbCpt' => "$Bin/DATA/topo_col.cpt",

		    'Names'         => 0,  # other_data: names
		    'Name1Data'     => "$Bin/DATA/example_names_data.dat",
		    'Name1Symbol'   => 'c0.05',
		    'Name1SymbPenSiz'   => 5,
		    'Name1SymbPenCol'   => 0,
		    'Name1SymbFilCol'   => 0,
		    'Name1TextPenCol'   => 0,
		    'Name1TextFontSiz'   => 10,
		    'Name1XShift'   => 0.05,
		    'Name1YShift'   => 0.05,

		    'Text'          => 'n', # other_data: text
		    'TextData'      => "$Bin/DATA/example_text_data.dat",
		    'TextRecFil'    => 'no',
		    'TextRecCle'    => '0.05/0.05',
		    'TextFilCol'    => 0,

		    'Polygons'      => 'n',
		    'Polyg1Data'    => "$Bin/DATA/example_poly_data.dat",
		    'Polyg1PenSiz'  => 34,
		    'Polyg1PenCol'  => 0,
		    'Polyg1FilCol'  => 'no',

		    'PlotCMT'       => 'n',  #extras: cmt
		    'CMTFile'       => "$Bin/DATA/test_cmt.dat",
		    'CMTPlotType'   => 'd',
		    'CMTScale'      => 0.5,
		    'CMTFontSize'   => 0,
		    'CMTOffset'     => 1,
		    'CMTHeader'     => 17,
		    'CMTThrustFill' => '255/0/0',
		    'CMTExtFill'    => '0/0/255',

		  );
my %mailvarhash_backup = %mailvarhash;

# load settings if there is a $HOME/casmi_defaults.cas file
if (-e $ENV{HOME}.'/casmi_defaults.cas') {
    load_settings($ENV{HOME}.'/casmi_defaults.cas');
}

my $mvhash_ref = \%mailvarhash;
my %measure_unit_h = ('cm' => 'cm',
		     'i' => 'Inch',);
my $unit = $measure_unit_h{$mailvarhash{MEASURE_UNIT}};
my $user_defined = 'User Defined';

####################################################
#                     Menu                        ##
####################################################

# Declaration of Variables

# some Var for the map output format
my ($map_output_format_g, $start_image, $prefix, $ms24, $range_image,
    $proc, $labeltext,);

# neues Prozess Objekt:
$proc = Process->new();
$labeltext = 'Make Map!';

my ($mw, $menubar);
# Buttons on the Menubar
my ($file_mpd, $stress_par_mpd, $map_par_mpd, $extras_mpd,
    $map_it_mb, $exit_mb, $help_mb, $info_mb);
my ($canvas_w);      # Canvas for the map
# Fonts
my ($big_font, $small_font);
# Stress Data Menu

# Range Menu
my ($range_mb, $map_attributes_mb, $overview_map_mb,
    $map_title_mb, $map_info_mb, $topography_mb,);

# Initialising
$map_output_format_g = 'gif';
$start_image = $Bin.'/start_image.gif';
$range_image = $Bin.'/range_image_small.gif';
$ms24 = 'ms24.gmt';


# Main Window
$mw = MainWindow -> new();
$mw -> wm("geometry", "623x623");
$mw -> title("CASMI - Create A Stress Map Interactively");

# Menu Bar
$mw -> configure (-menu => $menubar = $mw -> Menu);

# Buttons on the menu bar
$file_mpd = $menubar -> cascade (-label => "File");
$stress_par_mpd = $menubar -> cascade (-label => "Data Parameters");
$map_par_mpd = $menubar -> cascade (-label => "Map Parameters");
$extras_mpd = $menubar -> cascade (-label => "Extras");

# some space before and after map_it:
$menubar -> command (-label => '    ', -command => sub {});
$map_it_mb = $menubar -> command (-label => $labeltext,
				  -command => \&map_it);
$menubar -> command (-label => '    ',);

# Map It Button
# $menubar -> command (-label => 'My Map', -command => \&my_map);

# Help
$help_mb = $menubar -> command (-label => "Help",
				-command => \&open_help);
# Info
$info_mb = $menubar -> command (-label => "Info",
				-command => \&open_info);
# Exit
$exit_mb = $menubar -> command ( -label => "Quit!",
				 -command => \&exit_casmi);

###################################
#      Canvas                    ##
###################################
# to use this , we need to know the bounding box info for the scrollregion
# $canvas_w = $mw -> Scrolled (qw/Canvas -relief sunken -borderwidth 2 -scrollbars se -scrollregion/ => ['-10c', '-10c', '50c', '20c'])
$canvas_w = $mw -> Scrolled (qw/Canvas -relief sunken -borderwidth 2 -scrollbars se /)
  -> pack(-expand => 'yes', -fill => 'both');

show_map($start_image);


###################################
#      Fonts                     ##
###################################
# used for headings
$big_font = $mw ->
  fontCreate('ueberschrift', -family => 'helvetica',
	     -weight => 'bold',
	     -size => 14,);
$small_font = $mw -> fontCreate (-family => 'helvetica', -size => 2);

##################################################
##      File Menu                              ###
##################################################

$file_mpd -> command (-label => "Page Settings",
		      -command => \&page_settings
		      );
$file_mpd -> command (-label => "Save Map As",
		      -command => \&save_map
		      );
$file_mpd -> command (-label => "Save Stress Data (ASCII)",
		      -command => \&save_ascii_data
		      );
$file_mpd -> command (-label => "Save Plot Settings",
		      -command => \&save_settings
		      );
$file_mpd -> command (-label => "Load Plot Settings",
		      -command => \&load_settings
		      );
$file_mpd -> command (-label => "All settings to default",
		      -command => \&all_to_default
		      );
$file_mpd -> command (-label => 'Exit',
		      -command => \&exit_casmi,
		      );


###################################################
##         Stress Data Menu                      ##
###################################################

$stress_par_mpd -> command (-label => "WSM Stress Data",
			   -command => \&stress_data1
			  );
$stress_par_mpd -> command (-label => "Symbols WSM",
			    -command => \&symbols_stress1,
			    );
$stress_par_mpd -> command (-label => "Stress Legend",
			    -command => \&stress_legend,
			    );

   $stress_par_mpd -> command (-label => "User Stress Data",
   			   -command => \&user_stress_data,
   			  );
   $stress_par_mpd -> command (-label => "Symbols User Data",
   			    -command => \&user_symbols_stress,
   			    );

###################################################
##     Map Parameters Menu                      ###
###################################################

#  Begin of Range

$range_mb = $map_par_mpd -> command(-label   => "Set Range and Projection",
				    -command => \&Set_Range);
$map_attributes_mb = $map_par_mpd
  ->command(-label   => "Map Attributes",
	    -command => \&map_attributes);
$topography_mb = $map_par_mpd -> command (-label => 'Topography',
					  -command => \&topography);

$map_title_mb = $map_par_mpd -> command (-label => "Map Title",
					 -command => \&map_title);
$map_info_mb = $map_par_mpd -> command (-label => "Map Information",
					 -command => \&map_info);

$overview_map_mb = $map_par_mpd
  ->command(-label   => "Overview Map",
	    -command => \&overview_map);

###################################################
##     Extras Menu                              ###
###################################################

$extras_mpd -> command(-label   => "Change Files/Directories",
		       -command => \&change_files_directories);
$extras_mpd -> command(-label   => "Change GMT Defaults",
		       -command => \&change_gmt_defaults);
$extras_mpd -> command(-label   => "Show GMT Messages",
		       -command => \&show_gmt_messages);
$extras_mpd -> command(-label   => "Plot smoothed data",
		       -command => \&plot_smoothed_data);
$extras_mpd -> command(-label   => "Plot gridded smoothed data",
		       -command => \&plot_gridded_smooth);
$extras_mpd -> command(-label   => "Plot smoothed trajectories",
		       -command => \&plot_smooth_trajectories);
$extras_mpd -> command(-label   => "Relative Plate Motions",
		       -command => \&plate_motions);
$extras_mpd -> command(-label   => "Other Data",
		       -command => \&other_data);
$extras_mpd -> command(-label   => "CMT Solutions",
		       -command => \&cmt);

####################################################
##            Packen                             ###
####################################################

# $mw_m  -> pack (-side => 'top', -fill => 'x');
# $file_mpd ->pack (-side => 'left');
# $stress_par_mpd ->pack (-side => 'left');
# $map_par_mpd ->pack (-side => 'left');
# $exit_mb -> pack  (-side => 'right');

##########################################################
##          Subs                                       ###
##########################################################

sub map_it{

    my (@args, $message_w);
    print "\nStart producing the file \n";

    # remove old ms24-str:
    if (-e "$startdir/$mailvarhash{PsName}.gmt") {
      unlink ("$startdir/$mailvarhash{PsName}.gmt")
	or warn "could not remove $startdir/$mailvarhash{PsName}.gmt \n";
    }
    
  # produce ms24-stripped 
    open (MS24, "< $Bin/$ms24") or warn "Could not open File $ms24 for $!";
    open (MS24TEMP, "> $mailvarhash{PsName}.gmt") or warn "Could not open ms24-temp for $!";

    if ($DEBUG) {
      print("Key ist $_ und Value: $mailvarhash{$_} \n") for (sort keys %mailvarhash);
    }


    while (<MS24>) {
      # don't iterate on comments or empty lines
      unless (  /^#*\s*$/ ) {
	# just iterate if there is a "set" somewhere in the line
	if (/^\s*set.*$/) {
	  foreach my $key (keys %mailvarhash) {
	    $_ =~ s/set $key(\s*) =(.*)/set $key = $mailvarhash{$key}/;
	  }
	}
      }
      print MS24TEMP $_;
    }
    close (MS24TEMP) or warn " Could not close $mailvarhash{PsName}.gmt for $!\n";
    close (MS24) or warn " Could not close $ms24 for $!\n";
    
    # existsjetzt ist der temporaere ms24-stripped entstanden mit den
    # ueberschriebenen Variablen
    @args = ('csh', "$startdir/$mailvarhash{PsName}.gmt");
    #system (@args) == 0 or warn "system @args failed: $!";
    $ms24_messages = `csh $startdir/$mailvarhash{PsName}.gmt`;

    # give an explicit .ps ending
    rename ("$startdir/$mailvarhash{PsName}", "$startdir/$mailvarhash{PsName}.ps")
	or warn "Cannot rename $startdir/$mailvarhash{PsName}\n";

    # convert the ps file to gif
    print ("Now converting to gif - depending on the size of the map this will take some time \n");


    # Converting the *.ps image to gif to show in the canvas
    @args = ("convert", "$mailvarhash{PsName}".'.ps', "$mailvarhash{PsName}.gif");
    # this is  working but very ugly output (badly scaled gif...)
    # and it puts the image in the lower half of the canvas
    # @args = ('gs', '-sDEVICE=ppmraw', "-sOutputFile=$startdir/$mailvarhash{PsName}.gif",'-q', '-dNOPAUSE', '-q', '-dBATCH',  "$mailvarhash{PsName}.ps", '-sPAPERSIZE=A4');

    system (@args) == 0 or warn "system @args failed: $!";
    
    # Changing to pdf if desired
#    if ($map_output_format_g eq 'pdf'){
#      @args = ('ps2pdf', "$mailvarhash{PsName}");
#      system (@args) == 0 or warn "could not convert to pdf for $! \n";
#    }

    # puts map into the canvas
    show_map("$mailvarhash{PsName}.gif");
    print "Converting is finished.\n";
    
}

# end of sub map_it

########################################
##    sub: my_map                     ##
########################################

sub my_map {
}
  

#########################################
#    sub Set_Range
#
#    gesetzte Var: 
#    c1_lat, c2_lat, 
#    c1_lon, c2_lon, 
#    ProjectionName
#
#########################################

sub Set_Range
  {
    # New Window to select the range of the map
    # test for existence is not working,
    # Declaration of variables

    my ($button_f, $range_f, $range_f2, $proj_f, );
    my ($wsm_logo, @var_a, %var_h, $apply_fr, @proj_a);
    
    if ( defined $range_w ) {
      $range_w -> deiconify();
      $range_w -> raise();
    } else {

      # Initialising the var
      @var_a = (qw/ c1_lat c2_lat c1_lon c2_lon ProjectionName MapShape /);
      $var_h{$_} = $mailvarhash{$_} for (@var_a);
      @proj_a = (['Mercator',                'Mercator'                    ],
		 ['Albers Conic Equal Area', 'Albers_Conic_Equal-Area'     ],
		 ['Lambert Conic Conformal', 'Lambert_Conic_Conformal'     ],
		 ['Lambert Azimuthal',       'Lambert_Azimuthal_Equal-Area'],
		 ['Orthographic',            'Orthographic'                ],
		 ['Mollweide',               'Mollweide'                   ],
		);

      # Creating the window
      $range_w = $mw -> Toplevel();
      $range_w -> title ("Range and Projection of Map");
      #####################################################
      #	Frames
      #####################################################

      $range_f  = $range_w -> Frame -> pack (-anchor => 'n');
      $range_f2 = $range_f -> Frame -> pack (-side => 'bottom'); # for bounded/rectangular
      $proj_f  = $range_w -> Frame ->pack;
      $button_f = $range_w -> Frame -> pack (-side => 'bottom', -anchor => 'e',);


      # Range:
      heading($range_f, "Range", 'n', 'n');
     
      # Range Entry Buttons
      $range_f -> LabEntry(-label   => "South",
			   -labelPack => [qw/ -side bottom -anchor w/],
			   -width => 5,		    
			   -textvariable => \$var_h{c1_lat},)
	-> pack (-side => 'bottom');
      $range_f -> LabEntry(-label   => "North",
			   -width => 5,		    
			   -labelPack => [qw/ -side top -anchor w/],
			   -textvariable => \$var_h{c2_lat},)
	-> pack (-side => 'top');
      $range_f -> LabEntry(-label   => "West",
			   -width => 5,		    
			   -labelPack => [qw/ -side left -anchor w/],
			   -textvariable => \$var_h{c1_lon},)
	-> pack (-side => 'left');
      $range_f -> LabEntry(-label   => "East",
			   -width => 5,		    
			   -labelPack => [qw/ -side right -anchor w/],
			   -textvariable => \$var_h{c2_lon},)
	-> pack (-side => 'right');

      # WSM Logo
      $range_f -> Photo('imggif', -file => $range_image);
      $wsm_logo = $range_f ->Label ('-image' => 'imggif')->pack();

      # MapShape:
      foreach (qw/bounded rectangular/) {
	$range_f2 -> Radiobutton( -text => $_,
				 -value => $_,
				 -pady => '2',
				 -variable => \$var_h{MapShape},
				) ->pack(-side => 'left', );
      }
      # Button: Whole Earth
      $range_f2 -> Button (-text => 'Whole Earth',
			  -command => sub {
			    my ($max_lat);
			    if ($var_h{ProjectionName} eq 'Mercator') {
			      $max_lat = 75;
			    }
			    else {$max_lat = 90; }
			    # we can't use eq c1,c2 lat for conical projections
			    # but that should be checked in check_range
			    $var_h{c1_lat} = -$max_lat;
			    $var_h{c2_lat} = $max_lat;
			    $var_h{c1_lon} = -180;
			    $var_h{c2_lon} = 180;
			  }) -> pack (-anchor => 'w');
      
			    


      ######################################
      #     Projections                   ##
      ######################################

      heading($proj_f, "Projection");

      foreach (@proj_a) {
	$proj_f -> Radiobutton(-text => @$_[0],
			       -value => @$_[1],
			       -variable => \$var_h{ProjectionName},
			      ) -> pack (-side => 'top', -anchor => 'w');
      }


      #######################################
      #    Buttons                         ##
      #######################################

      $button_f
	-> Button (-text  => "Ok",
		   -command => sub { &$apply_fr();
				     # not to good because
				     # even if an range error occurs we close
				     # the window nevertheless
				     $range_w -> withdraw;
				   }
		  ) -> pack (-side => 'right');
      $button_f
	-> Button (-text  => "Apply",
		   -command => $apply_fr = sub{
		     if(&check_range($var_h{c2_lat}, $var_h{c1_lat},
				     $var_h{c2_lon}, $var_h{c1_lon},
				     $var_h{ProjectionName} )
		       ){
		       # adjust the range in the overview map
		       # we have to be careful not to add over 90/180 degrees
		       # c1_lat = south
		       # c2_lat = north
		       # c1_lon = west
		       # c2_lon = east
		       my ($max_lat) = 75;
		       $mailvarhash{c1i_lat} = (($var_h{c1_lat} > -$max_lat) ?
			 $var_h{c1_lat} - 10  : -$max_lat);
		       $mailvarhash{c2i_lat} = (($var_h{c2_lat} < $max_lat) ?
			 $var_h{c2_lat} + 10  : $max_lat);
		       $mailvarhash{c1i_lon} = (($var_h{c1_lon} > -170) ?
			 $var_h{c1_lon} - 10  : -180);
		       $mailvarhash{c2i_lon} = (($var_h{c2_lon} < 170) ?
			 $var_h{c2_lon} + 10  : 180);
		       # if Proj: Lambert Azi, MapShape must be rectangular
		       if ($var_h{ProjectionName} eq
			   'Lambert_Azimuthal_Equal-Area'
			   and $var_h{MapShape} eq 'bounded'
			  ) {err_win ('The Lambert Azimuthal Equal Area is not supported with a bounded mapshape by GMT. Therefor the mapshape is changed to rectangular');
			     $var_h{MapShape} = 'rectangular';
			   }
		       $mailvarhash{$_} = $var_h{$_} for (@var_a);}
		     if ($DEBUG) {
		       foreach (sort keys %var_h) {
			 print("Key ist $_ und Value: $var_h{$_} \n");
		       }
		     }
		   }
		  )-> pack (-side => 'right');

      $button_f -> Button (-text  => "Cancel",
			  -command => sub {$range_w -> destroy; undef $range_w})
	->pack (-side => 'right');

      $proj_f -> Button (
	-text => "Change Defaults",
	-command => sub {proj_extra_var($var_h{ProjectionName})},
			  ) -> pack (-side => 'left', -anchor => 'w',);

	
    }				# end of else   
  }
# end of sub: Set_Range


#######################################################
##    sub proj_extra_var                             ##
##    parameter: $proj_name                          ##
##    sets var: lon_pro, lat_pro                     ##
##              stan1_pro, stan2_pro, CentralMerid   ##
#######################################################


sub proj_extra_var  {
  if (!Exists $proj_extra_var_w) {
  # Declaration of Variables
  my ($proj_center_f, $proj_button_f);
  my (@var_a, %var_h, %button_h, $key, $proj_name);
  
  # given $proj_name in @_
  # Initalisation
  $proj_name = @_;

  @var_a = (qw/lon_pro lat_pro stan1_pro stan2_pro CentralMerid/);
  foreach (@var_a) {$var_h{$_} = $mailvarhash{$_}  }

  %button_h = ('Longitude of Projection Center' => \$var_h{lon_pro},
	       'Latitude of Projection Center'  => \$var_h{lat_pro},
	       'Lower Standard Parallel'        => \$var_h{stan1_pro},
	       'Upper Standard Parallel'        => \$var_h{stan2_pro},
	       'Central Meridian for Mollweide' => \$var_h{CentralMerid},
	      );

  # Windows and Frames
  $proj_extra_var_w = $mw -> Toplevel();
  $proj_extra_var_w -> title ("Extra Parameter for the Projection");
  $proj_center_f = $proj_extra_var_w -> Frame -> pack (-anchor => 'w');
  $proj_button_f = $proj_extra_var_w -> Frame -> pack(
	-side => 'bottom', -anchor => 'e',);					 
   foreach (sort keys %button_h) {
     my $frame = $proj_center_f -> Frame -> pack (-anchor => 'w');
     $frame -> Entry (-width => 8, -textvariable => $button_h{$_})
       -> pack (-side => 'left');
     $frame -> Label (-text => $_) -> pack (-side => 'left');
   }

  # Default button
  $proj_center_f -> Button (-text => "Back to default",
			       -command => sub{
				 $var_h{$_} = 'default' for (@var_a);
			       }) -> pack (-anchor => 'w');

  # Buttons
  make_buttons($proj_extra_var_w, $proj_button_f, \%var_h);
}
  else {
    $proj_extra_var_w -> deiconify();
    $proj_extra_var_w -> raise();
  } 
    

}				# end of sub proj_extra_var

########################################################
##    sub: map_attributes                             ##
########################################################

sub map_attributes{
  # Declaration of Variables
  if (!Exists $map_attributes_w) {
    my ($general_info_f, $coastline_f, $pol_bo_f, $button_f);
  my (@var_a, %var_h, %coastline_h,);

  # Initalisation
  @var_a = (qw/ DataSet DataLevel DataSize Coastlines CoastPenSize
	    CoastPenColor
	    ContinentFill OceanFill Rivers RiverPenSize RiverPenColor
	    PoliticalBounds PolitBoPenSize PolitBoPenColor PlateBounds
	    PlaBoPenSiz PlaBoPenCol/); 
  foreach (@var_a) {$var_h{$_} = $mailvarhash{$_}; }
  %coastline_h = ( 'Ocean Fill Color'     => \$var_h{OceanFill},
		   'Continent Fill Color' => \$var_h{ContinentFill},
		   'Coastline Pen Size'   => \$var_h{CoastPenSize},
		   'Coastline Pen Color'  => \$var_h{CoastPenColor},
		 );

  # Window;
  $map_attributes_w = $mw
    -> Toplevel(-title => "Map Attributes");
  # Frames:

  $general_info_f = $map_attributes_w -> Frame() -> pack (-side => "left") ;
  extra_frame($map_attributes_w);
  $coastline_f = $map_attributes_w -> Frame()
      -> pack (-side => "left", -anchor => 'n') ;
  extra_frame($map_attributes_w);
  $pol_bo_f = $map_attributes_w -> Frame()
      -> pack (-side => 'top', -anchor => 'w') ;
  $button_f = $map_attributes_w -> Frame()
      -> pack (-side => 'bottom', -anchor => 'se') ;


  # General Info
  heading($general_info_f, "Coastline Resolution", 'w', 'n');
  foreach (qw/ full high intermediate low crude/){
      $general_info_f -> Radiobutton (-text => $_,
				      -value => substr($_, 0,1),
				      -variable => \$var_h{DataSet},
				      )
	  -> pack (-anchor => 'w');
  }
  $general_info_f -> Label (-text => "Minimum Lake/Island Size",
			    -pady => 5) -> pack (-anchor => 'w');

  $general_info_f -> LabEntry (-label => "km2",
			       -labelPack => [qw/-side right -anchor w/],
			       -width => 5,
			       -textvariable => \$var_h{DataSize})
      -> pack (-anchor => 'w');

  # Coastline Level
  heading ($general_info_f, "Coastline Level");
  foreach (qw/ 1 2 3 4/){
      $general_info_f -> Radiobutton (-text => $_,
				      -value => $_,
				      -variable => \$var_h{DataLevel},
				      ) -> pack (-anchor => 'w');
  }

  # Coastlines + Rivers (both in coastline frame)
  heading ($coastline_f, "Coastlines", 'w', 'n');
  yes_no($coastline_f, \$var_h{Coastlines});
  foreach (sort keys %coastline_h) {
    $coastline_f -> LabEntry (-label => $_,
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 10,
			     -textvariable => $coastline_h{$_}
			     ) -> pack (-anchor => 'w');
  }

  
  # starting with Rivers
  heading ($coastline_f, "Rivers and Lakes");
  yes_no($coastline_f, \$var_h{Rivers});
  $coastline_f -> LabEntry (-label => "Size",
			    -labelPack => [qw /-side right -anchor w/],
			    -width => '10',
			    -textvariable => \$var_h{RiverPenSize},
			    ) -> pack (-anchor => 'w');
  $coastline_f -> LabEntry (-label => "Color",
			    -labelPack => [qw /-side right -anchor w/],
			    -width => '10',
			    -textvariable => \$var_h{RiverPenColor},
			    ) -> pack (-anchor => 'w');

  # Political + Plate Boundaries
  heading ($pol_bo_f, "Political Boundaries", 'w', 'n');
  yes_no($pol_bo_f, \$var_h{PoliticalBounds});
  $pol_bo_f -> LabEntry (-label => "Size",
			    -labelPack => [qw /-side right -anchor w/],
			    -width => '10',
			    -textvariable => \$var_h{PolitBoPenSize},
			    ) -> pack (-anchor => 'w');
  $pol_bo_f -> LabEntry (-label => "Color",
			    -labelPack => [qw /-side right -anchor w/],
			    -width => '10',
			    -textvariable => \$var_h{PolitBoPenColor},
			    ) -> pack (-anchor => 'w');

  heading ($pol_bo_f, "Plate Boundaries");
  yes_no($pol_bo_f, \$var_h{PlateBounds});
  $pol_bo_f -> LabEntry (-label => "Size",
			    -labelPack => [qw /-side right -anchor w/],
			    -width => '10',
			    -textvariable => \$var_h{PlaBoPenSiz},
			    ) -> pack (-anchor => 'w');
  $pol_bo_f -> LabEntry (-label => "Color",
			    -labelPack => [qw /-side right -anchor w/],
			    -width => '10',
			    -textvariable => \$var_h{PlaBoPenCol},
			    ) -> pack (-anchor => 'w');
  

  # Button_f
  make_buttons($map_attributes_w, $button_f, \%var_h);
  }
  else {
      $map_attributes_w -> deiconify;
      $map_attributes_w -> raise;
   }

} #end of sub map_attributes

#################################################
## sub: topography                             ##
#################################################

sub topography{
  if (!Exists $topography_w) {
  
    # Declaration
    my ($main_f, $resolution_f, $contour_f, $scale_f,
	$button_f, $global_age_f);
    my (@var_a, %var_h, @scale_a, $apply_fr,);

    # Initalisation
    @var_a = (qw/ Topography TopoIllum TopoIllumAng
	      TopoIllumNorm  GridScale GridScaleOri
	      GridScaleLen GridScaleWid GridScaleX GridScaleY
	      GridScaleLab GridScaleSpac GridScaleFil
	      Contour ContourInterval ContourAnnot ContourPen
              /);
    # global age grid not included as i don't find the gridfile!
    # OtherGrid GridFile GridCptFile
    
    foreach (@var_a) { $var_h{$_} = $mailvarhash{$_} }
    @scale_a = (["Length ($measure_unit_h{$mailvarhash{MEASURE_UNIT}})",
		             \$var_h{GridScaleLen}],
		["Width ($measure_unit_h{$mailvarhash{MEASURE_UNIT}})",
		             \$var_h{GridScaleWid}],
		['x Position',          \$var_h{GridScaleX}],
		['y Position',          \$var_h{GridScaleY}],
		['Spacing',             \$var_h{GridScaleSpac}],
		['Color Clearance Rectangle', \$var_h{GridScaleFil}],
		);
      
    
    # Window and Frames:

    $topography_w = $mw -> Toplevel (-title => 'Topography');
    $main_f = $topography_w -> Frame -> pack;
    $resolution_f = $topography_w -> Frame ->
      pack (-side => 'left', -anchor => 'nw');
    $contour_f = $resolution_f -> Frame -> pack ( -anchor => 'w');
    $global_age_f = $resolution_f -> Frame -> pack (-anchor => 'w');
    extra_frame ($topography_w);
    $scale_f = $topography_w -> Frame -> pack ();
    $button_f = $topography_w -> Frame
      -> pack (-side => 'bottom', -anchor => 'e');

    yes_no ($main_f, \$var_h{Topography}, 'n');

    # resolution_f
    heading ($resolution_f, 'Illumination');
    yes_no ($resolution_f, \$var_h{TopoIllum});
    $resolution_f -> LabEntry (-label => 'Direction of Light',
			       -labelPack => [qw/ -side right -anchor w/],
			       -width => 5,
			       -textvariable => \$var_h{TopoIllumAng},
			       ) -> pack (-anchor => 'w');
    $resolution_f -> LabEntry (-label => 'Normalisation Factor',
			       -labelPack => [qw/ -side right -anchor w/],
			       -width => 5,
			       -textvariable => \$var_h{TopoIllumNorm},
			       ) -> pack (-anchor => 'w');

    # Contours
    heading ($contour_f, 'Contours');
    yes_no ($contour_f, \$var_h{Contour});
    # [...] returns a ref to an anomynous array, @{[...]} takes this ref
    foreach (@{[['Contour Interval', 5,    \$var_h{ContourInterval}],
		['Annotation Interval',5,    \$var_h{ContourAnnot}],
		['Pen Attributes',     10,   \$var_h{ContourPen}],
	       ]})
      { $contour_f -> LabEntry (-label => @$_[0],
			       -labelPack => [qw/ -side right -anchor w/],
			       -width => @$_[1],
			       -textvariable => @$_[2],
			      ) -> pack (-anchor => 'w');
     }
    

    # Scale
    heading ($scale_f, 'Scale');
    yes_no ($scale_f, \$var_h{GridScale});
    $scale_f -> Label (-text => 'Orientation') ->pack (-anchor => 'w');

    foreach (qw/ horizontal vertical/){
	$scale_f -> Radiobutton (-text => $_,
				  -value => substr($_, 0, 1),
				  -variable => \$var_h{GridScaleOri},
				 ) -> pack (-anchor => 'w');
    }

    # Topo Label must have a greater width, therefor not in loop
    $scale_f -> LabEntry (-label => 'Label',
			  -labelPack => [qw/ -side right -anchor w/],
			  -width => 12,
			  -textvariable =>  \$var_h{GridScaleLab},
			 ) -> pack (-anchor => 'w');
    
    foreach (@scale_a) {
      $scale_f -> LabEntry (-label => @$_[0],
			    -labelPack => [qw/ -side right -anchor w/],
			    -width => 6,
			    -textvariable => @$_[1],
			   ) -> pack (-anchor => 'w');
    }
    
    # Buttons
    make_buttons($topography_w, $button_f, \%var_h);
  }
  else {
    $topography_w -> deiconify;
    $topography_w -> raise;
  }
			 
} # end of topography



##################################################
##   sub: Map Title                            ###
##################################################

sub map_title{
  if (!Exists $map_title_w ) {
  
    my ( $main_f, $button_f);
    my (@var_a, %var_h);

    if (! defined $map_title_w){
	# Main Window and Frames
	$map_title_w = $mw -> Toplevel (-title => 'Map Title');
	$main_f = $map_title_w -> Frame -> pack;
	$button_f = $map_title_w -> Frame
	  -> pack (-side => 'bottom', -anchor => 'e');

	# Initialising the Variables
	@var_a = (qw/ PlotMapTitle MapTitle MapTitleFontS
		  MapTitleFontC MapTitleLoc /);
	$var_h{$_} = $mailvarhash{$_} for (@var_a);

	# yes/no
	yes_no ($main_f, \$var_h{PlotMapTitle}, 'n');
	$main_f -> Label (-text => '') -> pack;

	$main_f -> Entry (-textvariable => \$var_h{MapTitle}, -width => 30,)
	    -> pack (-anchor => 'w');
	$main_f -> LabEntry (-label => "Font Size",
			  -width => 10,
			  -labelPack => [qw/ -side right -anchor w/],
			  -textvariable => \$var_h{MapTitleFontS})
	    -> pack (-anchor => 'w');
	$main_f -> LabEntry (-label => "Font Color",
			  -width => 10,
			  -labelPack => [qw/ -side right -anchor w/],
			  -textvariable => \$var_h{MapTitleFontC})
	    -> pack (-anchor => 'w');
	heading ($main_f, "Position");

	$main_f -> Radiobutton (-text => 'Centered',
				-value => 'above',
				-variable => \$var_h{MapTitleLoc},
				) -> pack (-anchor => 'w');
	$main_f -> Radiobutton (-text => 'Upper Left',
				-value => 'default',
				-variable => \$var_h{MapTitleLoc},
				) -> pack (-anchor => 'w');

	$main_f -> LabEntry (-label => "x/y Position ($measure_unit_h{$mailvarhash{MEASURE_UNIT}})",
			  -width => 10,
			  -labelPack => [qw/ -side right -anchor w/],
			  -textvariable => \$var_h{MapTitleLoc})
	    -> pack (-anchor => 'w');
	
	# Buttons
	make_buttons($map_title_w, $button_f, \%var_h);
    }
  }
    else {
	$map_title_w -> deiconify();
	$map_title_w -> raise();
    }
	

} # end of map_title

###################################################
##   sub: Map Info                               ##
###################################################
sub map_info{
  if (!Exists $map_info_w) {
  
    my ($main_f, $plot_info_f, $button_f);
    my (@var_a, %var_h,);
    my ($gridlines, $gridannot);

    # Initialising the Variables:
    @var_a = (qw/ GridLinesLon GridLinesLat GridAnnotLon GridAnnotLat
	      SimpleMapScale ScaleLength ScalePosition PlotInfoString /);
    foreach (@var_a) {$var_h{$_} = $mailvarhash{$_} }
    ($gridlines, $gridannot) = ('y', 'y');
    

    $map_info_w = $mw -> Toplevel (-title => "Map Information");
    # Frames
    $main_f = $map_info_w -> Frame -> pack;
    $plot_info_f = $main_f -> Frame ->
      pack (-side => 'bottom', -anchor => 'w');
    $button_f = $map_info_w -> Frame ->
      pack (-side => 'bottom', -anchor => 'e');

    heading ($main_f, "Gridlines", 'w', 'n');
    yes_no ($main_f, \$gridlines);
    $main_f -> LabEntry (-label => 'Lat Interval',
			 -width => 10,
			 -labelPack =>  [qw/ -side right -anchor w/],
			 -textvariable => \$var_h{GridLinesLat},
			 ) -> pack (-anchor => 'w');
    $main_f -> LabEntry (-label => 'Lon Interval',
			 -width => 10,
			 -labelPack =>  [qw/ -side right -anchor w/],
			 -textvariable => \$var_h{GridLinesLon},
			 ) -> pack (-anchor => 'w');

    heading($main_f, "Annotation");
    yes_no ($main_f, \$gridannot);
    $main_f -> LabEntry (-label => 'Lat Annotation Interval',
			 -labelPack =>  [qw/ -side right -anchor w/],
			 -width => 10,
			 -textvariable => \$var_h{GridAnnotLat},
			 ) -> pack (-anchor => 'w');
    $main_f -> LabEntry (-label => 'Lon Annotation Interval',
			 -labelPack =>  [qw/ -side right -anchor w/],
			 -width => 10,
			 -textvariable => \$var_h{GridAnnotLon},
			 ) -> pack (-anchor => 'w');

    heading ($main_f, "Map Scale");
    yes_no ($main_f, \$var_h{SimpleMapScale});
    $main_f -> LabEntry (-label => 'Scale Length (km)',
			 -labelPack =>  [qw/ -side right -anchor w/],
			 -width => 10,
			 -textvariable => \$var_h{ScaleLength},
			 ) -> pack (-anchor => 'w');
    $main_f -> LabEntry (-label => 'Scale Position (lon/lat)',
			 -labelPack =>  [qw/ -side right -anchor w/],
			 -textvariable => \$var_h{ScalePosition},
			 -width => 10,
			 ) -> pack (-anchor => 'w');
    heading ($main_f, "Plot Info String");
    foreach (qw/yes short no/){
	$plot_info_f -> Radiobutton (-text => $_,
				     -value => substr ($_, 0, 1),
				     -variable => \$var_h{PlotInfoString},
				     ) -> pack (-side => 'left');
    }

    # Buttons:
    $plot_info_f -> Label (-text => '') -> pack;
    $button_f
	-> Button (-text => "Ok",
		   -command => sub{
		       if ($gridlines eq 'n'){$var_h{GridLinesLon} = 0;
					      $var_h{GridLinesLat} = 0;}
		       if ($gridannot eq 'n'){$var_h{GridAnnotLon} = 0;
					      $var_h{GridAnnotLat} = 0;}
		       foreach (keys %var_h)
		       { $mailvarhash{$_} = $var_h{$_} }
		       $map_info_w -> withdraw;
		   }) -> pack (-side => 'right');
    $button_f
	-> Button (-text => "Apply",
		   -command => sub{
		       if ($gridlines eq 'n'){$var_h{GridLinesLon} = 0;
					      $var_h{GridLinesLat} = 0;}
		       if ($gridannot eq 'n'){$var_h{GridAnnotLon} = 0;
					      $var_h{GridAnnotLat} = 0;}
		       foreach (keys %var_h)
		       { $mailvarhash{$_} = $var_h{$_} }
		   }) -> pack (-side => 'right');
    $button_f -> Button (-text => "Cancel",
			 -command => sub {$map_info_w -> destroy;})
	-> pack (-side => 'right');
  }
  else {
    $map_info_w -> deiconify;
    $map_info_w -> raise;
  }


	

} # end of map_info



###################################################
##   sub: Overview Map                           ##
###################################################

sub overview_map{
  # Declaration of Variables
  if (!Exists $overview_map_w) {
  
  my ($range_f, $lower_f, $position_f, $pol_bo_f, $button_f);
  my ($key, %position_hash, @var_a, %var_h);

  # Initialisation of Variables
  @var_a = (qw/ Insert PosInsert InsertWidth ShowPolitInsert
	    ContinFillInsert OceanFillInsert CoastlineInsert
	    MapColorInsert PolitBoundInsert
	    c1i_lon c2i_lon c1i_lat c2i_lat /);
  foreach (@var_a) {$var_h{$_} = $mailvarhash{$_} }

  %position_hash = ('Lower Left'  => 'll',
		       'Lower Right' => 'lr',
		       'Upper Left'  => 'ul',
		       'Upper Right'  => 'ur',);
  

  #  Map Window:
  $overview_map_w = $mw -> Toplevel (-title => "Overview Map");
  # Frames:
  $range_f = $overview_map_w -> Frame -> pack (-anchor => 'n');
  $lower_f = $overview_map_w -> Frame -> pack (-side => 'bottom');
  $position_f = $lower_f -> Frame ()
    -> pack (-side => 'left', -anchor => 'n');
  extra_frame($lower_f);
  $pol_bo_f = $lower_f -> Frame
    -> pack (-side => 'top', -anchor => 'w');
  $button_f = $lower_f -> Frame
    -> pack (-side => 'bottom', -anchor => 'e');

  # Range of Overview Map
  # yes/no via sub
  yes_no($range_f, \$var_h{Insert}, 'n');
  heading ($range_f, "Range", 'n');

  $range_f -> LabEntry (-label => 'South',
 			  -width => 5,
 			  -labelPack => [qw / -side bottom -anchor w/],
 			  -textvariable => \$var_h{c1i_lat},
 			  ) -> pack (-side => 'bottom');
  $range_f -> LabEntry (-label => 'North', 
 			  -width => 5,
 			  -labelPack => [qw / -side top -anchor w/],
 			  -textvariable => \$var_h{c2i_lat},
 			  ) -> pack (-side => 'top');
  $range_f -> LabEntry (-label => 'West',
 			  -width => 5,
 			  -labelPack => [qw / -side left -anchor w/],
 			  -textvariable => \$var_h{c1i_lon},
 			  ) -> pack (-side => 'left');
  $range_f -> LabEntry (-label => 'East',
 			  -width => 5,
 			  -labelPack => [qw / -side right -anchor w/],
 			  -textvariable => \$var_h{c2i_lon},
 			  ) -> pack (-side => 'right');
  $range_f -> Photo('imggif', -file => $range_image);
  $range_f ->Label ('-image' => 'imggif')->pack();

  # position
  heading ($position_f, "Position");
  foreach $key (sort keys %position_hash){
    $position_f -> Radiobutton(-text  => "$key",
			       -value => $position_hash{$key},
			       -variable => \$var_h{PosInsert},
			       ) -> pack (-anchor => 'w');
  }
  

  heading ($position_f, "Width");
  $position_f -> LabEntry (-label => "in $measure_unit_h{$mailvarhash{MEASURE_UNIT}}",
			   -width => '8',
			   -textvariable => \$var_h{InsertWidth},
			   -labelPack => [qw / -side right -anchor w/],
			   )-> pack (-anchor => 'w');
  $position_f -> Button(-text => 'Default',
			-command => sub {$var_h{InsertWidth} = 'default'})
    -> pack (-anchor => 'w');

  # Other Info
  heading ($pol_bo_f, "Overview Map Attributes");
  
  $pol_bo_f -> Label (-text => 'Political Boundaries',) -> pack (-anchor => 'w');
  # y/n Radio
  yes_no($pol_bo_f, \$var_h{ShowPolitInsert});
  # Entries
  $pol_bo_f -> LabEntry (-label => 'Pen Attributes',
			   -width => '10',
			   -textvariable => \$var_h{PolitBoundInsert},
			   -labelPack => [qw / -side right -anchor w/],
			   )-> pack (-anchor => 'w');

  $pol_bo_f -> LabEntry (-label => 'Continent Color',
			   -width => '10',
			   -textvariable => \$var_h{ContinFillInsert},
			   -labelPack => [qw / -side right -anchor w/],
			   )-> pack (-anchor => 'w');

  $pol_bo_f -> LabEntry (-label => 'Ocean Color',
			   -width => '10',
			   -textvariable => \$var_h{OceanFillInsert},
			   -labelPack => [qw / -side right -anchor w/],
			   )-> pack (-anchor => 'w');

  $pol_bo_f -> LabEntry (-label => 'Coastlines',
			   -width => '10',
			   -textvariable => \$var_h{CoastlineInsert},
			   -labelPack => [qw / -side right -anchor w/],
			   )-> pack (-anchor => 'w');

  $pol_bo_f -> LabEntry (-label => 'Map Colors',
			   -width => '10',
			   -textvariable => \$var_h{MapColorInsert},
			   -labelPack => [qw / -side right -anchor w/],
			   )-> pack (-anchor => 'w');

  # and an empty field to make some space to the buttons
  $pol_bo_f -> Label (-text => '') -> pack (-anchor => 'w');
  

  # Buttons
  $button_f ->
    Button (-text => "Ok",
	    -command => sub{
	      if (check_range($var_h{c2i_lat}, $var_h{c1i_lat},
			       $var_h{c2i_lon}, $var_h{c1i_lon}, 'Mercator')
		 )
	      {
		  foreach (keys %var_h){ $mailvarhash{$_} = $var_h{$_} }
		  $overview_map_w -> withdraw;
	      } # end of if 
	  }) -> pack(-side => 'right');
  $button_f ->
    Button (-text => "Apply",
	    -command => sub{
	      if (check_range($var_h{c2i_lat}, $var_h{c1i_lat},
			       $var_h{c2i_lon}, $var_h{c1i_lon}, 'Mercator')
		 ){foreach (keys %var_h){ $mailvarhash{$_} = $var_h{$_} } } 
	  }) -> pack(-side => 'right');
  $button_f -> Button (-text => "Cancel",
		       -command => sub {$overview_map_w -> destroy;})
    -> pack(-side => 'right');
}
  else {
    $overview_map_w -> deiconify;
    $overview_map_w -> raise;
  }


  
} # end of sub: overview_map


###############################################################
#        subs from Stress Data Menu                         ###
###############################################################

###############################################
#  sub stress_data1                           
#  sets vars: Stress1Type (FMS, BO..)         
#             Stress1Qual, Stress1Depth       
#  note that Stress1Type,Qual are set to user_defined
#  in the initalisation of mailvarhash
#  and if Depth All is selected, the Entries DepthTop, Bottom
#  are not used
#  
###############################################

sub stress_data1{
  if (!Exists $stress_data1_w) {
  
  # Declaration of Variables
  my ($quality_f, $depth_f, $regime_f, $type_f, $button_f,
      $data_default_button_f,
      $fms_type_f, $pbe_warn_text_f, $pbe_warn_button_f,
      $pbe_text_f, $pbe_all_f, $pbe_all_dist_f,
      $pbe_regime_f, $pbe_regime_dist_f, $pbe_wsm_f);
  my (%typehash, %type_cb, %quality_hash, );
  my (@type_a, @var_a, %var_h,);
  my ($element_ref, $key, $regime_aref, $type_aref, $fms_type_aref,
      @pbe_text, $pbe_all_aref, $pbe_all_dist_aref,
      $pbe_regime_aref, $pbe_regime_dist_aref, $pbe_wsm_aref,);
##$fms_type_f, $pbe_text_f, $pbe_all_f, $pbe_all_dist_f,
##      $pbe_regime_f, $pbe_regime_dist_f, $pbe_wsm_f

  # Initialisation
  @var_a = (qw/ S1TypeFMS S1TypeFMA S1TypeFMF S1TypeBO S1TypeDIF S1TypeBS S1TypeOC S1TypeHF S1TypeGI
                S1_Regime_TF S1_Regime_TS S1_Regime_SS
                S1_Regime_NS S1_Regime_NF S1_Regime_U
                S1_CTF_exclude_all S1_CTF_exclude_all_distance
                S1_CTF_exclude_SS S1_CTF_exclude_SS_distance
		S1_CTF_exclude_PBE_events
                S1_CRB_exclude_all S1_CRB_exclude_all_distance
                S1_CRB_exclude_NF S1_CRB_exclude_NF_distance
		S1_CRB_exclude_PBE_events
                S1_CCB_exclude_all S1_CCB_exclude_all_distance
                S1_CCB_exclude_TF S1_CCB_exclude_TF_distance
		S1_CCB_exclude_PBE_events
                S1_OTF_exclude_all S1_OTF_exclude_all_distance
                S1_OTF_exclude_SS S1_OTF_exclude_SS_distance
		S1_OTF_exclude_PBE_events
                S1_OSR_exclude_all S1_OSR_exclude_all_distance
                S1_OSR_exclude_NF S1_OSR_exclude_NF_distance
		S1_OSR_exclude_PBE_events
                S1_OCB_exclude_all S1_OCB_exclude_all_distance
                S1_OCB_exclude_TF S1_OCB_exclude_TF_distance
		S1_OCB_exclude_PBE_events
                S1_SUB_exclude_all S1_SUB_exclude_all_distance
                S1_SUB_exclude_TF S1_SUB_exclude_TF_distance
		S1_SUB_exclude_PBE_events
                S1QualA S1QualB S1QualC S1QualD S1QualE
                Stress1Depth S1DepthTop S1DepthBot
	    /);
  $var_h{$_} = $mailvarhash{$_} for (@var_a);

  %quality_hash =('A' => \$var_h{'S1QualA'},
		  'B' => \$var_h{'S1QualB'},
		  'C' => \$var_h{'S1QualC'},
		  'D' => \$var_h{'S1QualD'},
		  'E  (only' => \$var_h{'S1QualE'},
		  );

  $regime_aref = [['TF (Thrust Faulting)',      \$var_h{S1_Regime_TF}],
       	          ['TS (TF with SS component)', \$var_h{S1_Regime_TS}],
       	          ['SS (Strike-Slip)',          \$var_h{S1_Regime_SS}],
       	          ['NS (NF with SS component)', \$var_h{S1_Regime_NS}],
       	          ['NF (Normal Faulting)',      \$var_h{S1_Regime_NF}],
       	          ['U (Unknown)',               \$var_h{S1_Regime_U}],
	          ];

  $type_aref = [['Focal Mechanism, Average (FMA)', \$var_h{'S1TypeFMA'}],
                ['Focal Mechanism, Formal Inversion (FMF)', \$var_h{'S1TypeFMF'}],
		['Borehole Breakout (BO)' ,        \$var_h{'S1TypeBO'}],
		['Drilling Induced Fractures (DIF)' ,  \$var_h{'S1TypeDIF'}],
		['Borehole Slotter (BS)' ,          \$var_h{'S1TypeBS'}],
		['Overcoring (OC)' ,                \$var_h{'S1TypeOC'}],
		['Hydraulic Fracture (HF)' ,            \$var_h{'S1TypeHF'}],
		['Geological Indicators (GI)' ,     \$var_h{'S1TypeGI'}],
		];

  $fms_type_aref = [['Focal Mechanism, Single (FMS)', \$var_h{S1TypeFMS}],
         	    ];

  @pbe_text = ('CTF (Continental Transform Fault)',
               'CRB (Continental Rift Boundary)',
               'CCB (Continental Collision Boundary)',
               'OTF (Oceanic Transform Fault)',
               'OSR (Oceanic Spreading Ridge)',
               'OCB (Oceanic Collision Boundary)',
               'SUB (Subduction zone)',
               );

  $pbe_all_aref = [['all events <', \$var_h{S1_CTF_exclude_all}],
       	           ['all events <', \$var_h{S1_CRB_exclude_all}],
       	           ['all events <', \$var_h{S1_CCB_exclude_all}],
       	           ['all events <', \$var_h{S1_OTF_exclude_all}],
       	           ['all events <', \$var_h{S1_OSR_exclude_all}],
       	           ['all events <', \$var_h{S1_OCB_exclude_all}],
       	           ['all events <', \$var_h{S1_SUB_exclude_all}],
	           ];

  $pbe_all_dist_aref = [['km', \$var_h{S1_CTF_exclude_all_distance}],
       	                ['km', \$var_h{S1_CRB_exclude_all_distance}],
       	                ['km', \$var_h{S1_CCB_exclude_all_distance}],
       	                ['km', \$var_h{S1_OTF_exclude_all_distance}],
       	                ['km', \$var_h{S1_OSR_exclude_all_distance}],
       	                ['km', \$var_h{S1_OCB_exclude_all_distance}],
       	                ['km', \$var_h{S1_SUB_exclude_all_distance}],
	                ];

  $pbe_regime_aref = [['SS events <', \$var_h{S1_CTF_exclude_SS}],
       	              ['NF events <', \$var_h{S1_CRB_exclude_NF}],
       	              ['TF events <', \$var_h{S1_CCB_exclude_TF}],
       	              ['SS events <', \$var_h{S1_OTF_exclude_SS}],
       	              ['NF events <', \$var_h{S1_OSR_exclude_NF}],
       	              ['TF events <', \$var_h{S1_OCB_exclude_TF}],
       	              ['TF events <', \$var_h{S1_SUB_exclude_TF}],
	              ];

  $pbe_regime_dist_aref = [['km', \$var_h{S1_CTF_exclude_SS_distance}],
       	                   ['km', \$var_h{S1_CRB_exclude_NF_distance}],
       	                   ['km', \$var_h{S1_CCB_exclude_TF_distance}],
       	                   ['km', \$var_h{S1_OTF_exclude_SS_distance}],
       	                   ['km', \$var_h{S1_OSR_exclude_NF_distance}],
       	                   ['km', \$var_h{S1_OCB_exclude_TF_distance}],
       	                   ['km', \$var_h{S1_SUB_exclude_TF_distance}],
	                   ];

  $pbe_wsm_aref = [['PBE events',
                        \$var_h{S1_CTF_exclude_PBE_events}],
       	           ['PBE events',
                        \$var_h{S1_CRB_exclude_PBE_events}],
       	           ['PBE events',
                        \$var_h{S1_CCB_exclude_PBE_events}],
       	           ['PBE events',
                        \$var_h{S1_OTF_exclude_PBE_events}],
       	           ['PBE events',
                        \$var_h{S1_OSR_exclude_PBE_events}],
       	           ['PBE events',
                        \$var_h{S1_OCB_exclude_PBE_events}],
       	           ['PBE events',
                        \$var_h{S1_SUB_exclude_PBE_events}],
	           ];


  # Window and Frames
  $stress_data1_w = $mw -> Toplevel(-title => "Select WSM Stress Data",
                                    -width => 790, -height => 520);
  $quality_f = $stress_data1_w -> Frame() -> place (-x=> 10, -y=> 10);
  $depth_f = $stress_data1_w -> Frame() -> place (-x=>100, -y=> 10);
  $regime_f = $stress_data1_w -> Frame() -> place (-x=>230, -y=> 10);
  $type_f = $stress_data1_w -> Frame() -> place (-x=>450, -y=> 10);
  $fms_type_f = $stress_data1_w -> Frame() -> place (-x=> 30, -y=>220);
  $pbe_warn_text_f = $stress_data1_w -> Frame() -> place (-x=>365, -y=>239);
  $pbe_warn_button_f = $stress_data1_w -> Frame() -> place (-x=>700, -y=>235);
  $pbe_text_f = $stress_data1_w -> Frame() -> place (-x=> 30, -y=>270);
  $pbe_all_f = $stress_data1_w -> Frame() -> place (-x=>280, -y=>270);
  $pbe_all_dist_f = $stress_data1_w -> Frame() -> place (-x=>380, -y=>270);
  $pbe_regime_f = $stress_data1_w -> Frame() -> place (-x=>470, -y=>270);
  $pbe_regime_dist_f = $stress_data1_w -> Frame() -> place (-x=>570, -y=>270);
  $pbe_wsm_f = $stress_data1_w -> Frame() -> place (-x=>660, -y=>270);
  ##    -> pack (-side => 'top', -anchor => 'w');
  ##  extra_frame ($stress_data1_w);
  $data_default_button_f = $stress_data1_w -> Frame() -> place (-x=>370, -y=>480);
  $button_f = $stress_data1_w -> Frame() -> place (-x=>570, -y=>480);

  # Types
  heading($type_f, "Type", 'w', 'n');
  # $type_aref is a 2dim array
   foreach $element_ref (@$type_aref){
       $type_f -> Checkbutton (-text => @$element_ref[0],
 			      -onvalue => 'y',
 			      -offvalue => 'n',
 			      -variable => @$element_ref[1],      
 			      ) -> pack (-anchor => 'w');
   }
  heading($fms_type_f, "FMS type events", 'w', 'n');
  # $fms_type_aref is a 2dim array
   foreach $element_ref (@$fms_type_aref){
       $fms_type_f -> Checkbutton (-text => @$element_ref[0],
 			           -onvalue => 'y',
 			           -offvalue => 'n',
 			           -variable => @$element_ref[1],      
 			          ) -> pack (-anchor => 'w');
   }

  # Regimes
  heading($regime_f, "Regime", 'w', 'n');
  # $regime_aref is a 2dim array
   foreach $element_ref (@$regime_aref){
       $regime_f -> Checkbutton (-text => @$element_ref[0],
 	      		         -onvalue => 'y',
 	      		         -offvalue => 'n',
 	      		         -variable => @$element_ref[1],      
 			        ) -> pack (-anchor => 'w');
   }

  # FMS type options
  $pbe_warn_text_f -> Label (-text => 'Before changing the following settings, please read the ',
                             -foreground => 'red',
		            ) -> pack (-side => 'left');
  $pbe_warn_button_f -> Button (-text => 'Manual!',
		                -command => \&open_help,
		               ) -> pack (-side => 'left');
  col_heading($pbe_text_f, " Plate Boundary Type", 'w');
  # $pbe_text is a 1dim array
   foreach $element_ref (@pbe_text){
       $pbe_text_f -> Label (-text => $element_ref,
                             -pady => 2,
 			    ) -> pack (-anchor => 'w');
   }
  col_heading_red($pbe_all_f, "exclude", 'w');
  # $pbe_all_aref is a 2dim array
   foreach $element_ref (@$pbe_all_aref){
       $pbe_all_f -> Checkbutton (-text => @$element_ref[0],
                                  -onvalue => 'y',
                                  -offvalue => 'n',
                                  -variable => @$element_ref[1],      
                                 ) -> pack (-anchor => 'w');
   }
  col_heading($pbe_all_dist_f, "distance", 'w');
  # $pbe_all_dist_aref is a 2dim array
   foreach $element_ref (@$pbe_all_dist_aref){
       $pbe_all_dist_f -> LabEntry (-label => @$element_ref[0],
                                    -width => 5,
                           -labelPack => [qw /-side right -anchor w/],
                                    -textvariable => @$element_ref[1],
                                   ) -> pack (-anchor => 'w');
   }
  col_heading_red($pbe_regime_f, "exclude", 'w');
  # $pbe_regime_aref is a 2dim array
   foreach $element_ref (@$pbe_regime_aref){
       $pbe_regime_f -> Checkbutton (-text => @$element_ref[0],
                                     -onvalue => 'y',
                                     -offvalue => 'n',
                                     -variable => @$element_ref[1],      
                                    ) -> pack (-anchor => 'w');
   }
  col_heading($pbe_regime_dist_f, "distance", 'w');
  # $pbe_regime_dist_aref is a 2dim array
   foreach $element_ref (@$pbe_regime_dist_aref){
       $pbe_regime_dist_f -> LabEntry (-label => @$element_ref[0],
                                    -width => 5,
                           -labelPack => [qw /-side right -anchor w/],
                                    -textvariable => @$element_ref[1],
                                   ) -> pack (-anchor => 'w');
   }
  col_heading_red($pbe_wsm_f, "exclude", 'w');
  # $pbe_wsm_aref is a 2dim array
   foreach $element_ref (@$pbe_wsm_aref){
       $pbe_wsm_f -> Checkbutton (-text => @$element_ref[0],
                                  -onvalue => 'y',
                                  -offvalue => 'n',
                                  -variable => @$element_ref[1],      
                                 ) -> pack (-anchor => 'w');
   }
  
  # Qualities
  heading ($quality_f, "Quality", 'w', 'n');
  foreach $key (sort keys %quality_hash){
    $quality_f -> Checkbutton (-text => $key,
			       -onvalue => 'y',
			       -offvalue => 'n',
			       -variable => $quality_hash{$key},
			       ) -> pack(-anchor => 'w');
  }
  $quality_f -> Label (-text => '     location)',
		            ) -> pack (-side => 'right');

  # Depth
  heading ($depth_f, "Depth", 'w', 'n');
  foreach (qw/all user_defined/) {
  $depth_f -> Radiobutton (-text => $_,
			   -variable => \$var_h{Stress1Depth},
			   -value => $_,
			   ) -> pack (-side => 'top', -anchor => 'w');
  }
  
  $depth_f -> LabEntry (-label => "From",
			-width => 5,
			-labelPack => [qw /-side left -anchor w/],
			-textvariable => \$var_h{S1DepthTop},
		       ) -> pack (-anchor => 'w');
  $depth_f -> LabEntry (-label => "To    ", # some spaces added, so that the Entries align
			-width => 5,
			-labelPack => [qw /-side left -anchor w/],
			-textvariable => \$var_h{S1DepthBot},
		       ) -> pack (-anchor => 'w');
  $depth_f -> Label (-text => '         [km]',
		            ) -> pack (-side => 'left');

  # Buttons:
  make_data_default_button($stress_data1_w, $data_default_button_f, \%var_h);
  make_buttons($stress_data1_w, $button_f, \%var_h);
}
  else {
    $stress_data1_w -> deiconify;
    $stress_data1_w -> raise;
  }

} # end of sub stress_data1

##########################################################
##   sub symbols_stress1                               ###
##########################################################

sub symbols_stress1{
  if (!Exists $symbols_stress1_w) {
  
    my ($size_f, $length_f, $color_f,
	$outline_f, $sitecode_f, $button_f);
    my ($key, @var_a, %var_h, $string, @size_a, @color_a, $line_ar);
    my (%size_hash, %length_hash, %color_hash, %outline_hash);

    # Initalisation
    @var_a = (qw/ Stress1DataSize Stress1DataColor Stress1DataLen Stress1DataT
	      S1DataQASize S1DataQBSize S1DataQCSize S1DataQDSize S1DataQESize
	      S1DataQALen S1DataQBLen S1DataQCLen S1DataQDLen S1DataQELen
	      S1DataTFColor S1DataSSColor S1DataNFColor S1DataUColor
	      S1QualAT S1QualBT S1QualCT S1QualDT S1QualET
	      Stress1SC Stress1SCCol Stress1SCFontSiz /);
    foreach (@var_a){ $var_h{$_} = $mailvarhash{$_} }

    %size_hash = ('Quality A' => \$var_h{'S1DataQASize'},
		  'Quality B' => \$var_h{'S1DataQBSize'},
		  'Quality C' => \$var_h{'S1DataQCSize'},
		  'Quality D' => \$var_h{'S1DataQDSize'},
		  'Quality E' => \$var_h{'S1DataQESize'},
		  );
    %length_hash = ('Quality A' => \$var_h{'S1DataQALen'},
		    'Quality B' => \$var_h{'S1DataQBLen'},
		    'Quality C' => \$var_h{'S1DataQCLen'},
		    'Quality D' => \$var_h{'S1DataQDLen'},
		    'Quality E' => \$var_h{'S1DataQELen'},
		    );

    %color_hash = ('TF' => \$var_h{'S1DataTFColor'},
		    'SS' => \$var_h{'S1DataSSColor'},
		    'NF' => \$var_h{'S1DataNFColor'},
		    'U' => \$var_h{'S1DataUColor'},
		    );
    %outline_hash = ('Quality A' => \$var_h{'S1QualAT'},
		    'Quality B' => \$var_h{'S1QualBT'},
		    'Quality C' => \$var_h{'S1QualCT'},
		    'Quality D' => \$var_h{'S1QualDT'},
		    'Quality E' => \$var_h{'S1QualET'},
		    );
    @size_a = (['large',       'large'],
	       ['middle',      'middle'],
	       ['small',       'small'],
	       ['tiny',        'tiny'],
	       ['very tiny',   'verytiny'],
	       [$user_defined, 'user_defined'],
	      );
    @color_a = (['default',     'default'],
	       ['black',        'black'],
	       [$user_defined,  'user_defined'],);
    
    # Window and frames
    $symbols_stress1_w = $mw -> Toplevel (-title => 'WSM Stress Symbols');
     foreach ($size_f, $length_f, $color_f){
 	$_ = $symbols_stress1_w -> Frame () ->
 	    pack (-side => 'left', -anchor => 'nw');
	extra_frame ($symbols_stress1_w);
     }
    $outline_f =  $symbols_stress1_w -> Frame -> pack ;
    $sitecode_f = $color_f -> Frame -> pack (-side => 'bottom') ;
    $button_f = $symbols_stress1_w -> Frame -> pack (-side => 'bottom',
						     -anchor => 'se');
    #Size
    heading ($size_f, 'Symbol Size', 'w', 'n');
    foreach $line_ar (@size_a) {
	$size_f -> Radiobutton (-text => @$line_ar[0],
				-value => @$line_ar[1],
				-variable => \$var_h{'Stress1DataSize'}
				) -> pack (-anchor => 'w');
    }
    foreach $key (sort keys %size_hash){
	$size_f -> LabEntry (-label => $key,
			     -textvariable => $size_hash{$key},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 5,
			     ) -> pack (-anchor => 'w');
    }
    
    #Length
    heading ($length_f, 'Length', 'w', 'n');
    foreach $line_ar(@size_a) {
	$length_f -> Radiobutton (-text => @$line_ar[0],
				-value => @$line_ar[1],
				-variable => \$var_h{Stress1DataLen},
				) -> pack (-anchor => 'w');
    }
    foreach $key (sort keys %length_hash){
	$length_f -> LabEntry (-label => $key,
			     -textvariable => $length_hash{$key},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 5,
			     ) -> pack (-anchor => 'w');
    }
    
    #Color
    heading ($color_f, 'Color', 'w', 'n');
    foreach $line_ar (@color_a){
	$color_f -> Radiobutton (-text => @$line_ar[0],
				-value => @$line_ar[1],
				-variable => \$var_h{Stress1DataColor},
				) -> pack (-anchor => 'w');
    }
    foreach $key (sort keys %color_hash){
	$color_f -> LabEntry (-label => $key,
			     -textvariable => $color_hash{$key},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 10,
			     ) -> pack (-anchor => 'w');
    }
    
    #outline
    heading ($outline_f, 'Line Thickness', 'w', 'n');
    # in the outline array we can use the @size_a without tiny and verytiny
    splice (@size_a, 3,2);
    foreach (@size_a){
	$outline_f -> Radiobutton (-text => @$_[0],
				-value => @$_[1],
				-variable => \$var_h{Stress1DataT}
				) -> pack (-anchor => 'w');
    }
    foreach $key (sort keys %outline_hash){
	$outline_f -> LabEntry (-label => $key,
			     -textvariable => $outline_hash{$key},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 3,
			     ) -> pack (-anchor => 'w');
    }

    # Sitecode
    heading ($sitecode_f, 'Sitecode');
    yes_no ($sitecode_f, \$var_h{Stress1SC});
    $sitecode_f -> LabEntry (-label => 'Color',
			     -textvariable => \$var_h{Stress1SCCol},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 8,
			     ) -> pack (-anchor => 'w');
    $sitecode_f -> LabEntry (-label => 'Font Size',
			     -textvariable => \$var_h{Stress1SCFontSiz},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 8,
			     ) -> pack (-anchor => 'w');

    # Buttons
    make_buttons($symbols_stress1_w, $button_f, \%var_h);
  }
  else {
    $symbols_stress1_w -> deiconify;
    $symbols_stress1_w -> raise;
  }
    
    
} # end of symbols_stress1

###############################################################
##   sub: stress_legend                                     ###
###############################################################

sub stress_legend {
  if (!Exists $stress_legend_w) {
  

    my ($position_f, $size_f, $background_f, $button_f);
    my (%position_hash, @var_a, %var_h, $key);


    # Initalisation of Variables
    @var_a = (qw/ StressLegend PosStressLegend SizeStressLegend
	      StressLegBackgr DepthIntLeg /);
    foreach (@var_a){ $var_h{$_} = $mailvarhash{$_} }

    %position_hash = ('Lower Left' => 'll',
		      'Lower Right'=> 'lr',
		      'Upper Left' => 'ul',
		      'Uppper Right' => 'ur',
		      );

    # Legend Window
    $stress_legend_w = $mw -> Toplevel (-title => 'Stress Legend');
    yes_no ($stress_legend_w, \$var_h{StressLegend}, 'n');

    # Frames
    $position_f = $stress_legend_w -> Frame -> pack (-side => 'left');
    $background_f = $position_f -> Frame -> pack (-side => 'bottom');
    extra_frame ($stress_legend_w);
    $size_f = $stress_legend_w -> Frame -> pack ();
    $button_f = $stress_legend_w -> Frame -> pack (-side => 'bottom');
    
    # Position
    heading ($position_f, 'Position');
    foreach $key (sort keys %position_hash){
	$position_f -> Radiobutton (-text => $key,
				    -value => $position_hash{$key},
				    -variable => \$var_h{PosStressLegend},
				    ) -> pack (-anchor => 'w');
    }

    # Size
    heading ($size_f, 'Size');
    foreach (qw/ huge large middle small/){
	$size_f -> Radiobutton (-text => $_,
				-value => $_,
				-variable => \$var_h{SizeStressLegend},
				) -> pack (-anchor => 'w');
    }

    # Background Color
    heading ($background_f, 'Background Color');
    $background_f -> LabEntry (-label => 'r/g/b',
			       -labelPack => [qw/ -side right -anchor w/],
			       -textvariable => \$var_h{StressLegBackgr},
			       -width => '10',
			       ) -> pack (-anchor => 'w');

    heading ($background_f, 'Depth Interval');
    yes_no ($background_f, \$var_h{DepthIntLeg});
    
    # Buttons
    make_buttons($stress_legend_w, $button_f, \%var_h);
  }
  else {
    $stress_legend_w -> deiconify;
    $stress_legend_w -> raise;
  }
    
} # end of sub stress_legend



###############################################
#  sub user_stress_data                       #
###############################################

sub user_stress_data {
  if (!Exists $user_stress_w) {
  
  # Declaration of Variables
  my ($quality_f, $depth_f, $regime_f, $type_f, $button_f, $file_f);
  my (%typehash, %type_cb, %quality_hash, );
  my (@type_a, @var_a, %var_h,);
  my ($element_ref, $key, $regime_aref, $type_aref,);

  # Initialisation
  @var_a = (qw/
	    Stress2Data
	    S2TypeFMS S2TypeFMA S2TypeFMF S2TypeBO S2TypeDIF S2TypeBS S2TypeOC S2TypeHF S2TypeGI
            S2_Regime_TF S2_Regime_TS S2_Regime_SS S2_Regime_NS S2_Regime_NF S2_Regime_U
	    S2QualA S2QualB S2QualC S2QualD S2QualE
	    Stress2Depth S2DepthTop S2DepthBot
	    /);
  $var_h{$_} = $mailvarhash{$_} for (@var_a);

  %quality_hash =('A' => \$var_h{'S2QualA'},
		  'B' => \$var_h{'S2QualB'},
		  'C' => \$var_h{'S2QualC'},
		  'D' => \$var_h{'S2QualD'},
		  'E' => \$var_h{'S2QualE'},
		  );
  
  $regime_aref = [['TF (Thrust Faulting)',      \$var_h{S2_Regime_TF}],
       	          ['TS (TF with SS component)', \$var_h{S2_Regime_TS}],
       	          ['SS (Strike-Slip)',          \$var_h{S2_Regime_SS}],
       	          ['NS (NF with SS component)', \$var_h{S2_Regime_NS}],
       	          ['NF (Normal Faulting)',      \$var_h{S2_Regime_NF}],
       	          ['U (Unknown)',               \$var_h{S2_Regime_U}],
	          ];

  $type_aref = [['Focal Mechanism, Single (FMS)', \$var_h{'S2TypeFMS'}],
                ['Focal Mechanism, Average (FMA)', \$var_h{'S2TypeFMA'}],
                ['Focal Mechanism, Formal Inversion (FMF)', \$var_h{'S2TypeFMF'}],
		['Borehole Breakout (BO)' ,        \$var_h{'S2TypeBO'}],
		['Drilling Induced Fractures (DIF)' ,  \$var_h{'S2TypeDIF'}],
		['Borehole Slotter (BS)' ,          \$var_h{'S2TypeBS'}],
		['Overcoring (OC)' ,                \$var_h{'S2TypeOC'}],
		['Hydraulic Fracture (HF)' ,            \$var_h{'S2TypeHF'}],
		['Geological Indicators (GI)' ,     \$var_h{'S2TypeGI'}],
		];


  # Window and Frames
  $user_stress_w = $mw -> Toplevel(-title => "Select User Stress Data",
                                   -width => 790, -height => 300);
  $quality_f = $user_stress_w -> Frame -> place (-x=> 10, -y=> 10);
  $depth_f = $user_stress_w -> Frame  -> place (-x=>100, -y=> 10);
  $regime_f = $user_stress_w -> Frame() -> place (-x=>230, -y=> 10);
  $type_f = $user_stress_w -> Frame() -> place (-x=>450, -y=> 10);
  $file_f = $user_stress_w -> Frame -> place (-x=>130, -y=>220);
  $button_f = $user_stress_w -> Frame -> place (-x=>570, -y=>260);

  # Types
  heading($type_f, "Type", 'w', 'n');
  # $type_aref is an 2dim array
   foreach $element_ref (@$type_aref){
       $type_f -> Checkbutton (-text => @$element_ref[0],
 			      -onvalue => 'y',
 			      -offvalue => 'n',
 			      -variable => @$element_ref[1],      
 			  ) -> pack (-anchor => 'w');
   }
  
  # Regimes
  heading($regime_f, "Regime", 'w', 'n');
  # $regime_aref is a 2dim array
   foreach $element_ref (@$regime_aref){
       $regime_f -> Checkbutton (-text => @$element_ref[0],
 	      		         -onvalue => 'y',
 	      		         -offvalue => 'n',
 	      		         -variable => @$element_ref[1],      
 			        ) -> pack (-anchor => 'w');
   }

  # Qualities
  heading ($quality_f, "Quality", 'w', 'n');
  foreach $key (sort keys %quality_hash){
    $quality_f -> Checkbutton (-text => $key,
			       -onvalue => 'y',
			       -offvalue => 'n',
			       -variable => $quality_hash{$key},
			       ) -> pack(-anchor => 'w');
  }

  # Depth
  heading ($depth_f, "Depth", 'w', 'n');
  foreach (qw/all user_defined/) {
  $depth_f -> Radiobutton (-text => $_,
			   -variable => \$var_h{Stress2Depth},
			   -value => $_,
			   ) -> pack (-side => 'top', -anchor => 'w');
  }
  
  $depth_f -> LabEntry (-label => "From",
			-width => 5,
			-labelPack => [qw /-side left -anchor w/],
			-textvariable => \$var_h{S2DepthTop},
		       ) -> pack (-anchor => 'w');
  $depth_f -> LabEntry (-label => "To    ", # some spaces added, so that the Entries align
			-width => 5,
			-labelPack => [qw /-side left -anchor w/],
			-textvariable => \$var_h{S2DepthBot},
		       ) -> pack (-anchor => 'w');
  $depth_f -> Label (-text => '         [km]',
		            ) -> pack (-side => 'left');

  # select your own data file
  $file_f -> Button (-text => 'Select your data file',
		      -command => sub {
			err_win("Please note that the Stress Data is expected
to have the following format: \n
 longitude latitude azimuth type quality regime depth sitecode");
			$var_h{Stress2Data} = open_file('Selecting your Stress Data');
			} ) -> pack (-anchor => 'w');
  

  # Buttons:
  make_buttons($user_stress_w, $button_f, \%var_h);
}
  else {
    $user_stress_w -> deiconify;
    $user_stress_w -> raise;
  }

} # end of sub user_stress_data

##########################################################
##   sub user_symbols_stress                           ###
##########################################################

sub user_symbols_stress {
  if (!Exists $user_symbols_stress_w) {
  
    my ($size_f, $length_f, $color_f,
	$outline_f, $sitecode_f, $button_f);
    my ($key, @var_a, %var_h, $string, @size_a, @color_a, $line_ar);
    my (%size_hash, %length_hash, %color_hash, %outline_hash);

    # Initalisation
    @var_a = (qw/ Stress2DataSize Stress2DataColor Stress2DataLen Stress2DataT
	      S2DataQASize S2DataQBSize S2DataQCSize S2DataQDSize S2DataQESize
	      S2DataQALen S2DataQBLen S2DataQCLen S2DataQDLen S2DataQELen
	      S2DataTFColor S2DataSSColor S2DataNFColor S2DataUColor
	      S2QualAT S2QualBT S2QualCT S2QualDT S2QualET
	      Stress2SC Stress2SCCol Stress2SCFontSiz /);
    foreach (@var_a){ $var_h{$_} = $mailvarhash{$_} }

    %size_hash = ('Quality A' => \$var_h{'S2DataQASize'},
		  'Quality B' => \$var_h{'S2DataQBSize'},
		  'Quality C' => \$var_h{'S2DataQCSize'},
		  'Quality D' => \$var_h{'S2DataQDSize'},
		  'Quality E' => \$var_h{'S2DataQESize'},
		  );
    %length_hash = ('Quality A' => \$var_h{'S2DataQALen'},
		    'Quality B' => \$var_h{'S2DataQBLen'},
		    'Quality C' => \$var_h{'S2DataQCLen'},
		    'Quality D' => \$var_h{'S2DataQDLen'},
		    'Quality E' => \$var_h{'S2DataQELen'},
		    );

    %color_hash = ('TF' => \$var_h{'S2DataTFColor'},
		    'SS' => \$var_h{'S2DataSSColor'},
		    'NF' => \$var_h{'S2DataNFColor'},
		    'U' => \$var_h{'S2DataUColor'},
		    );
    %outline_hash = ('Quality A' => \$var_h{'S2QualAT'},
		    'Quality B' => \$var_h{'S2QualBT'},
		    'Quality C' => \$var_h{'S2QualCT'},
		    'Quality D' => \$var_h{'S2QualDT'},
		    'Quality E' => \$var_h{'S2QualET'},
		    );
    @size_a = (['large',       'large'],
	       ['middle',      'middle'],
	       ['small',       'small'],
	       ['tiny',        'tiny'],
	       ['very tiny',   'verytiny'],
	       [$user_defined, 'user_defined'],
	      );
    @color_a = (['default',     'default'],
	       ['black',        'black'],
	       [$user_defined,  'user_defined'],);
    
    # Window and frames
    $user_symbols_stress_w = $mw -> Toplevel (-title => 'User Stress Symbols');
     foreach ($size_f, $length_f, $color_f){
 	$_ = $user_symbols_stress_w -> Frame () ->
 	    pack (-side => 'left', -anchor => 'nw');
	extra_frame ($user_symbols_stress_w);
     }
    $outline_f =  $user_symbols_stress_w -> Frame -> pack ;
    $sitecode_f = $color_f -> Frame -> pack (-side => 'bottom') ;
    $button_f = $user_symbols_stress_w -> Frame -> pack (-side => 'bottom',
						     -anchor => 'se');
    #Size
    heading ($size_f, 'Symbol Size', 'w', 'n');
    foreach $line_ar (@size_a) {
	$size_f -> Radiobutton (-text => @$line_ar[0],
				-value => @$line_ar[1],
				-variable => \$var_h{'Stress2DataSize'}
				) -> pack (-anchor => 'w');
    }
    foreach $key (sort keys %size_hash){
	$size_f -> LabEntry (-label => $key,
			     -textvariable => $size_hash{$key},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 5,
			     ) -> pack (-anchor => 'w');
    }
    
    #Length
    heading ($length_f, 'Length', 'w', 'n');
    foreach $line_ar(@size_a) {
	$length_f -> Radiobutton (-text => @$line_ar[0],
				-value => @$line_ar[1],
				-variable => \$var_h{Stress2DataLen},
				) -> pack (-anchor => 'w');
    }
    foreach $key (sort keys %length_hash){
	$length_f -> LabEntry (-label => $key,
			     -textvariable => $length_hash{$key},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 5,
			     ) -> pack (-anchor => 'w');
    }
    
    #Color
    heading ($color_f, 'Color', 'w', 'n');
    foreach $line_ar (@color_a){
	$color_f -> Radiobutton (-text => @$line_ar[0],
				-value => @$line_ar[1],
				-variable => \$var_h{Stress2DataColor},
				) -> pack (-anchor => 'w');
    }
    foreach $key (sort keys %color_hash){
	$color_f -> LabEntry (-label => $key,
			     -textvariable => $color_hash{$key},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 10,
			     ) -> pack (-anchor => 'w');
    }
    
    #outline
    heading ($outline_f, 'Line Thickness', 'w', 'n');
    # in the outline array we can use the @size_a without tiny and verytiny
    splice (@size_a, 3,2);
    foreach (@size_a){
	$outline_f -> Radiobutton (-text => @$_[0],
				-value => @$_[1],
				-variable => \$var_h{Stress2DataT}
				) -> pack (-anchor => 'w');
    }
    foreach $key (sort keys %outline_hash){
	$outline_f -> LabEntry (-label => $key,
			     -textvariable => $outline_hash{$key},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 3,
			     ) -> pack (-anchor => 'w');
    }

    # Sitecode
    heading ($sitecode_f, 'Sitecode');
    yes_no ($sitecode_f, \$var_h{Stress2SC});
    $sitecode_f -> LabEntry (-label => 'Color',
			     -textvariable => \$var_h{Stress2SCCol},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 8,
			     ) -> pack (-anchor => 'w');
    $sitecode_f -> LabEntry (-label => 'Font Size',
			     -textvariable => \$var_h{Stress2SCFontSiz},
			     -labelPack => [qw/ -side right -anchor w/],
			     -width => 8,
			     ) -> pack (-anchor => 'w');

    # Buttons
    make_buttons($user_symbols_stress_w, $button_f, \%var_h);
  }
  else {
    $user_symbols_stress_w -> deiconify;
    $user_symbols_stress_w -> raise;
  }

} # end of user_symbols_stress


####################################################
##        File Menu                              ###
####################################################

##########################################
##   sub page_settings                  ##
##########################################

sub page_settings {
  if (!Exists $page_settings_w) {
  

    my ($size_f, $orientation_f, $button_f);
    my (@var_a, %var_h, %margin_h, %bounding_box_h, $element, $key);

    # Initalisation
    @var_a = (qw/ PaperSize PaperWidth PaperHeight PaperOrientation
		 LeftMargin BottomMargin BBoxFrame
		 BBoxFrameCol BBoxFilCol PlotWidth 
	      /);
    $var_h{$_} = $mailvarhash{$_} for (@var_a);

    %margin_h = ('Left'   => \$var_h{'LeftMargin'},
		 'Bottom' => \$var_h{'BottomMargin'},
		 );
    %bounding_box_h = ('Frame Color'   => \$var_h{'BBoxFrameCol'},
		      # 'Fill Color' => \$var_h{'BBoxFilCol'},
		       );

    # Frames and Windows
    $page_settings_w = $mw -> Toplevel (-title => 'Page Settings');
    $size_f = $page_settings_w -> Frame
      -> pack (-side => 'left', -anchor => 'nw');
    extra_frame ($page_settings_w);
    $orientation_f = $page_settings_w -> Frame -> pack;
    $button_f = $page_settings_w -> Frame -> pack (-side => 'bottom',
						   -anchor => 'e');

    # Orientation, etc.
    heading ($orientation_f, 'Orientation', 'w', 'n');
    foreach (qw/Landscape Portrait/){
	$orientation_f -> Radiobutton (-text => $_,
				       -value => $_,
				       -variable => \$var_h{'PaperOrientation'},
				       ) -> pack (-anchor => 'w');
    }

    
    heading ($orientation_f, 'Plot Margins');
    foreach $key (keys %margin_h) {
	$orientation_f -> LabEntry (-label => $key,
				    -labelPack => [qw/ -side right -anchor w/],
				    -width => '10',
				    -textvariable => $margin_h{$key},
				    ) -> pack (-anchor => 'w');
    }

    heading ($orientation_f, 'Bounding Box');
    yes_no ($orientation_f, \$var_h{'BBoxFrame'});
    foreach $key (keys %bounding_box_h) {
	$orientation_f -> LabEntry (-label => $key,
				    -labelPack => [qw/ -side right -anchor w/],
				    -width => '10',
				    -textvariable => $bounding_box_h{$key},
				    ) -> pack (-anchor => 'w');
    }

    heading ($orientation_f, 'Plot Width');
    $orientation_f -> LabEntry (-label => "Width (Inches)",
				    -labelPack => [qw/ -side right -anchor w/],
				    -width => '10',
				    -textvariable => \$var_h{PlotWidth},
				    ) -> pack (-anchor => 'w');
    


    # Page Size
    heading ($size_f, 'Page Size', 'w', 'n');
    foreach (qw/ A4 A3 A2 A1 A0 Letter Legal Tabloid user_defined/){
	$size_f -> Radiobutton (-text => $_,
				-value => $_,
				-variable => \$var_h{'PaperSize'},
				) -> pack (-anchor => 'w');
    }
    $size_f -> LabEntry (-label => "Paper Height ($measure_unit_h{$mailvarhash{MEASURE_UNIT}})",
			 -labelPack => [qw/ -side right -anchor w/],
			 -width => 10,
			 -textvariable => \$var_h{'PaperHeight'},
			 ) -> pack (-anchor => 'w');
    $size_f -> LabEntry (-label => "Paper Width ($measure_unit_h{$mailvarhash{MEASURE_UNIT}})",
			 -labelPack => [qw/ -side right -anchor w/],
			 -width => 10,
			 -textvariable => \$var_h{'PaperWidth'},
			 ) -> pack (-anchor => 'w');

    # empty label to get some space to the buttons
    $size_f -> Label (-text => '') -> pack;

    # Buttons
    make_buttons($page_settings_w, $button_f, \%var_h);
  }
  else {
    $page_settings_w -> deiconify;
    $page_settings_w -> raise;
  }

} # end of page settings

###################################################
###      sub: save_map                           ##
###################################################

sub save_map{

  my ($file, $types, $path, $dir, $ext);
  my $orig_file = "$startdir/$mailvarhash{PsName}";
  $types = [
	    ['GIF Files', '.gif'],
	    ['PDF Files', '.pdf'],
	    ['PS Files',   '.ps'],
	    ['All Files',    '*'],
	   ];
  $path = $mw -> getSaveFile (-filetypes => $types,
			     -initialdir => Cwd::cwd(),
			     -title => 'Save Map As',
			     );
  if ($path ne '') {
    # we just cp casmi-output to filename with the appropiate extension
    # first split it into the appropiate parts: $dir/$base.$extension
    ($file, $dir, $ext) = fileparse($path,'\..*');

    # ps as default: 
    if ($ext eq '') {
    err_win ("Please write the extension in the file name. \n Your file is saved as $path.ps \n");
    move ("$orig_file.ps", $path) or warn "Couldn't move $orig_file to $path for $!";
    }
    elsif ($ext eq '.gif') {
      move ("$orig_file.gif", $path) or warn "Couldn't move $orig_file.gif to $path for $!";
    }
    elsif ($ext eq '.pdf') {
      system ('ps2pdf', "$orig_file.ps") == 0
	or warn "Couldn't ps2pdf $orig_file.ps for $!";
      move ("$orig_file.pdf", $path) or warn "Couldn't move $file.pdf to $path for $!";
    }
    elsif ($ext eq '.ps') {
      move ("$orig_file.ps", $path) or warn "Couldn't move $orig_file.ps to $path for $!";
    }
    else {
      print ("How could that be?\n");
      print ("dir is $dir, name is $file, extension is $ext\n");
    }
  }
} # end of save_map

#################################################
##   sub save_ascii_data                      ###
#################################################

sub save_ascii_data {
  my ($file, $type_ar);
  $type_ar = [['Data Files', '.dat'],
	      ['All Files', '*']];
  
  ($file) = $mw -> getSaveFile (-title => 'Save Stress Data (ASCII)',
				-initialdir => $startdir,
				-filetypes => $type_ar,
			#	-initialfile => 'stress_data.dat'
			       );
  if ($file ne '') {
    `cp 'StressData.select' $file`;
  }

}



###################################################
##        sub: save_settings                    ###
###################################################

sub save_settings {
  my ($filename, $key, $type_ar);

  # initialdir is not working
  # even without setting it, it should start,
  #     where the application has been started!

  $type_ar = [
	      ['Casmi Files', '.cas'],
	      ['All Files', '*'],
	      ];
  
  ($filename) = $mw -> getSaveFile(-filetypes => $type_ar,
                                   -initialdir => $startdir,
				   -initialfile => "$ENV{HOME}/casmi_defaults.cas",
				   -title => 'Save Plot Settings',);

  if ($filename ne ''){
    # write mailvarhash to the file 
    open (SAVEFILE, "> $filename") or warn "Could not write to $filename";
    foreach $key (sort keys %mailvarhash){
      print (SAVEFILE "$key => $mailvarhash{$key}\n");
    }
    close (SAVEFILE);
  }
} # end of save settings


###################################################
##        sub: load_settings                    ###
###################################################


sub load_settings {
  my ($filename, $key, $value, $type_ar) = @_;
  $type_ar = [
	      ['Casmi Files', '.cas'],
	      ['All Files', '*'],
	     ];

  # if filename is not supplied we have to get it
  if (!defined $filename) {
  ($filename) = $mw -> getOpenFile(-title => 'Load Plot Settings',
				   -initialdir => $startdir,
				   -filetypes => $type_ar);
  }

  if ($filename ne ''){
    # we have to empty %mailvarhash first and then read it in with the
    # new key / value pairs
    %mailvarhash = ();
    
    open (LOADFILE, "< $filename") or warn "Could not open $filename for $!\n";
    while (<LOADFILE>) {
      chomp;
      ($key, $value) = ($_ =~ m/^(.*) => (.*)\s*$/) unless /^\s*$/;
      $mailvarhash{$key} = $value;
    }
    close (LOADFILE) or warn "could not close $filename for $!\n";
  }
} # end of load_settings

#################################################
###     sub: all_to_default                    ##
#################################################

# will reset all of mailvarhash to $HOME/casmi_defaults.cas (if this exists)
# or to the original one

sub all_to_default {
  if (-e "$ENV{HOME}/casmi_defaults.cas") {
    load_settings ("$ENV{HOME}/casmi_defaults.cas")
  } else {
    %mailvarhash = ();
    $mailvarhash{$_} = $mailvarhash_backup{$_} for (keys %mailvarhash_backup);
  }
}			  

###################################################
###          sub: exit_casmi                    ###
###################################################

sub exit_casmi {
  if (-e "$startdir/$mailvarhash{PsName}.gmt") {
    unlink <casmi-*> or warn "unlink casmi-* failed for $!";
  }
  unlink 'StressData.select' if (-e 'StressData.select');
  exit 0;
}


##################################################
##        Extras Menu                           ##
##                                              ##
##################################################

########################################
##       change_files_directories     ##
########################################

sub change_files_directories {
  if (!Exists $change_files_directories_w) {
  

  my ($main_f, $button_f);
  my (@var_a, %var_h, $key, @files_a, $line_ar,);

  # Initalisation
  @var_a = (qw/
	    Stress1Data PlaBoData TopoFile TopoCptFile 
	    NOFOOTHER OVERLAY
	    /);
  @files_a = (['WSM Stress Data',  'Stress1Data'],
	      ['Topography',       'TopoFile'],
	      ['Topography CPT',        'TopoCptFile'],
	      ['Plate Boundaries', 'PlaBoData'],);
  foreach (@var_a) {$var_h{$_} = $mailvarhash{$_} }

  # Windows and Frames
  $change_files_directories_w = $mw -> Toplevel
    (-title => 'Change Files/Directories');
  $main_f = $change_files_directories_w -> Frame -> pack;
  $button_f = $change_files_directories_w -> Frame
    -> pack (-side => 'bottom', -anchor => 'e');

  
  # Changing Files
  heading ($main_f, 'Changing Files', 'w', 'n');
  foreach $line_ar (@files_a) {
    $main_f -> Button (-text => @$line_ar[0],
		       -command => sub {
			 # if a  open_file is cancelled and '' returned
			 # make_buttons will not overwrite the original
			 # $mailvarhash{value}
			 $var_h{@$line_ar[1]} = open_file("Changing @$line_ar[0]");
		       } ) -> pack (-anchor => 'w');
  }

  # Overlay/ Nofoother
  heading ($main_f, 'Change PostScript Settings');
  $main_f -> Label (-text => 'More postscript shall be appended later?',)
    -> pack (-anchor => 'w');
  foreach (qw/ yes no/){
    $main_f -> Radiobutton (-text => $_,
			    -value => $_,
			    -variable => \$var_h{NOFOOTHER},
			    ) -> pack (-anchor => 'w');
  }

  # Buttons
  make_buttons($change_files_directories_w, $button_f, \%var_h);
}
  else {
    $change_files_directories_w -> deiconify;
    $change_files_directories_w -> raise;
  }
  
} # end of sub: change_files_directories

#########################################################
## sub: change_gmt_defaults                            ##
#########################################################

sub change_gmt_defaults {
  if (!Exists $change_gmt_defaults_w) {
  
  my ($main_f, $button_f);
  my (@var_a, %var_h, );

  # Initialising
  @var_a = (qw/ DOTS_PER_INCH MEASURE_UNIT BASEMAP_TYPE ANOT_FONT_SIZE
 	    FRAME_WIDTH FRAME_PEN PAGE_COLOR LABEL_FONT_SIZE
 	    /);
  $var_h{$_} = $mailvarhash{$_} for (@var_a);


  # Windows, Frames
  $change_gmt_defaults_w = $mw -> Toplevel (-title => 'Change GMT Defaults');
  $main_f = $change_gmt_defaults_w -> Frame -> pack (-anchor => 'w');
  $button_f = $change_gmt_defaults_w -> Frame -> pack (-side => 'bottom',
						       -anchor => 'e');

  foreach (sort keys %var_h) {
    $main_f -> LabEntry (-label => $_,
			 -labelPack => [qw/ -side right -anchor w/],
			 -textvariable => \$var_h{$_},
			 -width => 10,
			) -> pack (-anchor => 'w');
  }
  make_buttons ($change_gmt_defaults_w, $button_f, \%var_h);
}
  else {
    $change_gmt_defaults_w -> deiconify;
    $change_gmt_defaults_w -> raise;
  }
  

} # end of change_gmt_defaults

###########################################################
###  gmt_messages_w
###########################################################

sub show_gmt_messages {
  if (! Exists $gmt_messages_w) {
    $gmt_messages_w = $mw -> Toplevel (-title => 'Showing all those gmt messages');
    my $t = $gmt_messages_w->Scrolled (qw / Text -relief sunken -borderwidth 2 -setgrid true -height 30 -scrollbars e/);
    $t->pack (qw/-expand yes -fill both/);
    $t->insert('0.0', $ms24_messages);
    

  }
  else {
    $gmt_messages_w -> deiconify;
    $gmt_messages_w -> raise;
  }


}



############################################################
##   Plot Smoothed Data                                  ###
############################################################

sub plot_smoothed_data {
  if (!Exists $plot_smooth_data_w) {
  
  my ($smooth_data_f, $call_smooth_f, $button_f);
  my (@var_a, %var_h,);

  @var_a = (qw/ SmoothData
	    SmSmData SmSmDataLen SmSmDataCol SmSmDataT SmInfo
	 /);
  $var_h{$_} = $mailvarhash{$_} for (@var_a);

  # Windows and Frames
  $plot_smooth_data_w = $mw -> Toplevel (-title => 'Plot Smoothed Data');
  $smooth_data_f = $plot_smooth_data_w -> Frame
    -> pack (-side => 'left', -anchor => 'nw');
  extra_frame ($plot_smooth_data_w);
  $call_smooth_f = $plot_smooth_data_w -> Frame -> pack;
  $button_f = $plot_smooth_data_w -> Frame -> pack (-side => 'bottom');

  # Plot Smooth Data
  heading ($smooth_data_f, 'Plot Smoothed Data?', 'w', 'n');
  yes_no ($smooth_data_f, \$var_h{SmoothData});

  $smooth_data_f -> Button (-text => 'Select Smooth Data',
			    -command => sub {
				my ($temp_file);
				$temp_file = 
				    open_file ('Select Smooth Data');
				if ($temp_file ne '') {
				  if ($temp_file =~ /\.sdat$/) {
				    $var_h{SmSmData} = $temp_file;
				  } else
				    {
				      err_win ("Please make sure, your input file for Smoothed Data has a '.sdat' extension");
				    }
				}
			    }) -> pack (-anchor => 'w');
  foreach (qw/tiny small middle large/) {
    $smooth_data_f -> Radiobutton (-text => $_,
				  -variable => \$var_h{SmSmDataLen},
				  -value => $_,
				  ) -> pack (-anchor => 'w');
  }

  foreach (@{[['Length', \$var_h{SmSmDataLen}],
	      ['Color of Lines', \$var_h{SmSmDataCol}],
	      ['Thickness in Inches', \$var_h{SmSmDataT}]]
	    }) {
    $smooth_data_f -> LabEntry (-label => @$_[0],
				-labelPack => [qw/ -side right -anchor w/],
				-textvariable => @$_[1],
				-width => 5,
				) -> pack (-anchor => 'w');
  }

  $smooth_data_f -> Label (-text => 'Plot Smooth Info String?')
      -> pack (-anchor => 'w');
  foreach (qw/ yes no /) {
    $smooth_data_f -> Radiobutton (-text => $_,
				   -value => substr($_,0,1),
				   -variable => \$var_h{SmInfo},
				  ) -> pack (-anchor => 'w');
  }

  # extra set of buttons to allow easy setting of vars without calling smooth
  make_buttons ($plot_smooth_data_w, $smooth_data_f, \%var_h);
  # Call Smooth
  heading ($call_smooth_f, 'Smooth Options', 'w', 'n');
  call_smooth_sub ($plot_smooth_data_w, $call_smooth_f, '-S');
}
  else {
    $plot_smooth_data_w -> deiconify;
    $plot_smooth_data_w -> raise;
  }

} # end of plot_smooth_data

############################################################
##  sub: plot_gridded_smooth                              ##
############################################################

sub plot_gridded_smooth {
  if (! Exists $plot_gridded_smooth_w) {
  
    my ($smooth_grid_data_f, $call_smooth_f,);
    my (@var_a, %var_h, %smooth_grid_h,);

  @var_a = (qw/ 
            SmoothGridmap SmGridData SmGridDataLen SmGridDataT SmGridDataCol
	    /);
  $var_h{$_} = $mailvarhash{$_} for (@var_a);

  %smooth_grid_h = ('grid_xinc' => 1,
		    'grid_yinc' => 1,
		    );

  # Windows and Frames
  $plot_gridded_smooth_w = $mw -> Toplevel (-title => 'Gridded Smooth');
  $smooth_grid_data_f = $plot_gridded_smooth_w -> Frame
    -> pack (-side => 'left', -anchor => 'nw');
  extra_frame ($plot_gridded_smooth_w);
  $call_smooth_f = $plot_gridded_smooth_w -> Frame -> pack;

  # Grid Data
  heading ($smooth_grid_data_f, 'Plot Gridded Smooth Data', 'w', 'n');
  yes_no ($smooth_grid_data_f, \$var_h{SmoothGridmap});

  $smooth_grid_data_f -> Button (-text => 'Select Grid Data',
			    -command => sub {
				my ($temp_file);
				$temp_file = 
				    open_file ('Select Grid Data');
				if ($temp_file ne '') {
				    $var_h{SmGridData} = $temp_file;
				}
			    }) -> pack (-anchor => 'w');
  foreach (qw/tiny small middle large /) {
    $smooth_grid_data_f -> Radiobutton (-text => $_,
				  -variable => \$var_h{SmGridDataLen},
				  -value => $_,
				  ) -> pack (-anchor => 'w');
  }

  foreach (@{[['Length', \$var_h{SmGridDataLen}],
	      ['Color of Lines', \$var_h{SmGridDataCol}],
	      ['Thickness in Inches', \$var_h{SmGridDataT}]]
	    }) {
    $smooth_grid_data_f -> LabEntry (-label => @$_[0],
				-labelPack => [qw/ -side right -anchor w/],
				-textvariable => @$_[1],
				-width => 10,
				) -> pack (-anchor => 'w');
  }
  make_buttons ($plot_gridded_smooth_w, $smooth_grid_data_f, \%var_h);

  # Smooth Grid Options (mainly xinc, yinc)
  heading ($call_smooth_f, 'Smooth Grid Options', 'w', 'n');
  my ($temp1_f,);
  $temp1_f = $call_smooth_f -> Frame -> pack (-anchor => 'w');
  $temp1_f -> LabEntry (-label => 'X Inc.',
			-labelPack => [qw/ -side right -anchor w/],
			-textvariable => \$smooth_grid_h{grid_xinc},
			-width => 5,
		       ) -> pack (-side => 'left');
  $temp1_f -> LabEntry (-label => 'Y Inc',
			-labelPack => [qw/ -side right -anchor w/],
			-textvariable =>\$smooth_grid_h{grid_yinc},
			-width => 5,
		       ) -> pack (-side => 'left');
  # Rest of the Options
  call_smooth_sub ($plot_gridded_smooth_w, $call_smooth_f, "-G", \$smooth_grid_h{grid_xinc}, \$smooth_grid_h{grid_yinc});
}
  else {
    $plot_gridded_smooth_w -> deiconify;
    $plot_gridded_smooth_w -> raise;
  }

} # end of plot_gridded_smooth


############################################################
##  sub: plot_smooth_trajectories                         ##
############################################################

sub plot_smooth_trajectories {
  if (!Exists $plot_smooth_traj_w) {
  
  my ($smooth_traj_data_f, $call_smooth_f,);
  my (@var_a, %var_h, %smooth_traj_h,);

  @var_a = (qw/
             SmoothTraj SmTrajData SmTrajDataSize SmTrajDataCol
	    /);
  $var_h{$_} = $mailvarhash{$_} for (@var_a);

  %smooth_traj_h = ('traj_startfile' => "$Bin/DATA/traj_default_startfile.trjs",
		    'traj_step' => 5,
		    );

  # Windows and Frames
  $plot_smooth_traj_w = $mw -> Toplevel (-title => 'Smooth Trajectories');
  $smooth_traj_data_f = $plot_smooth_traj_w -> Frame -> pack (-anchor => 'w');
  $call_smooth_f = $plot_smooth_traj_w -> Frame -> pack (-anchor => 'w');

  # Trajectories Options
  heading ($smooth_traj_data_f, 'Plot Smooth Trajectories', 'w', 'n');
  yes_no ($smooth_traj_data_f, \$var_h{SmoothTraj});

  $smooth_traj_data_f -> Button (-text => 'Select Trajectories Data',
			    -command => sub {
				my ($temp_file);
				$temp_file = 
				    open_file ('Select Trajectories Data');
				if ($temp_file ne '') {
				    $var_h{SmTrajData} = $temp_file;
				}
				
							      
			    }) -> pack (-anchor => 'w');

  foreach (@{[['Color of Lines', \$var_h{SmTrajDataCol}],
	      ['Thickness in Inches', \$var_h{SmTrajDataSize}]]
	    }) {
    $smooth_traj_data_f -> LabEntry (-label => @$_[0],
				-labelPack => [qw/ -side right -anchor w/],
				-textvariable => @$_[1],
				-width => 10,
				) -> pack (-anchor => 'w');
  }

  
  # extra set of buttons to allow easy setting of vars without calling smooth
  make_buttons ($plot_smooth_traj_w, $smooth_traj_data_f, \%var_h);
  
  # Smooth Traj Options (mainly startfile, traj_step)
  $call_smooth_f -> Label (-text => '') -> pack;
  heading ($call_smooth_f, 'Smooth Trajectories Options', 'w', 'n');
  my ($temp1_f,);
  $temp1_f = $call_smooth_f -> Frame -> pack (-anchor => 'w');
  $temp1_f -> Button (-text => 'Change Startfile',
		      -command => sub {
			$smooth_traj_h{startfile} = open_file
			  ('Change Smooth Trajectories Startfile');
			}) -> pack (-side => 'left');
  $temp1_f -> LabEntry (-label => 'Traj. Step',
			-labelPack => [qw/ -side right -anchor w/],
			-textvariable =>\$smooth_traj_h{traj_step},
			-width => 5,
		       ) -> pack (-side => 'left');
  # Rest of the Options
  # add some space 
  # $call_smooth_f -> Label (-text => '') -> pack;
  call_smooth_sub ($plot_smooth_traj_w, $call_smooth_f,"-T", \$smooth_traj_h{traj_startfile}, \$smooth_traj_h{traj_step});
}
  else {
    $plot_smooth_traj_w -> deiconify;
    $plot_smooth_traj_w -> raise;
  }

} # end of plot_smooth_traj


#############################################################
##   call_smooth_sub                                       ##
##   par: parent_window, $frame, output_format, ref1, ref2
##   eg: $parent_win, $frame, -T\$traj_startfile/\$traj_step
##   Note that the input file for smooth must be in lat/lon format
##   whereas the wsm_data is in lon/lat format
#############################################################

sub call_smooth_sub {
  my ($parent_window, $frame, $output_format, $ref1, $ref2) = @_;
  my ($other_par_f, $button_f, $apply_fr);
  my (@smooth_a,  %smooth_h, @args, %smooth_com_h, );
    # new variable %smooth_h for smooth options
  %smooth_h = (#'-inputfile' => "$Bin/DATA/small_region.dat",
	       '-inputfile' => "$mailvarhash{Stress1Data}_latlon",
	       '-A'     => 100,
	       '-B'     => 0,
	       '-C'     => 10,
	       '-D'     => 'ntwf',
	       '-E'     => 0,
	       '-I'     => 'n/3',
	       '-L'     => 12,
	       '-N'     => '',
	       '-O'     => "$startdir/casmi-smooth",
	       'output_format' => "$output_format",
	       '-R'      => "$mailvarhash{c1_lon}/$mailvarhash{c2_lon}/$mailvarhash{c1_lat}/$mailvarhash{c2_lat}",
	       '-Q'        => 'y1/0.75/0.5/0.25',
	       '-V'     => 0,

	       # other stuff
	       'traj_startfile' => '',
	       'traj_step'      => '',
	       'grid_xinc'      => 1,  # in degrees
	       'grid_yinc'      => 1,

	      );
  # strange enough: second array entry must be an ref, we can't put "\" 
  # in the -textvariable for some reason
  @smooth_a = (['Lambda'                     , \$smooth_h{-L}, 5],
	       ['Number of Neighbours'       , \$smooth_h{-N}, 5],
	       ['Radius [km]'                     , \$smooth_h{-A}, 5],
	       ['Quality A/B/C/D'            , \$smooth_h{-Q}, 15],
	       ['Range W/E/S/N'             , \$smooth_h{-R}, 15],
	    #   ['Name of Output File'        , \$smooth_h{-O}, 15],
	       ['Weight Method'              , \$smooth_h{-D}, 5],
	       ['Ignore Option'              , \$smooth_h{-I}, 5],
	       ['No. of Iterations'          , \$smooth_h{-C}, 5],
	      );

  # Windows and Frames
  $other_par_f = $frame -> Frame -> pack (-anchor => 'w');
  $button_f = $frame -> Frame -> pack (-side => 'bottom', -anchor => 'e');
  
  # Changing the Input file - default is Stress1Data_latlon
  $other_par_f -> Button (-text => 'Change Smooth Input File',
			    -command => sub {
			      my ($testfile);
			      $testfile = open_file ('Change Smooth Input File');
			      if ($testfile ne '') {$smooth_h{-inputfile} = $testfile;}
			    }) -> pack (-anchor => 'w');
  # Changing output file name, default is $Bin/DATA/casmi-smooth
  $other_par_f -> Button (-text => 'Change Output Filename',
			    -command => sub {
			      my ($testfile);
			      $testfile = open_file ('Change Output Filename');
			      if ($testfile ne '') {$smooth_h{-O} = $testfile;}
			    }) -> pack (-anchor => 'w');

  foreach (@smooth_a) {
    $other_par_f -> LabEntry (-label => @$_[0],
			      -labelPack => [qw/ -side right -anchor w/],
			      -textvariable => @$_[1],
			      -width => @$_[2],
			     ) -> pack (-anchor => 'w');
  }

  foreach (@{[['Deviation of Trajectories',  \$smooth_h{-E}],
	      ['Robustness Checking (Beta)', \$smooth_h{-B}],
	      ['Smooth in Verbose Mode',     \$smooth_h{-V}],
	     ]}) {
    $other_par_f -> Checkbutton (-text => @$_[0],
				 -variable => @$_[1],
			      ) -> pack (-anchor => 'w');
  }
  
  # Buttons
  $button_f -> Button (-text =>'Smooth data from given Input File',
		       -command => $apply_fr = sub {			 
##  $apply_fr = sub {			 
			 # checking the variables
			 if ($smooth_h{-N} ne '' and $smooth_h{-A} ne '') {
			   err_win("Please select only an area or neighbours \n");
			 }
			 unless ($smooth_h{-V}) {delete $smooth_h{-V} }
			 unless ($smooth_h{-E}) {delete $smooth_h{-E} }
			 unless ($smooth_h{-B}) {delete $smooth_h{-B} }

			 
			 # if no traj_file is given, we take the default:
			 if ($smooth_h{output_format} eq '-T'
			     and $smooth_h{traj_startfile} eq '') {
			   $smooth_h{traj_startfile} = "$Bin/DATA/traj_default_startfile.trjs";
			 }
			 # settting together the output format:
			 # getting: 2 refs, maybe one empty
			 if ($output_format eq '-G') {
			   $smooth_h{output_format} = "-G$$ref1/$$ref2";
			 }
			 elsif ($output_format eq '-T') {
			   $smooth_h{output_format} = "-T$$ref1/$$ref2";
			 }
			 elsif ($output_format eq '-S') {
			   $smooth_h{output_format} = "-S";
			 }
			   

			 # putting the vars into the command hash
			 %smooth_com_h = %smooth_h;
			 foreach (keys %smooth_h) {
			   if ($smooth_h{$_} eq '') {delete $smooth_com_h{$_} }
			 }
			 if ($DEBUG) {
			     foreach (sort keys %smooth_com_h) {
				 print ("Key: $_ and Value: $smooth_com_h{$_} \n");
			     }
			 }
			 # deleting what we don't need
			 @args = (qw/ traj_startfile traj_step
                                      grid_xinc grid_yinc
                                  /);
			 delete $smooth_com_h{$_} for (@args);
			 # writing -A, etc before the value
			 # expect for inputfile, output_format
			 foreach (keys %smooth_com_h) {
			   unless ($_ eq '-inputfile' or $_ eq 'output_format') {
			     $smooth_com_h{$_} = "$_$smooth_com_h{$_}";
			   }
			 }
			 if (exists $smooth_com_h{-V})
			   {$smooth_com_h{-V} = '-V';}
			 if (exists $smooth_com_h{-E})
			   {$smooth_com_h{-E} = '-E';}
			 if (exists $smooth_com_h{-B})
			   {$smooth_com_h{-B} = '-B';}
			 # printing the vars for error checking:
			 #foreach (sort keys %smooth_com_h) {print ("Key: $_ and Value: $smooth_com_h{$_} \n");}
			 # changing lat/lon in input file

			 unless ( -e $smooth_h{-inputfile} ) {
			   print "creating input file for smooth\n" if $DEBUG;
			   open (WSM, "< $mailvarhash{Stress1Data}") or die "Couldn't open $mailvarhash{Stress1Data} for $!";
			   open ( SMOOTH, "> $smooth_h{-inputfile}" ) or die "Couldn't open $smooth_h{inputfile} for $!";
			   while (<WSM>) {
			     chomp;
			     next if /^\s*$/;
			     # reversing: WSM[0] is lon, Smooth[0] must be lat
			     s/^(.*?)\s+(.*?)\s+(.*)$/$2 $1 $3/;
			     print SMOOTH "$_\n";
			   }
			   close (WSM) or die "Couldn't close $mailvarhash{Stress1Data} for $!";
			   close (SMOOTH) or die "Couldn't close $smooth_h{-inputfile} for $!";
			 }

			 @args = ("$Bin/smooth/smooth",
				  $smooth_h{-inputfile});
			 delete $smooth_com_h{-inputfile};
			 foreach (sort keys %smooth_com_h) {
			   push(@args,  $smooth_com_h{$_});
			 }
			 print ("@args\n");
			 # this only works, if there are no uninitialised values
			 system (@args) == 0 or warn "system @args failed: $!";
			 # reset the output_format to whatever it was
			 $smooth_h{output_format} = substr($smooth_h{output_format}, 0,2);

##  };
		       }) -> pack (-side => 'bottom');
  # I don't think we need the ok or the cancel button
  $button_f -> Button (-text => 'OK S.',
		       -command => sub {&$apply_fr();
					$parent_window -> withdraw;
					});# -> pack (-side => 'left');
  $button_f -> Button (-text => 'Cancel',
		       -command => sub {$parent_window -> destroy;}
		       ) -> pack (-side => 'left');
##  $button_f -> Button (-text => 'Fast',
  $button_f -> Button (-text => 'Smooth WSM Stress Data',
		       -command => sub {
			   # extracting only the data points in our region from wsm2000-1.txt
			   my $smooth_small_region = "$startdir/smooth_small_region.dat";
			   my (@line, $corr, $south, $north, $east, $west);
			   # converting degrees to radians by multiplying by (2pi/360) ~ 0.0174533
			   $corr  = $smooth_h{-A}/111;
                           my (@range_tmp) = split('/', $smooth_h{-R});
                           my $west_tmp = $range_tmp[0];
                           my $east_tmp = $range_tmp[1];
                           my $south_tmp = $range_tmp[2];
                           my $north_tmp = $range_tmp[3];
			   $south = $south_tmp - $corr;
			   $north = $north_tmp + $corr;
			   $west  = $west_tmp - $corr / cos(($south_tmp+$north_tmp)/2.*0.0174533);
			   $east  = $east_tmp + $corr / cos(($south_tmp+$north_tmp)/2.*0.0174533);

			   open (FULL_WSM_DATA, "< $mailvarhash{Stress1Data}") or warn "Could not open the wsm data for $!\n";
			   open (SMALL_REGION, "> $smooth_small_region ") or warn "Could not open output file $smooth_small_region for $!";
			   while (<FULL_WSM_DATA>) {
			     chomp;
			     next if ( /^\s+$/ or /^#/ );

			       (@line) = split;

 			       if ($line[1] >= $south  and  $line[1] <= $north
				   and
				   $line[0] >= $west   and  $line[0] <= $east
  				   ) {

				 # filtering according to selection:
				 my ($type, $regime, $qual, $depth, $boundtype, $bounddist, $boundreg, $PBE) =
                                    ($line[3], $line[5], $line[4], $line[6], $line[-2], $line[-1], 'dummy', $line[-3] );
				 # depth - depth is not always $line[6] - because depth fields are empty in the database
                                 next if ($depth==999);
				 if ($mailvarhash{Stress1Depth} eq 'user_defined') {
				   next unless ($depth >= $mailvarhash{S1DepthTop} and
						$depth <= $mailvarhash{S1DepthBot});
				 }
				 # quality
				 next unless ("$qual" ne 'S' and $mailvarhash{"S1Qual$qual"} eq 'y');

				 # type - first changing types so that we can use the quality trick again
				 $type = 'FMS' if ($type =~ m/FMS/i);
				 $type = 'FMA' if ($type =~ m/FMA/i);
				 $type = 'FMF' if ($type =~ m/FMF/i);
				 $type = 'OC'  if ($type =~ m/OC/i);
				 $type = 'BO'  if ($type =~ m/(BO|BOC|BOT)/i);
				 $type = 'DIF' if ($type =~ m/DIF/i);
				 $type = 'BS'  if ($type =~ m/BS/i);
				 $type = 'HF'  if ($type =~ m/(HF|HFG|HFM|HFP|HFS)/i);
				 $type = 'GI'  if ($type =~ m/(PC|GFI|GFM|GFS|GVA)/i);
				 # hopefully all data has a type
				 die "unknown type $type" unless ($type =~ m/(FMS|FMA|FMF|OC|BO|DIF|BS|HF|GI)/i);
				 next unless ($mailvarhash{"S1Type$type"} eq 'y');

				 # regime
				 die "unknown regime $regime" unless ($regime =~ m/(TF|TS|SS|NS|NF|U)/i);
				 next unless ($mailvarhash{"S1_Regime_$regime"} eq 'y');

				 # PBEs
				 $regime = 'SS'  if ($regime =~ m/(SS|NS|TS)/i);
				 $regime = 'NF'  if ($regime =~ m/(NF|NS)/i);
				 $regime = 'TF'  if ($regime =~ m/(TF|TS)/i);
				 $boundreg = 'SS'  if ($boundtype =~ m/(CTF|OTF)/i);
				 $boundreg = 'NF'  if ($boundtype =~ m/(CRB|OSR)/i);
				 $boundreg = 'TF'  if ($boundtype =~ m/(CCB|OCB|SUB)/i);
				 die "unknown boundary type $boundtype" unless ($boundtype =~ m/(CTF|CRB|CCB|OTF|OSR|OCB|SUB)/i);
				 next unless ( !(
                                   ( $mailvarhash{"S1_"."$boundtype"."_exclude_all"} eq 'y' &&
                                     $bounddist<=$mailvarhash{"S1_"."$boundtype"."_exclude_all_distance"} ) ||
                                   ( $mailvarhash{"S1_"."$boundtype"."_exclude_"."$boundreg"} eq 'y' && $regime eq $boundreg &&
                                     $bounddist<=$mailvarhash{"S1_"."$boundtype"."_exclude_"."$boundreg"."_distance"} ) ||
                                   ( $mailvarhash{"S1_"."$boundtype"."_exclude_PBE_events"} eq 'y' && $PBE eq 'PBE' )
                                 ) );
				 

				 
			       # reversing: WSM[0] is lon, Smooth[0] must be lat
				 s/^(.*?)\s+(.*?)\s+(.*)$/$2 $1 $3/;
 				   print SMALL_REGION  "$_\n";
				 if ($DEBUG) {
				   print  "$_\n";
				   print ("Depth: $depth, type: $type, qual: $qual\n");
				 }
			       }
			   }
			   close (FULL_WSM_DATA)
			       or warn "Could not close the wsm data because $!\n";
			   close (SMALL_REGION)
			       or warn "Could not close the small file because $!\n";
			   $smooth_h{-inputfile} = $smooth_small_region;
			   &$apply_fr();

				    }) -> pack (-side => 'left');

} # end of call_smooth_sub

#######################################################
##          Plate Motions                            ##
#######################################################

sub plate_motions {
  if (!Exists $plate_motions_w) {
  
  my ($plate_motions_f, $button_f);
  my (@var_a, %var_h, @plates_a, %plates_h);

  # Initialisation
  @var_a = (qw/ PlateMotions MotionPlates MotionTraj MotionTrajInc
                MotionTrajPen MotionTrajCol/);
  $var_h{$_} = $mailvarhash{$_} for (@var_a);
  @plates_a = (['Africa - Antarctica'        , 1],
	       ['Africa - Eurasia'           , 2],
	       ['Africa - North America'     , 3],
	       ['Africa - South America'     , 4],
	       ['Antarctica - Australia'     , 5],
	       ['Antarctica - Pacific'       , 6],
	       ['Antarctica - South America' , 7],
	       ['Arabia - Eurasia'           , 8],
	       ['India - Eurasia'            , 9],
	       ['Eurasia - North America'    , 10],
	       ['Eurasia - Pacific'          , 11],
	       ['Pacific - Australia'        , 12],
	       ['Pacific - North America'    , 13],
	       ['Cocos - North America'      , 14],
	       ['Nazca - South America'      , 15],
	      );
  $plates_h{@$_[0]} = @$_[1] for(@plates_a);


  # Windows, Frames
  $plate_motions_w = $mw -> Toplevel (-title => 'Plate Motions');
  $plate_motions_f = $plate_motions_w -> Frame -> pack;
  $button_f = $plate_motions_w -> Frame -> pack (-side => 'bottom', -anchor => 'e');

  yes_no ($plate_motions_f, \$var_h{MotionTraj}, 'n');

  heading ($plate_motions_f, 'Motion between');
#   foreach (@plates_a) {
#     $plate_motions_f -> Radiobutton (-text => @$_[0],
# 				     -value => @$_[1],
# 				     -variable => \$var_h{MotionPlates},
# 				     ) -> pack (-anchor => 'w');
#   }
  # mal als hash ausprobieren
  foreach (sort keys %plates_h) {
    $plate_motions_f -> Radiobutton (-text => $_,
				     -value => $plates_h{$_},
				     -variable => \$var_h{MotionPlates},
				     ) -> pack (-anchor => 'w');
  }

  foreach (@{[['Distance between Trajectories', \$var_h{MotionTrajInc}],
	      ['Pen Size'                     , \$var_h{MotionTrajPen}],
	      ['Pen Color and Style'          , \$var_h{MotionTrajCol}],
	      ['Pair Number'                  , \$var_h{MotionPlates}],
	     ]}) {
    $plate_motions_f -> LabEntry (-label => @$_[0],
				  -labelPack => [qw/-side right -anchor w/],
				  -width => 5,
				  -textvariable => @$_[1],
				  ) -> pack (-anchor => 'w');
  }

  # Buttons
  make_buttons($plate_motions_w, $button_f, \%var_h);
}
  else {
    $plate_motions_w -> deiconify;
    $plate_motions_w -> raise;
  }
  
} # end of plate_motions

###################################################
##  sub other_data                               ##
###################################################

sub other_data {
  if (!Exists $other_data_w) {
  
  my ($points_f, $temp_f, $names_f, $temp2_f,
      $text_f, $temp3_f, $polyg_f, $multi_polyg_f, $temp4_f, $button_f);
  my (%var_h, @var_a);

  @var_a = (qw/ Points Point1Data Point1Symbol Point1SymbPenSiz
                Point1SymbPenCol Point1SymbFilCol
                Point1SymbFilCpt Point1SymbCpt
                Names Name1Data Name1Symbol Name1SymbPenSiz Name1SymbPenCol
                Name1SymbFilCol Name1SymbPenCol Name1TextFontSiz
                Name1XShift Name1YShift
                Text TextData TextRecFil TextRecCle TextFilCol
                Polygons Polyg1Data Polyg1PenCol Polyg1PenSiz Polyg1FilCol
             /);
#                  MultiPolygons MPolyg1Data MPolyg1FilIgnore
  $var_h{$_} = $mailvarhash{$_} for (@var_a);

  # Windows, Frames
  $other_data_w = $mw -> Toplevel (-title => 'Other Data');
  foreach ($points_f, $names_f, $polyg_f) {
    $_ = $other_data_w -> Frame -> pack (-side => 'left', -anchor => 'n');
  }
  $text_f = $polyg_f -> Frame -> pack;
  $button_f = $polyg_f -> Frame -> pack (-side => 'bottom', -anchor => 'e');
 # $multi_polyg_f = $polyg_f -> Frame -> pack (-side => 'bottom', -anchor => 'w');
  
  # Point Data
  heading ($points_f, "Point Data", 'w', 'n');
  $temp_f = $points_f -> Frame -> pack (-anchor => 'w');
  # can't use yes_no as values are 1,0
  foreach (@{[['yes', 1], ['no', 0]]}) {
    $temp_f -> Radiobutton (-text => @$_[0],
			    -value => @$_[1],
			    -variable => \$var_h{Points},
			    ) -> pack (-side => 'left');
  }
  
  
  foreach (@{[['Symbol and Symbol Size', \$var_h{Point1Symbol}],
	      ['Pen Size'              , \$var_h{Point1SymbPenSiz}],
	      ['Pen Color'             , \$var_h{Point1SymbPenCol}],
	      ['Filling Color'         , \$var_h{Point1SymbFilCol}],
	     ]}) {
    $points_f -> LabEntry (-label => @$_[0],
			   -labelPack => [qw/-side right -anchor w/],
			   -width => 8,
			   -textvariable => @$_[1],
			   ) -> pack (-anchor => 'w');
  }

  $points_f -> Button (-text => 'Select Point Data File',
		       -command => sub {
			 $var_h{Point1Data} = open_file("Select Point Data File");
		       } ) -> pack (-anchor => 'w');

  $points_f -> Label (-text =>  'CPT Filling for Point Data')
    -> pack (-anchor => 'w');
  foreach ('yes', 'no') {
    $points_f ->Radiobutton (-text => $_,
			     -value => $_,
			     -variable => \$var_h{Point1SymbFilCpt}
			     ) -> pack (-anchor => 'w');
  }
  $points_f -> Button (-text => 'Select Cpt',
		       -command => sub {
			 $var_h{Point1SymbCpt} = open_file("Selecting Cpt for Point Data");
		       } ) -> pack (-anchor => 'w');

  # Names Data - example: city with names
  heading ($names_f, "Names Data", 'w', 'n');
  $temp2_f = $names_f -> Frame -> pack(-anchor => 'w');
  # can't use yes_no as values are 1,0
  foreach (@{[['yes', 1], ['no', 0]]}) {
    $temp2_f -> Radiobutton (-text => @$_[0],
			    -value => @$_[1],
			    -variable => \$var_h{Names},
			    ) -> pack (-side => 'left');
  }
  
  foreach (@{[['Symbol and Symbol Size', \$var_h{Name1Symbol}],
	      ['Pen Size'              , \$var_h{Name1SymbPenSiz}],
	      ['Pen Color'             , \$var_h{Name1SymbPenCol}],
	      ['Filling Color'         , \$var_h{Name1SymbFilCol}],
	      ['Font Size'         , \$var_h{Name1TextFontSiz}],
	      ['X Shift'         , \$var_h{Name1XShift}],
	      ['Y Shift'         , \$var_h{Name1YShift}],
	     ]}) {
    $names_f -> LabEntry (-label => @$_[0],
			   -labelPack => [qw/-side right -anchor w/],
			   -width => 8,
			   -textvariable => @$_[1],
			   ) -> pack (-anchor => 'w');
  }

  $names_f -> Button (-text => 'Select Name Data File',
		       -command => sub {
			 $var_h{Name1Data} = open_file("Select Name Data File");
		       } ) -> pack (-anchor => 'w');

  # Text Data
  heading ($text_f, "Text Data", 'w', 'n');
  yes_no ($text_f, \$var_h{Text});

  foreach (@{[['Rectange beneath text string', \$var_h{TextRecFil}],
	      ['Clearance'              , \$var_h{TextRecCle}],
	      ['Font Color'             , \$var_h{TextFilCol}],
	     ]}) {
    $text_f -> LabEntry (-label => @$_[0],
			   -labelPack => [qw/-side right -anchor w/],
			   -width => 5,
			   -textvariable => @$_[1],
			   ) -> pack (-anchor => 'w');
  }

  $text_f -> Button (-text => 'Select Text Data File',
		       -command => sub {
			 $var_h{TextData} = open_file("Select Text Data File");
		       } ) -> pack (-anchor => 'w');


  # Polyg Data
  heading ($polyg_f, "Polygon Data", 'w', 'n');
  $temp3_f = $polyg_f -> Frame -> pack(-anchor => 'w');
  # can't use yes_no as values are 1,0
  foreach (@{[['yes', 1], ['no', 'n']]}) {
    $temp3_f -> Radiobutton (-text => @$_[0],
			    -value => @$_[1],
			    -variable => \$var_h{Polygons},
			    ) -> pack (-side => 'left');
  }
    
  foreach (@{[['Pen Size'              , \$var_h{Polyg1PenSiz}],
	      ['Pen Color'             , \$var_h{Polyg1PenCol}],
	      ['Filling Color'         , \$var_h{Polyg1FilCol}],
	     ]}) {
    $polyg_f -> LabEntry (-label => @$_[0],
			   -labelPack => [qw/-side right -anchor w/],
			   -width => 8,
			   -textvariable => @$_[1],
			   ) -> pack (-anchor => 'w');
  }

  $polyg_f -> Button (-text => 'Select Polygon File',
		       -command => sub {
			 $var_h{Polyg1Data} = open_file("Select Polygon File");
		       } ) -> pack (-anchor => 'w');

#   # Multiple Polygons
#   heading ($multi_polyg_f, "Multiple Polygons", 'w', 'n');
#   $temp4_f = $multi_polyg_f -> Frame -> pack;
#   # can't use yes_no as values are 1,0
#   foreach (@{[['yes', 1], ['no', 'n']]}) {
#     $temp4_f -> Radiobutton (-text => @$_[0],
# 			    -value => @$_[1],
# 			    -variable => \$var_h{MultiPolygons},
# 			    ) -> pack (-side => 'left');
#   }

#   $multi_polyg_f -> Label (-text => 'Ignore Fill') -> pack (-anchor => 'w');
#   foreach (@{[['yes', 'y'], ['no', 'n']]}) {
#     $multi_polyg_f -> Radiobutton (-text => @$_[0],
# 				   -value => @$_[1],
# 				   -variable => \$var_h{MPolyg1FilIgnore},
# 			    ) -> pack (-anchor => 'w');
#   }

#   $multi_polyg_f -> Button (-text => 'Select Multiple Polygon File',
# 			    -command => sub {
# 			      $var_h{MPolyg1Data} = open_file("Select Multiple Polygon File");
# 			    } ) -> pack (-anchor => 'w');




  
  # Buttons
  make_buttons($other_data_w, $button_f, \%var_h);
}
  else {
    $other_data_w -> deiconify;
    $other_data_w -> raise;
  }

} # end of other_data


##########################################################
##   cmt solutions                                       #
##   assumes input file is in harvard cmt psmeca format  #
##########################################################


sub cmt {
  if (!Exists $cmt_w) {
  
  my ($cmt_f, $button_f);
  my (%var_h, @var_a);

  @var_a = (qw/ CMTFile PlotCMT CMTPlotType CMTScale CMTFontSize
                CMTOffset CMTHeader CMTThrustFill CMTExtFill/);
  $var_h{$_} = $mailvarhash{$_} for (@var_a);
  
  # Windows, Frames
  $cmt_w = $mw -> Toplevel (-title => 'CMT Solutions');
  $cmt_f = $cmt_w -> Frame -> pack;
  $button_f = $cmt_w -> Frame -> pack (-side => 'bottom', -anchor => 'e');

  heading ($cmt_f, "Plotting CMT Data", 'w', 'n');
  yes_no ($cmt_f, \$var_h{PlotCMT});

  foreach (@{[['Only Double Couple', 'd'], ['Full CMT S.', 'm']]}) {
    $cmt_f -> Radiobutton (-text => @$_[0],
			    -value => @$_[1],
			    -variable => \$var_h{CMTPlotType},
			    ) -> pack (-anchor => 'w');
  }


  
  foreach (@{[['Scale'                  , \$var_h{CMTScale}],
	      ['Font Size'              , \$var_h{CMTFontSize}],
	      ['Offset'                 , \$var_h{CMTOffset}],
	      ['Header lines'           , \$var_h{CMTHeader}],
	      ['Thrust Fill Color'      , \$var_h{CMTThrustFill}],
	      ['Extension Fill Color'   , \$var_h{CMTExtFill}],
	     ]}) {
    $cmt_f -> LabEntry (-label => @$_[0],
			 -labelPack => [qw/-side right -anchor w/],
			 -width => 5,
			 -textvariable => @$_[1],
			) -> pack (-anchor => 'w');
  }

  $cmt_f -> Button (-text => 'Select CMT Data File',
		     -command => sub {
		       $var_h{CMTFile} = open_file("Select CMT Data File");
		     } ) -> pack (-anchor => 'w');


  # Buttons
  make_buttons ($cmt_w, $button_f, \%var_h);
}
  else {
    $cmt_w -> deiconify;
    $cmt_w -> raise;
  }

}


#####################################
#   sub show_map                   ##
#   par: image_file_name           ##
#####################################

sub show_map {
  my ($image_file) = @_;
  my $image = $canvas_w -> Photo('IMG', -file => $image_file);
  $canvas_w -> create ('image',0,0, -image => $image, -anchor => 'nw');
} # end of sub show_map

######################################################
##    sub check_range                                #
##    checks if the range var are sensible           #
##    par: $north, $south, $east, $west, $proj_name  #
##    returns 1 if everything is fine, 0 else        #
##    if 0:          error window pops up            #
######################################################

sub check_range{
  my ($north, $south, $east, $west, $proj_name) = @_;
  my $err_mess = "";
  my $ERROR = 0;
  if ($DEBUG) {print ("\@ ist @_ \n");}
  
  # checking for possible errors
  if ( abs($south) > 90 || abs($north) > 90 || abs($west) > 360 || abs ($east) > 360 ) {
    $err_mess = "Please give sensible Numbers";
    err_win($err_mess);
  } elsif ($north < $south) {
    $err_mess = "North must be greater than south";
    err_win($err_mess);
  } elsif ($west > $east) {
    $err_mess = "West must be smaller than east";
    err_win($err_mess);
  } 
  # conical projections can't have stan1_lat eq stan2_lat
  elsif (($proj_name eq 'Lambert_Conic_Conformal'
	  or $proj_name eq 'Albers_Conic_Equal-Area')
	 and $south == -$north
	 and $mailvarhash{stan1_pro} eq 'default'
	 and $mailvarhash{stan2_pro} eq 'default') {
      # therefore we set stan1_pro and stan2_pro instead of the user
      # works not (or not tested) with minutes/seconds
      # don't use $mailvarhash{c1_lat} but $north/south as these are the actual values
      my $lat_range_third = ($north - $south)/3.0;
      $mailvarhash{stan1_pro} = $south + $lat_range_third + 1;
      $mailvarhash{stan2_pro} = $north - $lat_range_third;
      # set $ERROR to 1 so that the changes are applied - after seeing the map the user will probably be changing quite quickly
      $ERROR = 1;
#    $err_mess = 'Please change standart parallels via the Change default Button\n Conic Projections cannot have the upper standart parallel eq the lower one';
      $err_mess = "Changed Standart Parallels from default to $mailvarhash{stan1_pro} and $mailvarhash{stan2_pro} \n";
      err_win($err_mess);
  }
  # Lambert Azimuthal can't plot whole earth
  elsif ($proj_name eq 'Lambert_Azimuthal_Equal-Area'
	 and ($east - $west) >= 90,
	) {

    $err_mess = 'Please select smaller area for this projection';
    err_win($err_mess);
  }

  elsif ($proj_name eq 'Mercator'
	and (abs($south) > 80 or abs($north) > 80) ) {
    err_win ("Mercator Projection cannot be used with these $north and $south values \n");
  }
  # falls er hier ankommt ist alles ok
  else {
    if ($DEBUG) {print ("@_ ok \n");}
    $ERROR = 1;
  }
  return $ERROR;
}				# end of sub check_range

########################################
# sub: yes_no                          #
# par: yes_no($frame, \$var; $anchor)  #
# sets the var to 'y' or 'n'           #
########################################

sub yes_no{
  my ($frame, $var_ref, $anchor) = @_;
  my ($temp_frame);
  # $anchor == n -> therefor we need some space above it
  if (defined $anchor) {$frame -> Label (-text => '',
				     -font => $small_font) -> pack;
		    } else {$anchor = 'w';}
  # frame to align yes/no Radiobuttons
  $temp_frame = $frame -> Frame -> pack (-anchor => "$anchor");
  # Initialising
  foreach (qw/yes no/){
    $temp_frame -> Radiobutton (-text => $_,
			   -value => substr ($_, 0, 1),
			   -variable => $var_ref,
				)-> pack (-side => 'left', -anchor => 'w');
  }
  return 1;
} #end of sub yes_no

###################################################
#     Window to report Errors of the user         #
#     par: error message string                   #
###################################################

sub err_win{
  # the message containing the error should be in @_
  my $error_w = $mw -> Toplevel (-title => 'Message');
  $error_w -> Message (-text => @_) -> pack(-fill => 'x', -expand => 1);
  $error_w -> Button (-text => "Close", -command => sub{withdraw $error_w})
    -> pack();
}

#############################################
#    sub extra_frame                        #
#    par: $parent_window                    #
#    frame which contains empty space       #
#    to bring some space between objects    #
#############################################
sub extra_frame{
  my ($parent_window) = @_;
  my ($frame,);

  $frame = $parent_window -> Frame() -> pack (-side => 'left');
  $frame -> Label (-text => "         ") -> pack;
}

###############################################
#  sub heading                                #
#  par: $parent_window, $string; $anchor, $sep #
#  the string is put via Label (ueberschrift  #
#  in the parent window                       #
###############################################

sub heading{
    my ($parent_window, $string, $anchor, $sep) = @_;


    if (! defined $anchor) {$anchor = 'w';}
    if (! defined $sep) {$sep = 'y';}
    if ($sep eq 'y'){
	$parent_window -> Label (-text => " ",-font => $small_font,)-> pack();
    }
    $parent_window -> Label (-text => "$string",
			     -font => 'ueberschrift',
			     -pady => '1',
			     ) -> pack (-anchor => "$anchor");
}

sub col_heading{
    my ($parent_window, $string, $anchor) = @_;

    if (! defined $anchor) {$anchor = 'w';}
    $parent_window -> Label (-text => "$string",
			     -pady => '0',
			     ) -> pack (-anchor => "$anchor");
}

sub col_heading_red{
    my ($parent_window, $string, $anchor) = @_;

    if (! defined $anchor) {$anchor = 'w';}
    $parent_window -> Label (-text => "$string",
			     -pady => '0',
                             -foreground => 'red',
			     ) -> pack (-anchor => "$anchor");
}

#############################################
## sub: open_file                          ##
## par: title; ext                         ##
## returns filename or ''                  ##
#############################################


sub open_file {
  my ($title, $filename, $ext,);
  ($title, $ext) = @_;
  if  (! defined $ext) {$ext = '*';}
  ($filename) = $mw -> getOpenFile (-title => $title,);
  return $filename;
}

#######################################################
##  sub: make_buttons                                 #
##  par: $window, $frame, $hash_r                     #
##  this routine does some error checking,            #
##  but if the vars are in several hashes/arrays      #
##  we cannot use it                                  #
##  mainly because i don't know                       #
##  how to pull them all together                     #
#######################################################

sub make_buttons {

  my ($window, $frame, $hash_r) = @_;

  $frame -> Button (-text => 'Cancel',
		    -command => sub {$window -> destroy;
				     $window = undef;
				     #print "Window ist $main::window\n";
				     #$main::window = 'undef';
				   }
		   ) -> pack (-side => 'left');
  $frame -> Button (-text => 'Apply',
		   -command => sub{
		     foreach (keys %$hash_r) {
		       if ($hash_r->{$_} ne '') {
			 $mailvarhash{$_} = $hash_r->{$_};
			 print("Key ist $_ und Value: $mailvarhash{$_} \n") if $DEBUG;
		       }
		     }
		   }) -> pack (-side => 'left');
  $frame -> Button (-text => 'Ok',
		    -command => sub {
		      foreach (keys %$hash_r) {
			# if another file is selected and then cancelled
			# we don't want to overwrite the original with ''
			if ($hash_r->{$_} ne '') {
			  $mailvarhash{$_} = $hash_r -> {$_};
			   print("Key ist $_ und Value: $mailvarhash{$_} \n") if $DEBUG;
			}
		      }
		      $window -> withdraw;
		    }) -> pack (-side => 'left');
} # end of sub: make_buttons

sub make_data_default_button {

  my ($window, $frame, $hash_r) = @_;

  $frame -> Button (-text => 'Apply Default Settings',
		    -command => sub {
                      $hash_r->{'S1TypeFMS'} = 'y';
                      $hash_r->{'S1TypeFMA'} = 'y';
                      $hash_r->{'S1TypeFMF'} = 'y';
                      $hash_r->{'S1TypeBO'} = 'y';
                      $hash_r->{'S1TypeOC'} = 'y';
                      $hash_r->{'S1TypeHF'} = 'y';
                      $hash_r->{'S1TypeGI'} = 'y';
                      $hash_r->{'S1TypeDIF'} = 'y';
                      $hash_r->{'S1TypeBS'} = 'y';
                      $hash_r->{'S1_Regime_TF'} = 'y';
                      $hash_r->{'S1_Regime_TS'} = 'y';
                      $hash_r->{'S1_Regime_SS'} = 'y';
                      $hash_r->{'S1_Regime_NS'} = 'y';
                      $hash_r->{'S1_Regime_NF'} = 'y';
                      $hash_r->{'S1_Regime_U'} = 'y';
                      $hash_r->{'S1_CTF_exclude_all'} = 'n';            #CTF
                      $hash_r->{'S1_CTF_exclude_all_distance'} = '200';
                      $hash_r->{'S1_CTF_exclude_SS'} = 'n';
                      $hash_r->{'S1_CTF_exclude_SS_distance'} = '200';
                      $hash_r->{'S1_CTF_exclude_PBE_events'} = 'y';
                      $hash_r->{'S1_CRB_exclude_all'} = 'n';            #CRB
                      $hash_r->{'S1_CRB_exclude_all_distance'} = '200';
                      $hash_r->{'S1_CRB_exclude_NF'} = 'n';
                      $hash_r->{'S1_CRB_exclude_NF_distance'} = '200';
                      $hash_r->{'S1_CRB_exclude_PBE_events'} = 'y';
                      $hash_r->{'S1_CCB_exclude_all'} = 'n';            #CCB
                      $hash_r->{'S1_CCB_exclude_all_distance'} = '200';
                      $hash_r->{'S1_CCB_exclude_TF'} = 'n';
                      $hash_r->{'S1_CCB_exclude_TF_distance'} = '200';
                      $hash_r->{'S1_CCB_exclude_PBE_events'} = 'y';
                      $hash_r->{'S1_OTF_exclude_all'} = 'n';            #OTF
                      $hash_r->{'S1_OTF_exclude_all_distance'} = '200';
                      $hash_r->{'S1_OTF_exclude_SS'} = 'n';
                      $hash_r->{'S1_OTF_exclude_SS_distance'} = '200';
                      $hash_r->{'S1_OTF_exclude_PBE_events'} = 'y';
                      $hash_r->{'S1_OSR_exclude_all'} = 'n';            #OSR
                      $hash_r->{'S1_OSR_exclude_all_distance'} = '200';
                      $hash_r->{'S1_OSR_exclude_NF'} = 'n';
                      $hash_r->{'S1_OSR_exclude_NF_distance'} = '200';
                      $hash_r->{'S1_OSR_exclude_PBE_events'} = 'y';
                      $hash_r->{'S1_OCB_exclude_all'} = 'n';            #OCB
                      $hash_r->{'S1_OCB_exclude_all_distance'} = '200';
                      $hash_r->{'S1_OCB_exclude_TF'} = 'n';
                      $hash_r->{'S1_OCB_exclude_TF_distance'} = '200';
                      $hash_r->{'S1_OCB_exclude_PBE_events'} = 'y';
                      $hash_r->{'S1_SUB_exclude_all'} = 'n';            #SUB
                      $hash_r->{'S1_SUB_exclude_all_distance'} = '200';
                      $hash_r->{'S1_SUB_exclude_TF'} = 'n';
                      $hash_r->{'S1_SUB_exclude_TF_distance'} = '200';
                      $hash_r->{'S1_SUB_exclude_PBE_events'} = 'y';
                      $hash_r->{'S1QualA'} = 'y';
                      $hash_r->{'S1QualB'} = 'y';
                      $hash_r->{'S1QualC'} = 'y';
                      $hash_r->{'S1QualD'} = 'n';      
                      $hash_r->{'S1QualE'} = 'n';      
                      $hash_r->{'S1DepthTop'} = '0';     
                      $hash_r->{'S1DepthBot'} = '40';
                      $hash_r->{'Stress1Depth'} = 'all';
		      foreach (keys %$hash_r) {
			if ($hash_r->{$_} ne '') {
			  $mailvarhash{$_} = $hash_r -> {$_};
			  print("Key ist $_ und Value: $mailvarhash{$_} \n") if $DEBUG;
			}
		      }
		    }) -> pack (-side => 'left');
} # end of sub: make_data_default_button

sub open_help {
  $proc->start (sub { exec ("acroread", "$Bin/DOCUMENTATION/help.pdf");});
  $SIG{CHLD} = sub {wait; }
}

sub open_info {
  $proc->start (sub { exec ("acroread", "$Bin/DOCUMENTATION/info.pdf");});
  $SIG{CHLD} = sub {wait; }
}
  
MainLoop;


