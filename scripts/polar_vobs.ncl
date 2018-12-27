;**************************************
;contour plots
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/glade/work/aherring/CESM2/arh-git-scripts/ncl/se_func_lib.ncl"
;**************************************
begin
;****************************************

  polar = True
  manlevs = True
  seover = False
  onemnth = False
  nstart = 0

  plotvar = "TREFHT"
  dir = "/glade/scratch/lvank/archive/"
  fname = (/"c2b8_UNI_fdm.004", \
	    "c2b8_VRGRN_28.003", \
	    "c2b8_VRGRN_28.005"/)
  fincl = "h0"
  nfiles = dimsizes(fname)

  labels = (/"ne30", \
             "ne30-VR-ne120", \
             "ne30-VR-ne120-new"/)

  obsvar = "TREFHT_LAND"
  ofactor = 1.
  obsdir = "/gpfs/fs1/p/cesm/amwg/amwg_data/obs_data/"
  wgtpath = "/glade/work/aherring/grids/grid_files/bilin/"

  obsname = "NCEP_JJA_climo.nc"
  title = "1980-1989 JJA Climo vs. NCEP JJA Climo (1979-1998)"
  wgtfile = (/wgtpath + "ne30_2_64x128.nc-bilin.nc", \
   	      wgtpath + "ne0G30-60-120_2_64x128.nc-bilin.nc", \
   	      wgtpath + "ne0G30-60-120_2_64x128.nc-bilin.nc"/)

  ;;obsname = "MERRA_JJA_climo.nc"
  ;;title = "1980-1989 JJA Climo vs. MERRA JJA Climo (1979-2013)"
  ;;wgtfile = (/wgtpath + "ne30_2_361x540.nc-bilin.nc", \
  ;;            wgtpath + "ne0G30-60-120_2_361x540.nc-bilin.nc", \
  ;;            wgtpath + "ne0G30-60-120_2_361x540.nc-bilin.nc"/)

  ;;obsname = "ERA40_JJA_climo.nc"
  ;;title = "1980-1989 JJA Climo vs. ERA40 JJA Climo (1980-2001)"
  ;;wgtfile = (/wgtpath + "ne30_2_73x144.nc-bilin.nc", \
  ;;            wgtpath + "ne0G30-60-120_2_73x144.nc-bilin.nc", \
  ;;            wgtpath + "ne0G30-60-120_2_73x144.nc-bilin.nc"/)

  ;;obsname = "LEGATES_JJA_climo.nc"
  ;;title = "1980-1989 JJA Climo vs. Legates and Willmott JJA Climo (1920-1980)"
  ;;wgtfile = (/wgtpath + "ne30_2_64x128.nc-bilin.nc", \
  ;;            wgtpath + "ne0G30-60-120_2_64x128.nc-bilin.nc", \
  ;;            wgtpath + "ne0G30-60-120_2_64x128.nc-bilin.nc"/)

  ;;obsname = "WILLMOTT_JJA_climo.nc"
  ;;title = "1980-1999 JJA Climo vs. Willmott and Matsuura JJA Climo (1950-1999)"
  ;;wgtfile = (/wgtpath + "ne30_2_180x360.nc-bilin.nc", \
  ;;            wgtpath + "ne0G30-60-120_2_180x360.nc-bilin.nc", \
  ;;            wgtpath + "ne0G30-60-120_2_180x360.nc-bilin.nc"/)

  secpday = 60.*60.*24;
  pi = 3.14159265358979
  g = 9.80616 ;m/s2
  Re = 6371.22
  cp = 1004.
  Rd = 287.
  p0 = 1000.d2

  var3d = False
  wkstype = "pdf"
  wkstype@wkBackgroundOpacityF = 0.
  plotNam = "temp_" + plotvar
  wks = gsn_open_wks(wkstype,plotNam)
  if (plotvar.eq."PSL") then
    gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    cmin = -5. 
    cmax =  5. 
    cspc =  0.05
    varNam = plotvar
    factor = 1./100.
  else if (plotvar.eq."PHIS") then
    gsn_define_colormap(wks,"BkBlAqGrYeOrReViWh200")
    cmin =     0.
    cmax = 40000.
    cspc =  1000.
    varNam = plotvar
    factor = 1.
  else if (plotvar.eq."Z3") then
    gsn_define_colormap(wks,"hotcolr_19lev")
    cmin = -50.
    cmax =  50.
    cspc =   5.
    varNam = "Z500"
    factor = 1.
    var3d = True
    pout = 500.d2
  else if (plotvar.eq."T") then
    gsn_define_colormap(wks,"hotcolr_19lev")
    cmin = -2.
    cmax =  2.
    cspc =   .2
    varNam = "T500"
    factor = 1.
    var3d = True
    pout = 500.d2
  else if (plotvar.eq."TREFHT") then
    gsn_define_colormap(wks,"hotcolr_19lev")
    cmin = -5.
    cmax =  5.
    cspc =   .5
    varNam = plotvar
    factor = 1.
  end if
  end if
  end if
  end if
  end if

