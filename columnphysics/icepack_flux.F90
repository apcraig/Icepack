!=======================================================================

! Flux manipulation routines for column package
!
! author Elizabeth C. Hunke, LANL
!
! 2014: Moved subroutines merge_fluxes, set_sfcflux from ice_flux.F90

      module icepack_flux

      use icepack_kinds
      use icepack_parameters, only: c1, emissivity, snwgrain
      use icepack_warnings, only: warnstr, icepack_warnings_add
      use icepack_warnings, only: icepack_warnings_setabort, icepack_warnings_aborted
      use icepack_tracers, only: tr_iso, tr_pond

      implicit none
      private
      public :: merge_fluxes, set_sfcflux

!=======================================================================

      contains

!=======================================================================

! Aggregate flux information from all ice thickness categories
!
! author: Elizabeth C. Hunke and William H. Lipscomb, LANL

      subroutine merge_fluxes (aicen,                &
                               flw, &
                               strairxn, strairyn,   &
                               Cdn_atm_ratio_n,      &
                               fsurfn,   fcondtopn,  &
                               fcondbotn,            &
                               fsensn,   flatn,      &
                               fswabsn,  flwoutn,    &
                               evapn,                &
                               evapsn,   evapin,     &
                               Trefn,    Qrefn,      &
                               freshn,   fsaltn,     &
                               fhocnn,   fswthrun,   &
                               fswthrun_vdr, fswthrun_vdf,&
                               fswthrun_idr, fswthrun_idf,&
                               fswthrun_uvrdr, fswthrun_uvrdf,&
                               fswthrun_pardr, fswthrun_pardf,&
                               strairxT, strairyT,   &
                               Cdn_atm_ratio,        &
                               fsurf,    fcondtop,   &
                               fcondbot,             &
                               fsens,    flat,       &
                               fswabs,   flwout,     &
                               evap,                 &
                               evaps,    evapi,      &
                               Tref,     Qref,       &
                               fresh,    fsalt,      &
                               fhocn,    fswthru,    &
                               fswthru_vdr, fswthru_vdf,&
                               fswthru_idr, fswthru_idf,&
                               fswthru_uvrdr, fswthru_uvrdf,&
                               fswthru_pardr, fswthru_pardf,&
                               melttn, meltsn, meltbn, congeln, snoicen, &
                               meltt,  melts,        &
                               meltb,  dsnow, dsnown,&
                               congel,  snoice,      &
                               meltsliq, meltsliqn,  &
                               Uref,     Urefn,      &
                               Qref_iso, Qrefn_iso,  &
                               fiso_ocn, fiso_ocnn,  &
                               fiso_evap, fiso_evapn,&
                               dpnd_flush,   dpnd_flushn,   &
                               dpnd_expon,   dpnd_exponn,   &
                               dpnd_freebd,  dpnd_freebdn,  &
                               dpnd_initial, dpnd_initialn, &
                               dpnd_dlid,    dpnd_dlidn)

      ! single category fluxes
      real (kind=dbl_kind), intent(in) :: &
          aicen       ! concentration of ice

      real (kind=dbl_kind), optional, intent(in) :: &
          flw     , & ! downward longwave flux          (W/m**2)
          strairxn, & ! air/ice zonal  strss,           (N/m**2)
          strairyn, & ! air/ice merdnl strss,           (N/m**2)
          Cdn_atm_ratio_n, & ! ratio of total drag over neutral drag
          fsurfn  , & ! net heat flux to top surface    (W/m**2)
          fcondtopn,& ! downward cond flux at top sfc   (W/m**2)
          fcondbotn,& ! downward cond flux at bottom sfc   (W/m**2)
          fsensn  , & ! sensible heat flx               (W/m**2)
          flatn   , & ! latent   heat flx               (W/m**2)
          fswabsn , & ! shortwave absorbed heat flx     (W/m**2)
          flwoutn , & ! upwd lw emitted heat flx        (W/m**2)
          evapn   , & ! evaporation                     (kg/m2/s)
          evapsn  , & ! evaporation over snow           (kg/m2/s)
          evapin  , & ! evaporation over ice            (kg/m2/s)
          Trefn   , & ! air tmp reference level         (K)
          Qrefn   , & ! air sp hum reference level      (kg/kg)
          freshn  , & ! fresh water flux to ocean       (kg/m2/s)
          fsaltn  , & ! salt flux to ocean              (kg/m2/s)
          fhocnn  , & ! actual ocn/ice heat flx         (W/m**2)
          fswthrun, & ! sw radiation through ice bot    (W/m**2)
          melttn  , & ! top ice melt                    (m)
          meltbn  , & ! bottom ice melt                 (m)
          meltsn  , & ! snow melt                       (m)
          meltsliqn,& ! mass of snow melt               (kg/m^2)
          dsnown  , & ! change in snow depth            (m)
          congeln , & ! congelation ice growth          (m)
          snoicen , & ! snow-ice growth                 (m)
          dpnd_flushn , & ! pond flushing rate due to ice permeability (m/step)
          dpnd_exponn , & ! exponential pond drainage rate (m/step)
          dpnd_freebdn, & ! pond drainage rate due to freeboard constraint (m/step)
          dpnd_initialn,& ! runoff rate due to rfrac (m/step)
          dpnd_dlidn  , & ! pond loss/gain due to ice lid (m/step)
          fswthrun_vdr, & ! vis dir sw radiation through ice bot    (W/m**2)
          fswthrun_vdf, & ! vis dif sw radiation through ice bot    (W/m**2)
          fswthrun_idr, & ! nir dir sw radiation through ice bot    (W/m**2)
          fswthrun_idf, & ! nir dif sw radiation through ice bot    (W/m**2)
          fswthrun_uvrdr, & !   > 700nm vis uvr dir sw radiation through ice bot (W/m**2)
          fswthrun_uvrdf, & !   > 700nm vis uvr dif sw radiation through ice bot (W/m**2)
          fswthrun_pardr, & ! 400-700nm vis par dir sw radiation through ice bot (W/m**2)
          fswthrun_pardf, & ! 400-700nm vis par dif sw radiation through ice bot (W/m**2)
          Urefn       ! air speed reference level       (m/s)

      ! cumulative fluxes
      real (kind=dbl_kind), optional, intent(inout) :: &
          strairxT, & ! air/ice zonal  strss,           (N/m**2)
          strairyT, & ! air/ice merdnl strss,           (N/m**2)
          Cdn_atm_ratio, & ! ratio of total drag over neutral drag
          fsurf   , & ! net heat flux to top surface    (W/m**2)
          fcondtop, & ! downward cond flux at top sfc   (W/m**2)
          fcondbot, & ! downward cond flux at bottom sfc   (W/m**2)
          fsens   , & ! sensible heat flx               (W/m**2)
          flat    , & ! latent   heat flx               (W/m**2)
          fswabs  , & ! shortwave absorbed heat flx     (W/m**2)
          flwout  , & ! upwd lw emitted heat flx        (W/m**2)
          evap    , & ! evaporation                     (kg/m2/s)
          evaps   , & ! evaporation over snow           (kg/m2/s)
          evapi   , & ! evaporation over ice            (kg/m2/s)
          Tref    , & ! air tmp reference level         (K)
          Qref    , & ! air sp hum reference level      (kg/kg)
          fresh   , & ! fresh water flux to ocean       (kg/m2/s)
          fsalt   , & ! salt flux to ocean              (kg/m2/s)
          fhocn   , & ! actual ocn/ice heat flx         (W/m**2)
          fswthru , & ! sw radiation through ice bot    (W/m**2)
          meltt   , & ! top ice melt                    (m)
          meltb   , & ! bottom ice melt                 (m)
          melts   , & ! snow melt                       (m)
          meltsliq, & ! mass of snow melt               (kg/m^2)
          congel  , & ! congelation ice growth          (m)
          snoice  , & ! snow-ice growth                 (m)
          dpnd_flush , & ! pond flushing rate due to ice permeability (m/step)
          dpnd_expon , & ! exponential pond drainage rate (m/step)
          dpnd_freebd, & ! pond drainage rate due to freeboard constraint (m/step)
          dpnd_initial,& ! runoff rate due to rfrac (m/step)
          dpnd_dlid  , & ! pond loss/gain (+/-) to ice lid freezing/melting (m/step)
          fswthru_vdr, & ! vis dir sw radiation through ice bot    (W/m**2)
          fswthru_vdf, & ! vis dif sw radiation through ice bot    (W/m**2)
          fswthru_idr, & ! nir dir sw radiation through ice bot    (W/m**2)
          fswthru_idf, & ! nir dif sw radiation through ice bot    (W/m**2)
          fswthru_uvrdr, & !   > 700nm vis uvr dir sw radiation through ice bot (W/m**2)
          fswthru_uvrdf, & !   > 700nm vis uvr dif sw radiation through ice bot (W/m**2)
          fswthru_pardr, & ! 400-700nm vis par dir sw radiation through ice bot (W/m**2)
          fswthru_pardf, & ! 400-700nm vis par dif sw radiation through ice bot (W/m**2)
          dsnow,    & ! change in snow depth            (m)
          Uref        ! air speed reference level       (m/s)

      real (kind=dbl_kind), dimension(:), intent(in), optional :: &
          Qrefn_iso, & ! isotope air sp hum ref level   (kg/kg)
          fiso_ocnn, & ! isotope fluxes to ocean        (kg/m2/s)
          fiso_evapn   ! isotope evaporation            (kg/m2/s)

      real (kind=dbl_kind), dimension(:), intent(inout), optional :: &
          Qref_iso, & ! isotope air sp hum ref level    (kg/kg)
          fiso_ocn, & ! isotope fluxes to ocean         (kg/m2/s)
          fiso_evap   ! isotope evaporation             (kg/m2/s)

      character(len=*),parameter :: subname='(merge_fluxes)'

      !-----------------------------------------------------------------
      ! Merge fluxes
      ! NOTE: The albedo is aggregated only in cells where ice exists
      !       and (for the delta-Eddington scheme) where the sun is above
      !       the horizon.
      !-----------------------------------------------------------------

      ! atmo fluxes

      if (present(strairxn) .and. present(strairxT)) &
         strairxT   = strairxT + strairxn  * aicen
      if (present(strairyn) .and. present(strairyT)) &
         strairyT   = strairyT + strairyn  * aicen
      if (present(Cdn_atm_ratio_n) .and. present(Cdn_atm_ratio)) &
         Cdn_atm_ratio = Cdn_atm_ratio + &
                         Cdn_atm_ratio_n   * aicen
      if (present(fsurfn) .and. present(fsurf)) &
         fsurf      = fsurf    + fsurfn    * aicen
      if (present(fcondtopn) .and. present(fcondtop)) &
         fcondtop   = fcondtop + fcondtopn * aicen
      if (present(fcondbotn) .and. present(fcondbot)) &
         fcondbot   = fcondbot + fcondbotn * aicen
      if (present(fsensn) .and. present(fsens)) &
         fsens      = fsens    + fsensn    * aicen
      if (present(flatn) .and. present(flat)) &
         flat       = flat     + flatn     * aicen
      if (present(fswabsn) .and. present(fswabs)) &
         fswabs     = fswabs   + fswabsn   * aicen
      if (present(flwoutn) .and. present(flwout) .and. present(flw)) &
         flwout     = flwout   &
              + (flwoutn - (c1-emissivity)*flw) * aicen
      if (present(evapn) .and. present(evap)) &
         evap       = evap     + evapn     * aicen
      if (present(evapsn) .and. present(evaps)) &
         evaps      = evaps    + evapsn    * aicen
      if (present(evapin) .and. present(evapi)) &
         evapi      = evapi    + evapin    * aicen
      if (present(Trefn) .and. present(Tref)) &
         Tref       = Tref     + Trefn     * aicen
      if (present(Qrefn) .and. present(Qref)) &
         Qref       = Qref     + Qrefn     * aicen

      ! Isotopes
      if (tr_iso) then
         if (present(Qrefn_iso) .and. present(Qref_iso)) then
            Qref_iso (:) = Qref_iso (:) + Qrefn_iso (:) * aicen
         endif
         if (present(fiso_ocnn) .and. present(fiso_ocn)) then
            fiso_ocn (:) = fiso_ocn (:) + fiso_ocnn (:) * aicen
         endif
         if (present(fiso_evapn) .and. present(fiso_evap)) then
            fiso_evap(:) = fiso_evap(:) + fiso_evapn(:) * aicen
         endif
      endif

      ! ocean fluxes
      if (present(Urefn) .and. present(Uref)) then
         Uref      = Uref      + Urefn     * aicen
      endif

      if (present(freshn) .and. present(fresh)) &
         fresh     = fresh     + freshn    * aicen
      if (present(fsaltn) .and. present(fsalt)) &
         fsalt     = fsalt     + fsaltn    * aicen
      if (present(fhocnn) .and. present(fhocn)) &
         fhocn     = fhocn     + fhocnn    * aicen
      if (present(fswthrun) .and. present(fswthru)) &
         fswthru   = fswthru   + fswthrun  * aicen

      if (present(fswthrun_vdr) .and. present(fswthru_vdr)) &
         fswthru_vdr = fswthru_vdr + fswthrun_vdr  * aicen
      if (present(fswthrun_vdf) .and. present(fswthru_vdf)) &
         fswthru_vdf = fswthru_vdf + fswthrun_vdf  * aicen
      if (present(fswthrun_idr) .and. present(fswthru_idr)) &
         fswthru_idr = fswthru_idr + fswthrun_idr  * aicen
      if (present(fswthrun_idf) .and. present(fswthru_idf)) &
         fswthru_idf = fswthru_idf + fswthrun_idf  * aicen

      if (present(fswthrun_uvrdr) .and. present(fswthru_uvrdr)) &
         fswthru_uvrdr   = fswthru_uvrdr   + fswthrun_uvrdr  * aicen
      if (present(fswthrun_uvrdf) .and. present(fswthru_uvrdf)) &
         fswthru_uvrdf   = fswthru_uvrdf   + fswthrun_uvrdf  * aicen
      if (present(fswthrun_pardr) .and. present(fswthru_pardr)) &
         fswthru_pardr   = fswthru_pardr   + fswthrun_pardr  * aicen
      if (present(fswthrun_pardf) .and. present(fswthru_pardf)) &
         fswthru_pardf   = fswthru_pardf   + fswthrun_pardf  * aicen

      ! ice/snow thickness

      if (present(melttn) .and. present(meltt)) &
         meltt     = meltt     + melttn    * aicen
      if (present(meltbn) .and. present(meltb)) &
         meltb     = meltb     + meltbn    * aicen
      if (present(meltsn) .and. present(melts)) &
         melts     = melts     + meltsn    * aicen
      if (snwgrain) then
         if (present(meltsliqn) .and. present(meltsliq)) &
            meltsliq  = meltsliq  + meltsliqn * aicen
      endif
      if (present(dsnown) .and. present(dsnow)) then
         dsnow     = dsnow     + dsnown    * aicen
      endif
      if (present(congeln) .and. present(congel)) &
         congel    = congel    + congeln   * aicen
      if (present(snoicen) .and. present(snoice)) &
         snoice    = snoice    + snoicen   * aicen
      ! Meltwater fluxes
      if (tr_pond) then
         if (present(dpnd_flushn)  .and. present(dpnd_flush))   &
            dpnd_flush   = dpnd_flush   + dpnd_flushn   * aicen
         if (present(dpnd_exponn)  .and. present(dpnd_expon))   &
            dpnd_expon   = dpnd_expon   + dpnd_exponn   * aicen
         if (present(dpnd_freebdn) .and. present(dpnd_freebd))  &
            dpnd_freebd  = dpnd_freebd  + dpnd_freebdn  * aicen
         if (present(dpnd_initialn).and. present(dpnd_initial)) &
            dpnd_initial = dpnd_initial + dpnd_initialn * aicen
         if (present(dpnd_dlidn)   .and. present(dpnd_dlid))    &
            dpnd_dlid    = dpnd_dlid    + dpnd_dlidn    * aicen
      endif

      end subroutine merge_fluxes

