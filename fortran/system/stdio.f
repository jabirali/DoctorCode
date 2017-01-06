!> Author:   Jabir Ali Ouassou
!> Date:     2015-07-10
!> Category: System
!>
!> This file renames the ISO input/output units to the standard UNIX names, and defines the ANSI escape codes for colored output.

module stdio_m
  use, intrinsic :: iso_fortran_env
  public

  ! Declare standard input/output units
  integer,      parameter :: stdin   = input_unit
  integer,      parameter :: stdout  = output_unit
  integer,      parameter :: stderr  = error_unit

  ! Define escape codes for terminal colors
  character(*), parameter :: color_none   = '[00m'
  character(*), parameter :: color_red    = '[31m'
  character(*), parameter :: color_green  = '[32m'
  character(*), parameter :: color_yellow = '[33m'
  character(*), parameter :: color_blue   = '[34m'
  character(*), parameter :: color_purple = '[35m'
  character(*), parameter :: color_cyan   = '[36m'
  character(*), parameter :: color_white  = '[37m'

  ! Declare public interfaces
  interface dump
    !! Public interface for functions that dump results to files
    module procedure dump_arrays, dump_scalar
  end interface
contains
  impure subroutine message(msg)
    ! This subroutine provides a way to report a status message.
    character(*), intent(in) :: msg

    write(stderr,'(a)') color_green  // ' >> INFO: '    // color_none // msg
  end subroutine

  impure subroutine warning(msg)
    ! This subroutine provides a way to report a warning message.
    character(*), intent(in) :: msg

    write(stderr,'(a)') color_yellow // ' >> WARNING: ' // color_none // msg
  end subroutine

  impure subroutine error(msg)
    ! This subroutine provides a way to report an error message and halt the program.
    character(*), intent(in) :: msg

    write(stderr,'(a)') color_red    // ' >> ERROR: '   // color_none // msg
    stop
  end subroutine

  impure subroutine status_head(title)
    !! This subroutine is used to write boxed status messages to standard out;
    !! in particular, this routine writes out a boxed title with a timestamp.
    character(len=*), intent(in) :: title
    character(len=33)            :: title_
    real                         :: time
    integer                      :: hh, mm, ss

    ! Calculate the current time
    call cpu_time(time)
    hh = int(time/3600.0)
    mm = int(mod(time,3600.0)/60.0)
    ss = int(mod(time,60.0))

    ! adjust the provided title
    title_ = ''
    title_((len(title_)-len(title)+1)/2:) = title

    ! Write out the boxed header
    write(*,*)
    write(*,'(a)') '╒═══════════════════════════════════╕'
    write(*,'(a)') '│ '         // title_ //          ' │'
    write(*,'(a)') '├───────────────────────────────────┤'
    write(*,'(a,3x,a,7x,i3.2,a,i2.2,a,i2.2,3x,a)') '│', 'Elapsed time:', hh, ':', mm, ':', ss, '│'
  end subroutine

  impure subroutine status_body(title, value)
    !! This subroutine is used to write boxed status messages to standard out;
    !! in particular, this routine writes out the name and value of a variable.
    character(len=*), intent(in) :: title
    character(len=20)            :: title_
    class(*),         intent(in) :: value

    ! Adjust the provided title
    title_ = trim(title) // ':'

    ! Print out the title and value
    select type(value)
      type is (integer)
        write(*,'(a,3x,a,i10  ,2x,a)') '│', title_, value, '│'
      type is (real)
        write(*,'(a,3x,a,f10.8,2x,a)') '│', title_, value, '│'
      type is (double precision)
        write(*,'(a,3x,a,f10.8,2x,a)') '│', title_, value, '│'
    end select
  end subroutine

  impure subroutine status_foot()
    !! This subroutine is used to write boxed status messages to standard out;
    !! in particular, this routine writes out the bottom edge of such a box.

    ! Write out the boxed footer
    write(*,'(a)') '╘═══════════════════════════════════╛'

    ! Flush the information to standard out
    flush(unit=stdout)
  end subroutine

  impure subroutine status_box(title)
    !! This subroutine is used to write boxed status messages to standard out.
    character(len=*), intent(in) :: title
    character(len=33)            :: title_

    ! adjust the provided title
    title_ = ''
    title_((len(title_)-len(title)+1)/2:) = title

    ! Write out the boxed message
    write(*,*)
    write(*,'(a)') '╒═══════════════════════════════════╕'
    write(*,'(a)') '│ '         // title_ //          ' │'
    write(*,'(a)') '╘═══════════════════════════════════╛'
  end subroutine

  impure subroutine dump_arrays(filename, arrays, header)
    !! This subroutine is used to dump numerical arrays to an output file.
    use :: iso_fortran_env

    character(len=*),               intent(in) :: filename
    real(real64),     dimension(:), intent(in) :: arrays
    character(len=*), dimension(:), intent(in) :: header

    real(real64), dimension(size(arrays)/size(header),size(header)) :: matrix

    integer :: unit
    integer :: iostat
    integer :: n

    ! Reshape the data
    matrix = reshape(arrays, shape(matrix))

    ! Open the output file
    open(newunit = unit, file = filename, iostat = iostat, action = 'write', status = 'replace')
    if (iostat /= 0) then
      call error('Failed to open output file "' // filename // '"!')
    end if

    ! Write the header line
    write(unit,'(*(a20,:,"	"))') '# ' // header(1), header(2:)

    ! Loop over the matrix rows
    do n=1,size(matrix,1)
      ! Write the matrix column to file
      write(unit,'(*(es20.12e3,:,"	"))') matrix(n,:)
    end do

    ! Close the output file
    close(unit = unit)
  end subroutine

  impure subroutine dump_scalar(filename, scalar)
    !! This subroutine is used to dump a numerical result to an output file.
    use :: iso_fortran_env

    character(len=*), intent(in) :: filename
    real(real64),     intent(in) :: scalar

    character(len=2048) :: str

    integer :: unit
    integer :: iostat
    integer :: n

    ! Open the output file
    open(newunit = unit, file = filename, iostat = iostat, action = 'write', status = 'replace')
    if (iostat /= 0) then
      call error('Failed to open output file "' // filename // '"!')
    end if

    ! Write out command-line arguments
    do n=1,command_argument_count()
      call get_command_argument(n, str)
      write(unit,'(a,"	")',advance='no') trim(str)
    end do

    ! Write the scalar value to file
    write(unit,'(*(es20.12e3,:,"	"))') scalar

    ! Close the output file
    close(unit = unit)
  end subroutine
end module