;************** 
;graphics stuff
;**************
  plot = new( (/nfiles/), graphic)
  setvalues NhlGetWorkspaceObjectId()
      "wsMaximumSize": 500000000
  end setvalues

   res             = True
   res@gsnMaximize = False
   res@gsnDraw     = False      ; Will draw later, after overlaying
   res@gsnFrame    = False      ; all plots

   res@cnFillMode = "AreaFill"
   res@cnFillOn          = True               ; turn on color fill
   res@cnLinesOn         = False
   res@gsnSpreadColors   = True               ; use full range of color map
   res@cnLineLabelsOn       = False
   res@cnInfoLabelOn        = False

   res@lbLabelBarOn         = False

   if (polar) then
     res@gsnPolar             = "NH"                 ; specify the hemisphere
     res@mpFillOn         = True
     res@mpCenterLonF         = -10
     res@mpMinLatF         = 50.
     res@mpGridAndLimbOn   = False
     ;res@mpGridLatSpacingF    = 20.                ; change latitude  line spacing
     ;res@mpGridLonSpacingF    = 20.                ; change longitude line spacing
     ;res@gsnPolarLabelSpacing = 60                   ; how frequently to label
   else
     res@mpCenterLonF = 180.
     res@mpOutlineOn          = False    ; turn off continental outline
     res@mpFillOn             = False
     res@mpGridAndLimbOn   = False           ; turn on lat/lon lines
     ;res@mpGridLatSpacingF = 10.
     ;res@mpGridLonSpacingF = 30.
     ;res@mpGridLineColor      = -1
     res@mpPerimOn         = False               ; turn off perimeter
     res@mpFillOn         = False
     res@mpOutlineBoundarySets     = "NoBoundaries"
   end if

   if (seover) then
     res@mpGreatCircleLinesOn=True
   end if

