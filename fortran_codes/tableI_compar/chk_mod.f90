module chk_mod
  use, intrinsic :: iso_fortran_env, only: dp => real64, iostat_end
  implicit none
  type :: Table_chk
     integer :: I
     real(dp) :: J
     integer :: par
     real(dp) :: coeff1
     real(dp) :: coeff2
  end type Table_chk
contains

  !********************************************************************
  ! Function: reduce_vec
  ! Purpose:  Open a vec.chk file, skip header lines and compute the coeff per root and per states. Then write it in a file.
  ! Inputs:
  !   fname  : filename as a string.
  !   nskip  : (optional) number of lines to skip before reading data.
  ! Returns: An allocatable array of TableI records.
  !********************************************************************
  function reduce_vec(fname, nstates, nskip) result(output_fname)
    implicit none
    character(len=*), intent(in) :: fname
    integer, intent(in), optional :: nskip
    integer, intent(in) :: nstates
    ! -- Local variables --
    character(len=:), allocatable :: output_fname
    character(len=256) :: line             ! Buffer for skipping header lines
    character(len=256) :: fmt_out          ! Format string for output file
    integer :: nskip_val, i
    integer :: ios, ios_internal
    integer :: len_fname
    integer :: line_num = 0

    ! Variables to read columns from input file
    integer  :: tmp_root, tmp_par, tmp_state, tmp_vib, tmp_lambda, tmp_ivib
    real(dp) :: tmp_j, tmp_coeff, tmp_spin, tmp_sigma, tmp_omega

    ! Variables for processing logic
    integer  :: current_root
    integer  :: current_par       ! Store parity for current root
    real(dp) :: current_j         ! Store J for current root
    real(dp), allocatable :: coeff_sum_st(:)
    logical  :: first_data_line 

    ! Check if nstates is valid
    if (nstates <= 0) then
        write(*, '(A, I0)') "Error: nstates must be positive. Received: ", nstates
        return
    end if
    print *, "Tracking sums for nstates = ", nstates

    ! Allocate the accumulator array
    allocate(coeff_sum_st(nstates), stat=ios)
    if (ios /= 0) then
        write(*, '(A, I0)') "Error: Could not allocate accumulator array for nstates = ", nstates
        return
    end if

    print *, "start_module reduce_vec"
    ! Set default skip value if not provided.
    nskip_val = 9
    if (present(nskip)) then
       nskip_val = nskip
    end if

    allocate(character(len=len(fname)-4+len( "_reduced.txt")) :: output_fname)
    output_fname = fname(:len(fname)-4) // "_reduced.txt"
    print *, "Output reduced vector file: "//output_fname

    open(unit=1, file=fname, status="old", action="read")
    open(unit=2, file=output_fname, status="replace", action="write")
    ! Write output header
    write(2, '(A)') "# Root  J Par SumCoeffSq(St=1) SumCoeffSq(St=2) SumCoeffSq(St=3)" ! Added J and Par
    fmt_out = '(I5, 1X, F5.1, 1X, I1, 3(1X,F12.8))' ! Updated format for J (F5.1) and Par (I1)
    
    ! Skip header
    do i=1, nskip_val
        read(1, '(A)', iostat=ios) line
    end do
        
    ! Initialize processing variables
    current_root = -1       ! Sentinel value (assuming root# is always positive)
    current_j = 0.0_dp      ! Initialize J value
    current_par = 0         ! Initialize parity value
    coeff_sum_st = 0.0_dp   ! Array assignment resets all elements
    first_data_line = .true. ! Flag to handle the very first data line correctly

    do
        ! 1. Read the entire next line as a string
        read(1, '(A)', iostat=ios) line

        ! 2. Check for End-of-File or file read error FIRST
        if (ios /= 0) then
            if (ios == iostat_end) then
                ! Normal end of file reached, expected exit condition
                ! print *, "End of file reached."
            else
                ! Error reading the line from the file
                write(*,'(A,I0)') "Error reading line from input file, IOSTAT = ", ios
            end if
            exit ! Exit the loop on EOF or file read error
        end if

        ! 3. Check if the line is the specific trailer text (use trim to ignore leading/trailing spaces)
        if (trim(adjustl(line)) == 'End of eigenvector') then
            print *, "Found 'End of eigenvector'. Finishing processing of reducing."
            exit ! Exit the loop cleanly, normal termination for this file type
        end if

        read(line, *, iostat=ios_internal) tmp_root, tmp_j, tmp_par, tmp_coeff, tmp_state, &
            tmp_vib, tmp_lambda, tmp_spin, tmp_sigma, tmp_omega, tmp_ivib
        if (ios_internal /= 0) then
            write(*,'(A)') "-----------------------------------------------------"
            write(*,'(A, I0)') "Format error processing line content, IOSTAT_INTERNAL = ", ios_internal
            write(*,'(A, A)') "Problematic line content: '", trim(line), "'"
            write(*,'(A)') "Skipping this line."
            write(*,'(A)') "-----------------------------------------------------"
            cycle
        end if

        ! Check if root changed - if so, write the previous root's results
        if (tmp_root /= current_root .and. .not. first_data_line) then
            ! Root has changed, write previous root's results with its own J and parity values
            write(2, fmt_out) current_root, current_j, current_par, (coeff_sum_st(i), i=1, nstates)
            ! Reset accumulators for the new root
            coeff_sum_st = 0.0_dp ! Array assignment resets all elements
        end if

        ! If root changed or it's the first data line, update current_root
        if (tmp_root /= current_root .or. first_data_line) then
            current_root = tmp_root
            current_j = tmp_j         ! Store J value for this root
            current_par = tmp_par     ! Store parity value for this root
            first_data_line = .false. ! No longer the first line
        end if

        if (tmp_state >= 1 .and. tmp_state <= nstates) then
            coeff_sum_st(tmp_state) = coeff_sum_st(tmp_state) + tmp_coeff**2
        end if
    end do 

    ! After the loop, write the results for the very last root encountered
    ! Check if any data was actually processed (first_data_line would be .false.)
    if (.not. first_data_line) then
        write(2, fmt_out) current_root, current_j, current_par, (coeff_sum_st(i), i=1, nstates)
    else
        print *, "No data lines found or processed after header."
    end if

    ! Cleanup: Close files and deallocate memory
    close(1)
    close(2)
    if (allocated(coeff_sum_st)) deallocate(coeff_sum_st) ! Deallocate the array
    print *, "end_module reduce_vec"

end function reduce_vec

  !********************************************************************
  ! Function: parse_chk
  ! Purpose:  Read and parse a reduced chk file
  ! Inputs:
  !   fname  : filename as a string.
  !   nskip  : (optional) number of lines to skip before reading data.
  ! Returns: An allocatable array of table_chk records.
  !********************************************************************
  function parse_chk(fname, nskip) result(data)
    implicit none
    character(len=*), intent(in) :: fname
    integer, intent(in), optional :: nskip
    type(Table_chk), allocatable :: data(:)
    type(Table_chk), allocatable :: tmp(:)
    integer :: nskip_val, ios, n, max_records, i
    character(len=256) :: line

    integer :: tempI, temppar
    real(dp) :: tempJ, tempE, temp_c1, temp_c2
    
    ! Set default skip value if not provided.
    nskip_val = 1
    if (present(nskip)) then
       nskip_val = nskip
    end if

    max_records = 50000   ! Maximum number of records (adjust if needed)
    allocate(data(max_records))
    n = 0

    open(unit=1, file=fname, status='old', action="read")
    ! Skip header lines
    do i = 1, nskip_val
       read(1, '(A)', iostat=ios) line
       if (ios /= 0) exit
    end do

    ! Read each remaining non-empty line.
    do
       read(1, '(A)', iostat=ios) line
       if (ios /= 0) exit
       if (len_trim(line) == 0) cycle
       read(line, *) tempI, tempJ, temppar, temp_c1, temp_c2
       n = n + 1
       data(n)%J      = tempJ
       data(n)%I      = tempI
       data(n)%par    = temppar
       data(n)%coeff1 = temp_c1
       data(n)%coeff2 = temp_c2
    end do
    close(1)

  ! Resize the array to the number of records actually read.
  if (n < max_records) then
     allocate(tmp(n))
     tmp = data(1:n)
     call move_alloc(tmp, data)
  end if
  end function parse_chk


end module chk_mod