!=======================================================================

! If model is not calculating surface temperature, set the surface
! flux values using values read in from forcing data or supplied via
! coupling (stored in ice_flux).
!
! If CICE is running in NEMO environment, convert fluxes from GBM values
! to per unit ice area values. If model is not running in NEMO environment,
! the forcing is supplied as per unit ice area values.
!
! authors Alison McLaren, Met Office

      subroutine set_sfcflux (aicen,               &
                              flatn_f,             &
                              fsensn_f,            &
                              fsurfn_f,            &
                              fcondtopn_f,         &
                              flatn,               &
                              fsensn,              &
                              fsurfn,              &
                              fcondtopn)

      ! ice state variables
      real (kind=dbl_kind), intent(in) :: &
         aicen       , & ! concentration of ice
         flatn_f     , & ! latent heat flux   (W/m^2)
         fsensn_f    , & ! sensible heat flux (W/m^2)
         fsurfn_f    , & ! net flux to top surface, not including fcondtopn
         fcondtopn_f     ! downward cond flux at top surface (W m-2)

      real (kind=dbl_kind), intent(out):: &
         flatn       , & ! latent heat flux   (W/m^2)
         fsensn      , & ! sensible heat flux   (W/m^2)
         fsurfn      , & ! net flux to top surface, not including fcondtopn
         fcondtopn       ! downward cond flux at top surface (W m-2)

      ! local variables

      real (kind=dbl_kind)  :: &
         raicen          ! 1 or 1/aicen

      logical (kind=log_kind) :: &
         extreme_flag    ! flag for extreme forcing values

      logical (kind=log_kind), parameter :: &
         extreme_test=.false. ! test and write out extreme forcing data

      character(len=*),parameter :: subname='(set_sfcflux)'

      raicen        = c1