;************
;Main Loop
;************
 do n = 0,nfiles-1

 if (n.eq.0) then
   print("grab obs...")
   print(":"+obsname)
   obs = addfile(obsdir+obsname,"r") 
   tmp = obs->$obsvar$

   if (.not.var3d) then
     bar0 = tmp(0,:,:)
     ;;bar0 = tmp ;;<--for Willmott and Matsuura only
   else if (var3d) then
     print("interploate to constant pressure lev...")
     lev = obs->lev
     lev3d = conform(tmp(0,:,:,:),lev,0)

     linlog = 2
     tmp0 = int2p_n(lev3d,tmp(0,:,:,:),(/pout/100./),linlog,0)
     bar0 = tmp0(0,:,:)
     delete([/tmp0,lev3d,lev/])
   end if
   end if
   delete([/obs,tmp/])  
   bar0 = bar0*ofactor
   print("max obs: " + max(bar0))
   print("min obs: " + min(bar0))
 end if

 print("begin case "+n)

 ;load all files
 files = systemfunc ("ls " + dir + fname(n) + "/atm/hist/" + fname(n) + ".cam."+fincl+"*")
 nf = dimsizes(files)
 nf = 120 ;;<--comment out for all years
 if (onemnth) then
   nfinish = nstart
 else
   nfinish = nf-1
 end if

 newfiles = new((/nf*3/12/),string)
 do t = 0,nf/12 - 1
   newfiles(3*t+0) = files(12*t+5)
   newfiles(3*t+1) = files(12*t+6)
   newfiles(3*t+2) = files(12*t+7)
 end do
 delete(files)

 print("load files...")
 print(":"+newfiles)
 f  = addfiles (newfiles,"r")
 ListSetType(f,"cat")
 delete(newfiles)

 if (isfilevardim(f[0],plotvar,"ncol")) then
   latlon = False
   print("history fields on native se-grid")
 else if (isfilevardim(f[0],plotvar,"lat")) then
   latlon = True
   print("history fields on latlon grid")
 end if
 end if

 print("Grab var...")
 var = f[:]->$plotvar$

 if (var3d) then
   print("interploate to constant pressure lev...")
   ps = f[:]->PS
   hyam = f[0]->hyam
   hybm = f[0]->hybm
   pm = se_pressure(ps,p0,hyam,hybm,0)

   linlog = 2
   var2d = int2p_n(pm,var,(/pout/),linlog,1)
   delete([/var,pm,ps/])
   var = var2d(:,0,:)
   delete(var2d)
 end if
 delete(f)
 var = factor*var

 print("Averaging...")
 bar = dim_avg_n(var,0)
 delete(var)

 if (.not.latlon) then
   print("remap to obs grid...")
   bar_regrid = ESMF_regrid_with_weights(bar,wgtfile(n),False) 
   delete(bar)
 else
   ;;not used
 end if

 print("max run: " + max(bar_regrid))
 print("min run: " + min(bar_regrid))

 ;;diff with obs
 bar_regrid = bar_regrid - bar0

 ;;;rmse
 lat = bar_regrid&lat
 indy = ind(lat.ge.60.d0)
 tmp = bar_regrid(indy,:)^2.
 wgty = cos(lat(indy)*pi/180.)
 rmse = wgt_areaave(tmp,wgty,1.0,0)
 rmse = sqrt(rmse)
 bar_regrid@long_name = "RMSE(.ge.60N) = " + tostring(rmse)
 delete([/tmp,rmse,wgty,indy,lat/])

 print("max anom: " + max(bar_regrid))
 print("min anom: " + min(bar_regrid))

 print("Plotting...")
 if (manlevs) then
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF  = cmin
   res@cnMaxLevelValF  = cmax
   res@cnLevelSpacingF = cspc
 else
   print("manual levels set to False")
   print("max var " + max(bar_regrid))
   print("min var " + min(bar_regrid))
   mxmmn = max(bar_regrid)-min(bar_regrid)
   print("max - min " + mxmmn)
 end if

 if (polar) then
   plot(n) = gsn_csm_contour_map_polar(wks,bar_regrid,res)
 else
   plot(n) = gsn_csm_contour_map(wks,bar_regrid,res)
 end if

 if (seover) then
   if (n.eq.0) then
     opt = False
   else
     opt = True
   end if
   overlay_se_grid(wks,plot(n),opt)
 end if

 delete(bar_regrid)
 ;;delete([/lat1d,lon1d/])

end do ;nfiles

;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot

  resP@gsnPanelMainString = title

  resP@gsnPanelFigureStrings = labels
  resP@gsnPanelFigureStringsFontHeightF = 0.010
  resP@gsnPanelFigureStringsPerimOn     = True
  resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  resP@amJust           = "TopRight"

  resP@gsnPanelLabelBar = True
  resP@lbBoxSeparatorLinesOn = False
  resP@gsnPanelBottom   = 0.1
  resP@lbTitleString              = varNam
  resP@lbTitlePosition            = "Top"
  resP@lbTitleFontHeightF         = 0.0084
  resP@lbLabelFontHeightF         = 0.008

  resP@pmLabelBarOrthogonalPosF = -0.01
  resP@pmLabelBarParallelPosF = 0.

  ;resP@gsnPanelTop        = 0.97
  resP@gsnPanelBottom     = 0.1
  ;resP@gsnPanelRight     = 0.9007;
  ;resP@gsnPanelLeft     = 0.40        ; position of left most plot
  gsn_panel(wks,plot,(/1,nfiles/),resP)      

frame(wks)

end



