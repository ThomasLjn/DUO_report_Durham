program diff
  use tableI_mod ! parse_tableI 
  use parse_raw_out_mod  ! parse_raw_out
  use chk_mod  ! reduce_vec and parse_chk functions
  use, intrinsic :: iso_fortran_env, only: input_unit, error_unit

  implicit none

  ! Input/Output related
  integer :: i, n, J_int, min_index, num_masked, converted_par, num_chk_masked
  character(len=256) :: output_file
  real(dp) :: e_diff, zpe
  integer, dimension(1) :: min_location_array
  logical :: file_exists
  ! Table arrays (allocatable)
  type(TableOut), allocatable :: table_out(:)
  type(TableOut), allocatable :: masked_table(:)
  type(TableI), allocatable :: table_data(:)
  type(Table_chk), allocatable :: tablechk(:)
  type(Table_chk), allocatable :: masked_chk_array(:)
  ! Scalar variable to hold the single matched chk entry
  type(Table_chk) :: masked_chk  

  integer :: nstates = 2

  ! Format strings
  character(len=*), parameter :: fmt_header = "(A4, A2, A2, A3, A12, A11, A6, A6, A6, A6)"
  character(len=*), parameter :: fmt_data   = "(I4, 1X, A1, 1X, I3, 1X, I3, 1X, F12.4, 1X, F11.4, 1X, F6.2,"// &
                                                "1X, F6.2, 1X, F6.2, 1X, F6.2, 1X, F6.2)"
  character(len=*), parameter :: header1 = &
  "   I p   J  v        Eexpt        Eduo    diff A_duo  b0_duo A_paper b0_paper"
  character(len=*), parameter :: header2 = &
  "---- - --- ------------ ----------- ------- ------ ------ ------- --------"
  character(len=256) :: table_i_file, table_out_file, table_chk_file, output_diff
  character(:), allocatable :: reduced_chk
  integer :: num_args, dot_pos
  character(len=10) :: extension

  ! Check number of args
  num_args = command_argument_count()
  
  if (num_args /= 4) then
    write(error_unit, *) "Usage: ./programme tableI.txt out.out chk.chk output_diff_name"
    stop 1
  end if
  
  call get_command_argument(1, table_i_file)
  call get_command_argument(2, table_out_file)
  call get_command_argument(3, table_chk_file)
  call get_command_argument(4, output_diff)


  dot_pos = index(table_chk_file, ".", .true.)

  ! --- Read input data ---
  print *, "Reading ", trim(table_i_file), "..."
  table_data = parse_tableI(table_i_file)
  print *, "Reading ", trim(table_out_file), "..."
  table_out = parse_raw_out(table_out_file)
  
  if (dot_pos > 0) then
    extension = table_chk_file(dot_pos:)
    print *, "Reading ", trim(table_chk_file), "..."

    if (trim(extension) == ".chk") then
      print *, "First reduce the .chk file"
      reduced_chk = reduce_vec(trim(table_chk_file), nstates)
      
      ! Vérifiez si reduced_chk est alloué et non vide
      if (.not. allocated(reduced_chk) .or. len(reduced_chk) == 0) then
          write(error_unit, *) "Error: Failed to generate reduced file"
          stop 1
      end if
      
      print *, "Now reading the reduced chk file:", trim(reduced_chk)
      ! Assurez-vous que le fichier existe avant de l'ouvrir
      inquire(file=reduced_chk, exist=file_exists)
      if (.not. file_exists) then
          write(error_unit, *) "Error: Reduced file not found:", trim(reduced_chk)
          stop 1
      end if
      
      ! Ajoutez une gestion des erreurs pour parse_chk
      tablechk = parse_chk(reduced_chk, nstates)
      
      ! Libérer la mémoire après utilisation
      if (allocated(reduced_chk)) deallocate(reduced_chk)
    end if
  else
    write(error_unit, *) "No extension found for third file. Cannot process further."
    stop 1
  end if

  print *, "Finished reading input files."

  ! --- Setup Output ---
  print *, "Output file: ", trim(output_diff)
  n = size(table_data) ! Get the number of elements from tableI.txt
  zpe = 24.794637558396 ! Zero Point Energy

  open(unit=1, file=trim(output_diff), status="replace", action="write")
  ! Write header
  write(1,'(A)') header1
  write(1,'(A)') header2

  ! --- Main Processing Loop ---
  print *, "Starting main loop over ", n, " entries..."
  do i = 1, n
    ! Filter table_out based on J value from table_data
    masked_table = pack(table_out, mask = (table_out%J == table_data(i)%J))
    num_masked = size(masked_table)

    ! Proceed only if matching J entries were found in table_out
    if (num_masked > 0) then
      ! Find the entry in masked_table with the minimum energy difference
      min_location_array = minloc(abs(masked_table%E + zpe - table_data(i)%Eexpt), dim=1)
      min_index = min_location_array(1) ! Extract scalar index
      e_diff = masked_table(min_index)%E + zpe - table_data(i)%Eexpt

      ! Process further only if the energy difference is small enough
      if (abs(e_diff) <= 10.0_dp) then

        ! Convert parity string ('+' or '-') to integer (0 or 1)
        if (masked_table(min_index)%par == "+") then
          converted_par = 0
        else if (masked_table(min_index)%par == "-") then
          converted_par = 1
        else
          ! Handle unexpected parity character if necessary
          print '(A, A, A, I0)', "Warning: Unexpected parity '", masked_table(min_index)%par, "' for table_data index i=", i
          cycle ! Skip to next i if parity is invalid
        end if

        ! Filter tablechk based on matching J and converted parity
        masked_chk_array = pack(tablechk, mask = (tablechk%J == table_data(i)%J) .and. &
                                          (tablechk%par == converted_par) .and. &
                                          (tablechk%I == masked_table(min_index)%I))
        num_chk_masked = size(masked_chk_array)

        if (num_chk_masked > 0) then
          ! Assign the first matching element to the scalar variable
          masked_chk = masked_chk_array(1)

          ! Write the combined results to the output file
          write(1, fmt_data) masked_table(min_index)%I, masked_table(min_index)%par, &
            nint(masked_table(min_index)%J), masked_table(min_index)%v, table_data(i)%Eexpt, masked_table(min_index)%E + zpe, &
            e_diff, masked_chk%coeff1 * 100, masked_chk%coeff2 * 100, &
            table_data(i)%a, table_data(i)%b0
        end if 
      end if
    end if
  end do

  print *, "Finished main loop."
  close(1)
  print *, "Output file closed."

  ! Deallocate arrays
  if (allocated(table_out)) deallocate(table_out)
  if (allocated(masked_table)) deallocate(masked_table)
  if (allocated(table_data)) deallocate(table_data)
  if (allocated(tablechk)) deallocate(tablechk)
  if (allocated(masked_chk_array)) deallocate(masked_chk_array)

end program diff