module io_module
    implicit none

    ! Define data types
    type vector_type
        integer :: root, p, st, vib, ivib
        real :: j, coeff, lambda, spin, sigma, omega
    end type vector_type  

    type basis_type
        integer :: num  ! Original index from vib file (optional but maybe useful)
        integer :: state ! Electronic state index
        integer :: ivib  ! Vibrational quantum number
        real, allocatable :: values(:) ! Array to hold ALL grid values
    end type basis_type
! 33       1363.872403      1   3   A1Sigma+
contains

subroutine read_vectors(fname, vectors, n, max_root)
    character(len=*), intent(in) :: fname
    type(vector_type), allocatable, intent(out) :: vectors(:)
    integer, intent(out) :: n
    integer, intent(out) :: max_root
    integer :: unit, ios, i, count_lines
    character(len=256) :: line
    logical :: found_data = .false.
    
    max_root = 0 ! init
    ! Open the file
    open(newunit=unit, file=fname, status="old", action="read", iostat=ios)
    if (ios /= 0) then
        print *, "Error opening file: ", fname
        return
    end if
    
    ! First, count the number of data lines
    count_lines = 0
    do
        read(unit, '(A)', iostat=ios) line
        if (ios /= 0) exit
        
        ! Check for start of data section
        if (index(line, 'A1Sigma+') /= 0 .or. index(line, 'b3pi') /= 0 .or. index(line, 'X1Sigma+') /= 0) then
            found_data = .true.
            ! Skip header line
            read(unit, '(A)') line
            cycle
        end if
        
        ! Check for end of data section
        if (index(line, 'End of eigenvector') /= 0) exit
        
        ! Count data lines after finding data section
        if (found_data) then
            ! Ignore blank lines
            if (len_trim(line) > 0) count_lines = count_lines + 1
        end if
    end do
    
    ! Allocate the vectors array
    n = count_lines
    allocate(vectors(n))
    
    ! Rewind the file to read data
    rewind(unit)
    
    ! Skip to data section
    found_data = .false.
    do
        read(unit, '(A)', iostat=ios) line
        if (ios /= 0) exit
        
        if (index(line, 'A1Sigma+') /= 0 .or. index(line, 'b3pi') /= 0 .or. index(line, 'X1Sigma+') /= 0) then
            found_data = .true.
            ! Skip header line
            read(unit, '(A)') line
            exit
        end if
    end do
    
    ! Read data
    i = 0
    do while (found_data .and. i < n)
        read(unit, '(A)', iostat=ios) line
        if (ios /= 0) exit
        
        ! Check for end of data
        if (index(line, 'End of eigenvector') /= 0) exit
        
        ! Skip blank lines
        if (len_trim(line) == 0) cycle
        
        i = i + 1
        read(line, *, iostat=ios) vectors(i)%root, vectors(i)%j, vectors(i)%p, &
                                vectors(i)%coeff, vectors(i)%st, vectors(i)%vib, &
                                vectors(i)%lambda, vectors(i)%spin, vectors(i)%sigma, &
                                vectors(i)%omega, vectors(i)%ivib
        if (vectors(i)%root > max_root) then 
            max_root = vectors(i)%root
        end if
        if (ios /= 0) then
            print *, "Error reading line: ", trim(line)
            print *, "Line number: ", i
        end if
    end do
    
    close(unit)
    
    ! Adjust the count if necessary
    n = i
    
end subroutine read_vectors

