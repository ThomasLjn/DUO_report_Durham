module parse_raw_out_mod
  use, intrinsic :: iso_fortran_env, only: dp => real64
  implicit none

  ! Derived type to hold one record of output data.
  type :: TableOut
     real(dp) :: J      ! Column 0 in Python (first column)
     integer :: I      ! Column 2 in Python (third column)
     real(dp) :: E ! Column 3 in Python (fourth column)
     integer :: state
     integer :: v
     integer :: lambda
     real(dp) :: spin
     real(dp) :: sigma
     real(dp) :: omega
     character(len=1) :: par
  end type TableOut

contains

  function parse_raw_out(fname, write_formatted_out) result(data)
   implicit none
   character(len=*), intent(in) :: fname
   logical, intent(in), optional :: write_formatted_out
   character(:), allocatable :: new_fname
   integer :: dot_position, prefix_len, new_len

   type(TableOut), allocatable :: data(:)
   type(TableOut), allocatable :: tmp(:)
   integer :: nskip_val, ios, n, max_records, i
   character(len=256) :: line

   integer :: tempI, tempstate, tempv, templambda,index_of_energy
   real(dp) :: tempJ, tempE, tempspin, tempsigma, tempomega
   character :: tempparity
   logical :: in_table = .false., w_formatted_out = .true.
   integer :: inp_unit = 1
   integer :: out_unit = 2
   


   max_records = 100000   ! Maximum number of records (adjust if needed)
   allocate(data(max_records))

   if (present(write_formatted_out)) then
      w_formatted_out = write_formatted_out
   end if


   if (w_formatted_out) then
      dot_position = index(fname, ".")
      if (dot_position > 1) then
         allocate(character(dot_position+13) :: new_fname)
         new_fname = fname(1:dot_position-1) // "_formatted.txt"
      else
         allocate(character(len_trim(fname)+14) :: new_fname)
         new_fname = trim(fname) // "_formatted.txt"
      end if

      open(unit=out_unit, file=new_fname, status='replace', action="write")
      write(out_unit, '(A)') '    J i(#)               E state  v lambda spin  sigma  omega parity'

   end if

   open(unit=inp_unit, file=fname, status='old', action="read")


   ! Read each remaining non-empty line.
   do
      read(inp_unit, '(A)', iostat=ios) line
      ! if any error: exit ; if blank line: go to next loop cycle
      if (ios /= 0) exit
      if (len_trim(line) == 0) then
         in_table = .false. ! end of table = blank line
         cycle
      end if
      line = trim(line)
      if (index(line, "J") > 0 .and. &
         index(line, "i") > 0 .and. &
         index(line, "Energy/cm") > 0 .and. &
         index(line, "State") > 0 .and. &
         index(line, "v") > 0 .and. &
         index(line, "lambda") > 0 .and. &
         index(line, "spin") > 0 .and. &
         index(line, "sigma") > 0 .and. &
         index(line, "omega") > 0 .and. &
         index(line, "parity") > 0) then
         in_table = .true.
         cycle
      end if

      if (in_table) then
         read(line, *) tempJ, tempI, tempE, tempstate, tempv, templambda, tempspin, tempsigma, tempomega, tempparity!, dummy_char
         n = n + 1
         data(n)%J      = tempJ
         data(n)%I      = tempI
         data(n)%E      = tempE
         data(n)%state  = tempstate
         data(n)%v      = tempv
         data(n)%lambda = templambda
         data(n)%spin   = tempspin
         data(n)%sigma  = tempsigma
         data(n)%omega  = tempomega
         data(n)%par    = tempparity
         
         if (w_formatted_out) then
            write(out_unit, '(F6.1,1X,I6,1X,F12.4,1X,I3,1X,I3,1X,I3,1X,F5.1,1X,F5.1,1X,F5.1,1X,A1)') &
      tempJ, tempI, tempE, tempstate, tempv, templambda, tempspin, tempsigma, tempomega, tempparity
         end if
      end if
      end do
      close(1)

   ! Resize the array to the number of records actually read.
   if (n < max_records) then
      allocate(tmp(n))
      tmp = data(1:n)
      call move_alloc(tmp, data)
   end if


  end function parse_raw_out

end module parse_raw_out_mod