#ifdef CICE_IN_NEMO
!----------------------------------------------------------------------
! Convert fluxes from GBM values to per ice area values when
! running in NEMO environment.  (When in standalone mode, fluxes
! are input as per ice area.)
!----------------------------------------------------------------------
      raicen        = c1 / aicen
#endif
      fsurfn   = fsurfn_f*raicen
      fcondtopn= fcondtopn_f*raicen
      flatn    = flatn_f*raicen
      fsensn   = fsensn_f*raicen

!----------------------------------------------------------------
! Flag up any extreme fluxes
!---------------------------------------------------------------

      if (extreme_test) then
         extreme_flag = .false.

         if (fcondtopn < -100.0_dbl_kind &
              .or. fcondtopn > 20.0_dbl_kind) then
            extreme_flag = .true.
         endif

         if (fsurfn < -100.0_dbl_kind &
              .or. fsurfn > 80.0_dbl_kind) then
            extreme_flag = .true.
         endif

         if (flatn < -20.0_dbl_kind &
              .or. flatn > 20.0_dbl_kind) then
            extreme_flag = .true.
         endif

         if (extreme_flag) then

            if (fcondtopn < -100.0_dbl_kind &
                 .or. fcondtopn > 20.0_dbl_kind) then
               write(warnstr,*) subname, &
                    'Extreme forcing: -100 > fcondtopn > 20'
               call icepack_warnings_add(warnstr)
               write(warnstr,*) subname, &
                    'aicen,fcondtopn = ', &
                    aicen,fcondtopn
               call icepack_warnings_add(warnstr)
            endif

            if (fsurfn < -100.0_dbl_kind &
                 .or. fsurfn > 80.0_dbl_kind) then
               write(warnstr,*) subname, &
                    'Extreme forcing: -100 > fsurfn > 40'
               call icepack_warnings_add(warnstr)
               write(warnstr,*) subname, &
                    'aicen,fsurfn = ', &
                    aicen,fsurfn
               call icepack_warnings_add(warnstr)
            endif

            if (flatn < -20.0_dbl_kind &
                 .or. flatn > 20.0_dbl_kind) then
               write(warnstr,*) subname, &
                    'Extreme forcing: -20 > flatn > 20'
               call icepack_warnings_add(warnstr)
               write(warnstr,*) subname, &
                    'aicen,flatn = ', &
                    aicen,flatn
               call icepack_warnings_add(warnstr)
            endif

         endif  ! extreme_flag
      endif     ! extreme_test

      end subroutine set_sfcflux

!=======================================================================

      end module icepack_flux

!=======================================================================
