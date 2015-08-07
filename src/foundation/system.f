! This file defines a module containing the machine size of single-precision, double-precision, and quadruple-precision
! floating point numbers; to declare the floating point precision of a variable, use real(sp), real(dp), or real(qp) as
! the type of the variable. It also renames the ISO input/output units to the standard UNIX names.  Finally, the module
! defines a set of subroutines with the common interface 'option' to read and parse command line arguments to a program.
!
! Author:  Jabir Ali Ouassou <jabirali@switzerlandmail.ch>
! Created: 2015-07-10
! Updated: 2015-07-25

module mod_system
  use, intrinsic :: iso_fortran_env

  ! Declare standard input/output units
  integer,      parameter :: stdin   = input_unit
  integer,      parameter :: stdout  = output_unit
  integer,      parameter :: stderr  = error_unit

  ! Declare floating-point precisions
  integer,      parameter :: sp      = REAL32
  integer,      parameter :: dp      = REAL64
  integer,      parameter :: qp      = REAL128

  ! Define comm on mathematical constants
  real(dp),     parameter :: inf     = huge(1.0_dp)
  real(dp),     parameter :: pi      = atan(1.0_dp)*4.0_dp
  complex(dp),  parameter :: i       = (0.0_dp,1.0_dp)

  ! Define escape codes for terminal colors
  character(*), parameter :: color_none   = '[0m'
  character(*), parameter :: color_red    = '[31m'
  character(*), parameter :: color_green  = '[32m'
  character(*), parameter :: color_yellow = '[33m'
  character(*), parameter :: color_blue   = '[34m'
  character(*), parameter :: color_purple = '[35m'
  character(*), parameter :: color_cyan   = '[36m'
  character(*), parameter :: color_white  = '[37m'

  ! Define an interface for obtaining command line arguments
  interface option
    module procedure print_option, option_logical, option_integer, option_real, option_string
  end interface
contains
  subroutine print_option
    ! If the subroutine 'option' is run without arguments, this prints out a header.
    write(*,'(a)') '╒═══════════════════════════════════╕'
    write(*,'(a)') '│        RUNTIME  PARAMETERS        │'
    write(*,'(a)') '╘═══════════════════════════════════╛'
  end subroutine

  subroutine option_integer(variable, option)
    ! Reads a command line option on the form option=value, where value is an integer.
    ! Note that 'variable' is only updated if the option is found, meaning that it should
    ! should be initialized to a sensible default value before this subroutine is called.
    integer,            intent(inout) :: variable
    character(len= * ), intent(in   ) :: option
    character(len=128)                :: string
    character(len= 20)                :: output
    integer                           :: n
    
    do n = 1,command_argument_count()
      ! Iterate over all command line arguments
      call get_command_argument(n,string)

      ! If this is the argument we were looking for, update the output variable
      if ( string(1:len(option)+1)  == option // '=' ) then
        read( string(len(option)+2:len(string)), '(i10)' ) variable
      end if
    end do

    ! Write the results to standard out for verification purposes
    output = option
    write(*,'(a,a,i10)') ' :: ', output, variable
  end subroutine

  subroutine option_real(variable, option)
    ! Reads a command line option on the form option=value, where value is a real number.
    ! Note that 'variable' is only updated if the option is found, meaning that it should
    ! should be initialized to a sensible default value before this subroutine is called.
    real(dp),           intent(inout) :: variable
    character(len= * ), intent(in   ) :: option
    character(len=128)                :: string
    character(len= 20)                :: output
    integer                           :: n
    
    do n = 1,command_argument_count()
      ! Iterate over all command line arguments
      call get_command_argument(n,string)

      ! If this is the argument we were looking for, update the output variable
      if ( string(1:len(option)+1)  == option // '=' ) then
        read( string(len(option)+2:len(string)), '(g24.0)' ) variable
      end if
    end do

    ! Write the results to standard out for verification purposes
    output = option
    write(*,'(a,a,f10.5)') ' :: ', output, variable
  end subroutine

  subroutine option_logical(variable, option)
    ! Reads a command line option on the form option=value, where value is a boolean.
    ! Note that 'variable' is only updated if the option is found, meaning that it should
    ! should be initialized to a sensible default value before this subroutine is called.
    logical,            intent(inout) :: variable
    character(len= * ), intent(in   ) :: option
    character(len=128)                :: string
    character(len= 20)                :: output
    integer                           :: n
    
    do n = 1,command_argument_count()
      ! Iterate over all command line arguments
      call get_command_argument(n,string)

      ! If this is the argument we were looking for, update the output variable
      if ( string(1:len(option)+1)  == option // '=' ) then
        read( string(len(option)+2:len(string)), '(l1)' ) variable
      end if
    end do

    ! Write the results to standard out for verification purposes
    output = option
    write(*,'(a,a,l10)') ' :: ', output, variable
  end subroutine

  subroutine option_string(variable, option)
    ! Reads a command line option on the form option=value, where value is a string.
    ! Note that 'variable' is only updated if the option is found, meaning that it should
    ! should be initialized to a sensible default value before this subroutine is called.
    character(len= * ), intent(inout) :: variable
    character(len= * ), intent(in   ) :: option
    character(len=128)                :: string
    integer                           :: n
    
    do n = 1,command_argument_count()
      ! Iterate over all command line arguments
      call get_command_argument(n,string)

      ! If this is the argument we were looking for, update the output variable
      if ( string(1:len(option)+1)  == option // '=' ) then
        read( string(len(option)+2:len(string)), '(a)' ) variable
      end if
    end do

    ! Write the results to standard out for verification purposes
    write(*,'(a,a,1x,a,a,a)') ' :: ', option, '"', trim(variable), '"'
  end subroutine

  subroutine print_status(header, iteration, change)
    ! Prints a status message including the iteration number and elapsed time to stdout.
    character(*),           intent(in) :: header
    integer,      optional, intent(in) :: iteration
    real(dp),     optional, intent(in) :: change
    real(sp)                           :: time
    character(33)                      :: string

    ! Determine how much CPU time has elapsed
    call cpu_time(time)

    ! Copy the header to a string of correct size
    string = header

    ! Print the progress information to standard out
    write(*,'(a)') '                                     '
    write(*,'(a)') '╒═══════════════════════════════════╕'
    write(*,'(a)') '│ '         // string //          ' │'
    write(*,'(a)') '├───────────────────────────────────┤'
    if (present(iteration)) then
      write(*,'(a,3x,a,i8,3x,a)')                       &
        '│','Iteration:           ',     iteration,     '│'
    end if
    if (present(change)) then
      write(*,'(a,3x,a,f8.6,3x,a)')                     &
        '│','Maximum change:      ',     change,       '│'
    end if
    write(*,'(a,3x,a,i2.2,a,i2.2,a,i2.2,3x,a)')         &
      '│','Elapsed time:        ',                      &
      int(time/3600.0_sp),':',                          &
      int(mod(time,3600.0_sp)/60.0_sp),':',             &
      int(mod(time,60.0_sp)),                          '│'
    write(*,'(a)') '╘═══════════════════════════════════╛'
  end subroutine

end module 
