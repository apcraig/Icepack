:tocdepth: 3

.. _library:

Using Icepack in other models
=================================

This section documents how to use Icepack in other models.

.. _liboverview:

Overview
----------------

Icepack is a column physics package designed to be used in other broader sea ice models, such as
CICE, SIS, or even in ocean models.  
Icepack includes options for simulating sea ice thermodynamics, mechanical redistribution 
(ridging) and associated area and thickness changes. In addition, the model supports a number of 
tracers, including thickness, enthalpy, ice age, first-year ice area, deformed ice area and 
volume, melt ponds, and biogeochemistry.

Icepack is called on a grid point by grid point basis.  All data is passed in and out of the model
via subroutine interfaces.  Fortran "use" statements are not encouraged for accessing data inside
the Icepack model.

Icepack does not contain any parallelization or I/O.  The driver of Icepack is expected to support
those features.  Icepack can be called concurrently across multiple MPI tasks.  Icepack should also
be thread safe.

.. _initialization:

Icepack Initialization
----------------------

The subroutine icepack_configure should be called before any other icepack interfaces are called.
This subroutine initializes the abort flag and a few other important defaults.  We recommend that
call be implemented as::

      call icepack_configure()  ! initialize icepack
      call icepack_warnings_flush(nu_diag)
      if (icepack_warnings_aborted()) call my_abort_method()

The 2nd and 3rd line above are described further in :ref:`aborts`.


.. _aborts:

Error Messages and Aborts
-----------------------------

Icepack does not understand the I/O (file units) or computing environment (MPI, etc).  It provides an
interface that allows the driver to write error messsages and check for an abort flag.  If Icepack
fails, it will make error messages available thru that interface and it will set an abort flag
that can be queried by the driver.
To best use those features, it's recommended that after every icepack interface call, the user
add the following::

      call icepack_warnings_flush(nu_diag)
      if (icepack_warnings_aborted()) call my_abort_method()

icepack_warnings_flush is a public interface in icepack that writes any warning or error messages
generated in icepack to the driver file unit number defined by nu_diag.  
The function icepack_warnings_aborted queries the internal icepack abort flag and
returns true if icepack generated an abort error.  
my_abort_method represents method that stops the driver model from 
running.  That interface or command is driver dependent.

.. _callingseq:

Calling Sequence
-----------------

TBD

.. _ipinterfaces:

Public Interfaces
--------------------

The section documents each of the public interfaces in Icepack.  The interfaces are available via a use statement to icepack_intfc.  For example::

   use icepack_intfc, only: icepack_step_radiation

.. (this works for future reference but is a comment now)  f:automodule:: icepack_shortwave


icepack_init_parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_parameters

icepack_query_parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_query_parameters

icepack_write_parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_write_parameters

icepack_recompute_constants
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_recompute_constants

icepack_compute_tracers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_compute_tracers

icepack_query_tracer_sizes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_query_tracer_sizes

icepack_write_tracer_sizes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_write_tracer_sizes

icepack_init_tracer_flags
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_init_tracer_flags

icepack_query_tracer_flags
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_query_tracer_flags

icepack_write_tracer_flags
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_write_tracer_flags

icepack_init_tracer_indices
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_init_tracer_indices

icepack_query_tracer_indices
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_query_tracer_indices

icepack_write_tracer_indices
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_write_tracer_indices

icepack_init_tracer_numbers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_init_tracer_numbers

icepack_query_tracer_numbers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_query_tracer_numbers

icepack_write_tracer_numbers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. xx f:autosubroutine:: icepack_write_tracer_numbers

icepack_init_itd
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_itd

icepack_init_itd_hist
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_itd_hist

icepack_aggregate
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_aggregate

icepack_step_ridge
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_step_ridge

icepack_ice_strength
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_ice_strength

icepack_prep_radiation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_prep_radiation

icepack_step_radiation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_step_radiation

icepack_init_hbrine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_hbrine

icepack_init_zsalinity
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_zsalinity

icepack_init_bgc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_bgc

icepack_init_zbgc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_zbgc

icepack_biogeochemistry
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_biogeochemistry

icepack_init_OceanConcArray
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_OceanConcArray

icepack_init_ocean_conc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_ocean_conc

icepack_atm_boundary
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_atm_boundary

icepack_ocn_mixed_layer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_ocn_mixed_layer

icepack_init_orbit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_orbit

icepack_query_orbit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_query_orbit

icepack_step_therm1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_step_therm1

icepack_step_therm2
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_step_therm2

icepack_ice_temperature
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_ice_temperature

icepack_snow_temperature
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_snow_temperature

icepack_liquidus_temperature
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_liquidus_temperature

icepack_sea_freezing_temperature
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_sea_freezing_temperature

icepack_enthalpy_snow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_enthalpy_snow

icepack_init_thermo
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_thermo

icepack_init_trcr
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_init_trcr

icepack_warnings_clear
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_warnings_clear

icepack_warnings_print
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_warnings_print

icepack_warnings_flush
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_warnings_flush

icepack_warnings_aborted
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. f:autosubroutine:: icepack_warnings_aborted

