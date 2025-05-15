program wf_calculator
    use io_module, only: read_vectors, read_grid, read_basis, vector_type, basis_type
    use wavefunction_module, only: calculate_psi
    implicit none

    ! Data containers
    real, allocatable :: grid(:)
    type(vector_type), allocatable :: vectors(:)
    type(basis_type), allocatable :: basis(:)
    character(len=50), allocatable :: states(:)

    ! Counters and temp var
    integer :: i, j, n_vec, n_basis_funcs, n_grid, n_states, unit, k, ios
    integer :: current_j, current_p, root, state_idx
    logical :: root_exists, state_exists, file_exists, done_processing
    real, allocatable :: psi(:)
    character(len=100) :: fname = "nroot30.txt"
    character(len=100) :: base_name = "test1.wf"  ! Default value
    character(len=256) :: vectors_file, vib_file
    integer :: max_root

    ! Read the base name from stdin
    write(*,*) "Enter base name for files (default: test1):"
    read(*,'(A)', iostat=ios) base_name
    if (ios /= 0 .or. len_trim(base_name) == 0) then
        base_name = "test1"  ! Use default if read fails or empty input
    end if
    
    write(*,*) "Using base name: ", trim(base_name)

    ! Construct file paths using the base name
    vectors_file = "chk/" // trim(base_name) // "_vectors.chk"
    vib_file = "chk/" // trim(base_name) // "_vib.chk"
    fname = trim(base_name) // ".wf"

    ! inquire(file=fname, exist=file_exists)
    ! if (file_exists) then
    !     write(*,*) "Error: File '", trim(fname), "' already exists. Program will stop."
    !     stop
    ! end if

    ! Initialisation
    ! n_states = 1
    n_states = 2
    allocate(states(n_states))
    ! states(1) = "X1Sigma+"
    states(1) = "A1Sigma+"
    states(2) = "b3pi0"

    ! Read the data
    print *, "Loading grid file"
    call read_grid("R_grid.txt", grid, n_grid)
    
    print *, "Loading vectors file: ", trim(vectors_file)
    call read_vectors(vectors_file, vectors, n_vec, max_root)

    print *, "Reading vib basis file: ", trim(vib_file)
    call read_basis(vib_file, basis, n_basis_funcs, n_grid)
   
    ! Validate data, sanity check of the input files
    if (n_vec == 0 .or. n_basis_funcs == 0 .or. n_grid == 0) then
        write(*,*) "Error: One or more data files failed to load properly."
        stop
    end if
    print *, n_vec
    allocate(psi(n_grid))

    done_processing = .false.

    ! Create the file
    open(newunit=unit, file=fname, status="replace", action="write")
    
    ! Loop over each (J, p) block
    do i=1, n_vec
        if (done_processing)  exit
        ! Check if this is a unique (J,p) pair we haven't processed yet
        root_exists = .false.
        do j = 1, i-1
            if (vectors(j)%j == vectors(i)%j .and. vectors(j)%p == vectors(i)%p .and. &
                vectors(j)%root == vectors(i)%root) then
                root_exists = .true.
                exit
            end if
        end do
        
        if (.not. root_exists) then ! Update the current params
            current_j = vectors(i)%j
            current_p = vectors(i)%p
            root = vectors(i)%root
            !if(current_p == 0) then ! Only + parity here
            ! Process each (J, p, root) states
                do state_idx=1, n_states
                    ! First check if this state exist for the current root in the (J,p) block
                    state_exists = .false.
                    do j=1, n_vec
                        if (vectors(j)%j == current_j .and. vectors(j)%p == current_p .and. &
                            vectors(j)%root == root .and. vectors(j)%st == state_idx) then
                                state_exists = .true.
                                exit
                        end if
                    end do

                    if (state_exists) then ! process
                        print *, "Calculating Psi for: J=", current_j, ", p=", current_p, &
                                ", root=", root, ", state='", trim(states(state_idx)), "'"
                        
                        psi = 0.0

                        call calculate_psi(vectors, n_vec, basis, n_basis_funcs, n_grid, &
                        current_j, current_p, root, state_idx, psi)
                        ! Now write psi in the file
                        write(unit, '(A,I0,A,I0,A,I0,A,A,A)') &
                                "# Calculation info: J=", current_j, ", p=", current_p, &
                                ", root=", root, ", state='", trim(states(state_idx)), "'"    
                        do k = 1, n_grid
                            write(unit, '(E20.10, E20.10)') grid(k), psi(k)
                        end do
                    end if
                end do
                if(root >= max_root*2) then 
                    done_processing = .true.
                end if
            !end if
        end if
    end do
    
    ! Clean up
    deallocate(grid, vectors, basis, states, psi)
    close(unit)
    
    write(*,*) "Wavefunction calculation completed successfully."

end program wf_calculator