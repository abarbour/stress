#
# read in stress data file and remove columns 7, 8 and 9.
# also: interchange longitude and latitude (this is for GMT).
# the output contains:
# 
#
# Format of Input File (New format for ESM/WSM: NF = 8 or NF = 9):
#      col 1: lat
#      col 2: lon
#      col 3: azimuth
#      col 4: type
#      col 5: quality
#      col 6: stress regime
#      col 7: depth (not yet evaluated)
#      col 8-9: site (site field of the ESM/WSM often contains blanks,
#             so awk then interprets this field as two colums!)
#
# Format of Output File:
#      col 1: lon
#      col 2: lat
#      col 3: azimuth
#      col 4: type
#      col 5: quality
#      col 6: stress regime
#      col 7: depth (not yet evaluated)
#      col 8: site (blanks are removed now)
#      col 9: PBE Event
#           


{
  printf("%8.3f %8.3f %3d %3s %1s %2s %7.3f %s%s %s %s %8.2f \n",$2,$1,$3,$4,$5,$6,$7,$8,$9, $10, $11,$12)
}
