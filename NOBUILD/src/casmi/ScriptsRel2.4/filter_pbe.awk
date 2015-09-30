# Daniel Kurfess, 2008-03
#
# filter out FMS events that may be PBEs (Plate Boundary Events),
# based on user criteria or the PBE flag set by the WSM team
#
# File format:
#        col. 1: longitude (deg) new calculated point 99 km away
#        col. 2: latitude (deg) new calculated point 99 km away
#        col. 3: longitude (deg) original location 
#        col. 4: latitude (deg) original location
#        col. 5: azimuth of stress direction (deg)
#        col. 6: type 
#        col. 7: quality 
#        col. 8: regime 
#        col. 9: depth
#        col. 10: sitecode
#        col. 11: 'PBE'/'no' (flag, data preselected as PBE by WSM team)
#        col. 12: type of nearest plate boundary
#        col. 13: distance to nearest plate boundary
#
# Passed by command line are the following informations
# temp PBE_Filter
# S_CTF_ex_all S_CTF_ex_all_dist S_CTF_ex_SS S_CTF_ex_SS_dist
#  S_CTF_ex_PBE
# S_CRB_ex_all S_CRB_ex_all_dist S_CRB_ex_NF S_CRB_ex_NF_dist
#  S_CRB_ex_PBE
# S_CCB_ex_all S_CCB_ex_all_dist S_CCB_ex_TF S_CCB_ex_TF_dist
#  S_CCB_ex_PBE
# S_OTF_ex_all S_OTF_ex_all_dist S_OTF_ex_SS S_OTF_ex_SS_dist
#  S_OTF_ex_PBE
# S_OSR_ex_all S_OSR_ex_all_dist S_OSR_ex_NF S_OSR_ex_NF_dist
#  S_OSR_ex_PBE
# S_OCB_ex_all S_OCB_ex_all_dist S_OCB_ex_TF S_OCB_ex_TF_dist
#  S_OCB_ex_PBE
# S_SUB_ex_all S_SUB_ex_all_dist S_SUB_ex_TF S_SUB_ex_TF_dist
#  S_SUB_ex_PBE
# which are set to values depending on the choice
# of the user.


{ 
  ntotal++

  if ($12 == "CTF")
  {
    if ( !( \
      ( (S_CTF_ex_all=="y") && ($13<=S_CTF_ex_all_dist) ) || \
      ( (S_CTF_ex_SS=="y") && ($8=="SS" || $8=="NS" || $8=="TS") && \
        ($13<=S_CTF_ex_SS_dist) ) || \
      ( (S_CTF_ex_PBE=="y") && ($11==PBE_Filter) )   ) )
    {
      print
      nsel++
    }
  }

  if ($12 == "CRB")
  {
    if ( !( \
      ( (S_CRB_ex_all=="y") && ($13<=S_CRB_ex_all_dist) ) || \
      ( (S_CRB_ex_NF=="y") && ($8=="NF" || $8=="NS") && \
        ($13<=S_CRB_ex_NF_dist) ) || \
      ( (S_CRB_ex_PBE=="y") && ($11==PBE_Filter) )   ) )
    {
      print
      nsel++
    }
  }

  if ($12 == "CCB")
  {
    if ( !( \
      ( (S_CCB_ex_all=="y") && ($13<=S_CCB_ex_all_dist) ) || \
      ( (S_CCB_ex_TF=="y") && ($8=="TF" || $8=="TS") && \
        ($13<=S_CCB_ex_TF_dist) ) || \
      ( (S_CCB_ex_PBE=="y") && ($11==PBE_Filter) )   ) )
    {
      print
      nsel++
    }
  }

  if ($12 == "OTF")
  {
    if ( !( \
      ( (S_OTF_ex_all=="y") && ($13<=S_OTF_ex_all_dist) ) || \
      ( (S_OTF_ex_SS=="y") && ($8=="SS" || $8=="NS" || $8=="TS") && \
        ($13<=S_OTF_ex_SS_dist) ) || \
      ( (S_OTF_ex_PBE=="y") && ($11==PBE_Filter) )   ) )
    {
      print
      nsel++
    }
  }

  if ($12 == "OSR")
  {
    if ( !( \
      ( (S_OSR_ex_all=="y") && ($13<=S_OSR_ex_all_dist) ) || \
      ( (S_OSR_ex_NF=="y") && ($8=="NF" || $8=="NS") && \
        ($13<=S_OSR_ex_NF_dist) ) || \
      ( (S_OSR_ex_PBE=="y") && ($11==PBE_Filter) )   ) )
    {
      print
      nsel++
    }
  }

  if ($12 == "OCB")
  {
    if ( !( \
      ( (S_OCB_ex_all=="y") && ($13<=S_OCB_ex_all_dist) ) || \
      ( (S_OCB_ex_TF=="y") && ($8=="TF" || $8=="TS") && \
        ($13<=S_OCB_ex_TF_dist) ) || \
      ( (S_OCB_ex_PBE=="y") && ($11==PBE_Filter) )   ) )
    {
      print
      nsel++
    }
  }

  if ($12 == "SUB")
  {
    if ( !( \
      ( (S_SUB_ex_all=="y") && ($13<=S_SUB_ex_all_dist) ) || \
      ( (S_SUB_ex_TF=="y") && ($8=="TF" || $8=="TS") && \
        ($13<=S_SUB_ex_TF_dist) ) || \
      ( (S_SUB_ex_PBE=="y") && ($11==PBE_Filter) )   ) )
    {
      print
      nsel++
    }
  }

}
END {
  if (nsel == 0) {
    print " PBE settings allow no FMS data " > temp"/info.filter_pbe"
    print " total number of data processed: " ntotal >> temp"/info.filter_pbe"
  }
  else {
    print "    " nsel " out of " ntotal " data points were not filtered by PBE settings and selected " > temp"/info.filter_pbe"
  }
}