subroutine read_grid(fname, grid, len_grid)
    ! I/O variables
    character(len=*), intent(in) :: fname
    real, allocatable, intent(out) :: grid(:)
    integer, intent(out) :: len_grid
    ! Other variables
    integer :: unit, ios, alloc_stat
    character(len=256) :: line

    len_grid = 0
    ios = 0
    ! Check file open
    open(newunit=unit, file=fname, status="old", action="read", iostat=ios)
    if (ios /= 0) then
        write(*,'(A,A,A,I0)') "Error: Cannot open file '", trim(fname), "'. IOSTAT=", ios
        return ! len_grid remains 0
    end if

    ! Count non-blank lines
    do
        read(unit, '(A)', iostat=ios) line ! Read as string to handle format simply
        if (ios /= 0) exit ! Exit on EOF or read error
        if (len_trim(line) > 0) then
             len_grid = len_grid + 1
        end if
    end do

    ! Rewind the file
    rewind(unit, iostat=ios)


    ! Allocate memory
    allocate(grid(len_grid), stat=alloc_stat)
    ! Read the grid data
    read(unit, *, iostat=ios) grid
    if (ios /= 0) then
        write(*,'(A,A,A,I0)') "Warning: IO error reading grid data from '", trim(fname), "'. Check format. IOSTAT=", ios
        ! Data in grid might be incomplete/incorrect, but len_grid is technically correct
    end if

    close(unit) ! Close the file

end subroutine read_grid



subroutine read_basis(fname, basis, n_basis_funcs, n_grid)
    character(len=*), intent(in) :: fname
    type(basis_type), allocatable, intent(out) :: basis(:)
    integer, intent(out) :: n_basis_funcs
    integer, intent(in) :: n_grid ! Grid size is needed

    integer :: unit, ios, i, func_idx, alloc_stat
    character(len=500) :: line
    ! Temp header variables
    integer :: num_temp, state_temp, ivib_temp
    real :: energy_temp
    character(len=32) :: label_temp

    ! First pass: Count basis functions (header lines)
    n_basis_funcs = 0
    open(newunit=unit, file=fname, status='old', action='read', iostat=ios)
    if (ios /= 0) return ! Error opening file
    do
        read(unit,'(A)', iostat=ios) line
        if (ios /= 0) exit ! EOF or error

        ! Attempt to read as header - assumes headers have >= 4 fields
        read(line,*,iostat=ios) num_temp, energy_temp, state_temp, ivib_temp
        if (ios == 0) then
             n_basis_funcs = n_basis_funcs + 1
        end if
    end do
    rewind(unit)

    ! Allocate basis array
    allocate(basis(n_basis_funcs), stat=alloc_stat)
    if (alloc_stat /= 0) then
        print *, "Error allocating basis array"
        close(unit)
        return
    end if

    ! Second pass: Read headers and values
    func_idx = 0
    do
        read(unit,'(A)', iostat=ios) line ! Read potential header
        if (ios /= 0) exit ! EOF or error

        ! Attempt to read as header
        read(line,*,iostat=ios) num_temp, energy_temp, state_temp, ivib_temp, label_temp
        if (ios == 0) then ! It's a header line
            func_idx = func_idx + 1
            if (func_idx > n_basis_funcs) exit ! Should not happen

            basis(func_idx)%num = num_temp
            basis(func_idx)%state = state_temp
            basis(func_idx)%ivib = ivib_temp

            ! Allocate space for values for this basis function
            allocate(basis(func_idx)%values(n_grid), stat=alloc_stat)
            if (alloc_stat /= 0) then
                 print *, "Error allocating basis values for function", func_idx
                 exit ! Stop reading
            end if

            ! Read the next n_grid lines as values
            do i = 1, n_grid
                read(unit,*,iostat=ios) basis(func_idx)%values(i)
                if (ios /= 0) then
                    print *, "Error reading value", i, "for basis function", func_idx
                    exit ! Stop reading
                end if
            end do
            if (ios /= 0) exit ! Exit outer loop if value reading failed
        end if
    end do
    close(unit)

    ! Check if we read the expected number of functions
    if (func_idx /= n_basis_funcs) then
        print *, "Warning: Expected", n_basis_funcs, "basis functions, read", func_idx
        ! Optional: deallocate and reallocate basis to actual size func_idx if needed
    end if

end subroutine read_basis


end module io_module