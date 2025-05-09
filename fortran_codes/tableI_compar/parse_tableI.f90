module tableI_mod
  use, intrinsic :: iso_fortran_env, only: dp => real64
  implicit none

  ! Derived type to hold one record of Table I data.
  type :: TableI
     integer :: N      ! Column 0 in Python (first column)
     integer :: J      ! Column 2 in Python (third column)
     real(dp) :: Eexpt ! Column 3 in Python (fourth column)
     real(dp) :: Ecalc ! Column 4 in Python (fifth column)
     real(dp) :: a
     real(dp) :: b0
     real(dp) :: b1
     real(dp) :: b2
  end type TableI
!N   i   J   Eexpt   Ecalc   Del   A%   b0%   b1%   b2%

contains

  !********************************************************************
  ! Function: parse_tableI
  ! Purpose:  Open a file, skip header lines and read columns 0,2,3,4
  !           similar to np.genfromtxt(..., skip_header=nskip, usecols=...)
  ! Inputs:
  !   fname  : filename as a string.
  !   nskip  : (optional) number of lines to skip before reading data.
  ! Returns: An allocatable array of TableI records.
  !********************************************************************
  function parse_tableI(fname, nskip) result(data)
    implicit none
    character(len=*), intent(in) :: fname
    integer, intent(in), optional :: nskip
    type(TableI), allocatable :: data(:)
   type(TableI), allocatable :: tmp(:)
    integer :: nskip_val, ios, n, max_records, i
    character(len=256) :: line
    integer :: tempN, tempJ, dummy
    real(dp) :: tempEexpt, tempEcalc, dummy_real, temp_a, temp_b0, temp_b1, temp_b2

    ! Set default skip value if not provided.
    nskip_val = 7118
    if (present(nskip)) then
       nskip_val = nskip
    end if

    max_records = 10000   ! Maximum number of records (adjust if needed)
    allocate(data(max_records))
    n = 0

    open(unit=10, file=fname, status='old', action="read")
    ! Skip header lines
    do i = 1, nskip_val
       read(10, '(A)', iostat=ios) line
       if (ios /= 0) exit
    end do

    ! Read each remaining non-empty line.
    do
       read(10, '(A)', iostat=ios) line
       if (ios /= 0) exit
       if (len_trim(line) == 0) cycle
       ! Read columns: assume the line has at least five numeric columns.
       ! In Fortran list-directed input, columns are space delimited.
       ! The second column (dummy) is skipped.
       read(line, *) tempN, dummy, tempJ, tempEexpt, tempEcalc, dummy_real, temp_a, temp_b0, temp_b1, temp_b2
       n = n + 1
       data(n)%N      = tempN
       data(n)%J      = tempJ
       data(n)%Eexpt  = tempEexpt
       data(n)%Ecalc  = tempEcalc
       data(n)%a      = temp_a
       data(n)%b0     = temp_b0
       data(n)%b1     = temp_b1
       data(n)%b2     = temp_b2
    end do
    close(10)

  ! Resize the array to the number of records actually read.
  if (n < max_records) then
     allocate(tmp(n))
     tmp = data(1:n)
     call move_alloc(tmp, data)
  end if
  end function parse_tableI

end module tableI_mod

