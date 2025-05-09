module io_integral
    implicit none

contains

subroutine read_wf(fname, len_grid, root, state, wf)
    integer, intent(in) :: len_grid, root
    character(len=*), intent(in) :: fname, state
    real, dimension(len_grid), intent(out) :: wf
    real :: tmp_r, col1, col2
    integer :: len_wf, ind
    integer :: i, k, unit, ios
    character(len=256) :: line
    character(len=20) :: root_str

    write(root_str, '(A,I0,A)') "root=", root, ","

    k = 0
    open(newunit=unit, file=fname, status="old", action="read", iostat=ios)
    if (ios /= 0) then
        write(*,'(A,A,A,I0)') "Error: Cannot open file '", trim(fname), "'. IOSTAT=", ios
        return
    end if

    do
        read(unit, '(A)', iostat=ios) line 
        if (ios /= 0) exit

        ind = index(line, trim(state))

        if (ind > 0) then
            if (index(line, trim(root_str)) > 0) then ! We are in the good section
                wf = 0.0
                do k=1, len_grid
                    read(unit, *, iostat=ios) tmp_r, wf(k)
                    if (ios /= 0) then 
                        write(*,*) "Error reading data at line", k
                        exit
                    end if
                end do
                close(unit) 
                return
            end if
        end if
    end do
    close(unit)  
    return

end subroutine read_wf

function norm_wf(wf_A, wf_b, R, len_grid) result(factor)
    integer, intent(in)                     :: len_grid
    real, dimension(len_grid), intent(in)   :: R ! grid
    real, dimension(len_grid), intent(in)  :: wf_A, wf_b
    real, dimension(len_grid)               :: integrand
    real                                    :: factor

    integrand = R**2 * (wf_A**2 + wf_b**2)
    factor = trapz(len_grid, R, integrand)

end function norm_wf


function trapz(len, X, Y) result(integral)
    integer, intent(in)                 :: len
    real, dimension(len), intent(in)    :: X, Y
    real                                :: integral, h
    integer                             :: i

    integral = 0.0
    do i=1, len-1
    h = X(i+1)-X(i)
        integral = integral + 0.5 * h * (Y(i) + Y(i+1))
    end do
end function trapz



subroutine read_dip(fname, len_grid, dipole)
    integer, intent(in) :: len_grid
    character(len=*), intent(in) :: fname
    real, dimension(len_grid), intent(out) :: dipole
    real :: tmp_r
    integer :: i, k, unit, ios
    character(len=256) :: line

    ! Create proper root string with correct formatting

    k = 0
    !len_wf = len_grid + 1 ! Number of lines per state in the .wf file
    open(newunit=unit, file=fname, status="old", action="read", iostat=ios)
    if (ios /= 0) then
        write(*,'(A,A,A,I0)') "Error: Cannot open file '", trim(fname), "'. IOSTAT=", ios
        return ! len_grid remains 0
    end if
    dipole = 0.0
    do k=1, len_grid
        read(unit, *, iostat=ios) tmp_r, dipole(k)
        if (ios /= 0) then  ! ADDED: Check for read errors
            write(*,*) "Error reading data at line", k
            exit
        end if
    end do

    close(unit)  ! ADDED: Make sure to close the file
    return
end subroutine read_dip


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
    grid = 0.0
    ! Read the grid data
    read(unit, *, iostat=ios) grid
    if (ios /= 0) then
        write(*,'(A,A,A,I0)') "Warning: IO error reading grid data from '", trim(fname), "'. Check format. IOSTAT=", ios
        ! Data in grid might be incomplete/incorrect, but len_grid is technically correct
    end if

    close(unit) ! Close the file

end subroutine read_grid

function calculate_integral(R, wf1, wf2, dipole, len_grid) result(integral)
    implicit none
    
    integer, intent(in) :: len_grid
    real, dimension(len_grid), intent(in) :: R, wf1, wf2, dipole
    real :: integral
    
    integer :: i
    real :: h, integrand_current, integrand_next
    
    integral = 0.0
    
    ! Apply trapezoidal rule: ∫f(x)dx ≈ h/2 * [f(x₀) + 2f(x₁) + ... + 2f(xₙ₋₁) + f(xₙ)]
    do i = 1, len_grid - 1
        ! Calculate step size (can vary if grid is not uniform)
        h = R(i+1) - R(i)
        
        ! Calculate integrand at current and next points
        ! integrand_current = R(i)**2 * wf1(i) * wf2(i) * dipole(i)
        ! integrand_next = R(i+1)**2 * wf1(i+1) * wf2(i+1) * dipole(i+1)
        
        integrand_current = wf1(i) * wf2(i) * dipole(i)
        integrand_next = wf1(i+1) * wf2(i+1) * dipole(i+1)
        
        ! Add this segment's contribution to the integral
        integral = integral + 0.5 * h * (integrand_current + integrand_next)
    end do
    
end function calculate_integral

end module io_integral