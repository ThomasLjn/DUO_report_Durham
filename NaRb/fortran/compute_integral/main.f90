program integral_calculator
    use io_integral, only: read_wf, read_grid, calculate_integral, read_dip, norm_wf
    implicit none

    real, allocatable   :: grid(:)
    real, allocatable   :: wf_A(:), wf_b(:), phi_perp(:), dipole(:)
    integer             :: n_grid, ierr, nroots, i
    real                :: integral, norm
    !                :: norm_X = sqrt(0.3073620539959103)

    nroots = 100

    print *, "Loading grid file"
    call read_grid("R_grid.txt", grid, n_grid)
    print *, "Grid size:", n_grid

    ! Allocate wf with proper size before passing to read_wf
    if (allocated(wf_A)) deallocate(wf_A)
    if (allocated(wf_b)) deallocate(wf_b)
    if (allocated(phi_perp)) deallocate(phi_perp)
    if (allocated(dipole)) deallocate(dipole)

    allocate(wf_A(n_grid), stat=ierr)
    allocate(wf_b(n_grid), stat=ierr)
    allocate(phi_perp(n_grid), stat=ierr)
    allocate(dipole(n_grid), stat=ierr)
    if (ierr /= 0) then
        print *, "Error: Failed to allocate wf/dipole array"
        stop
    end if

    phi_perp = 0.0
    dipole = 0.0

    call read_wf("X.wf", n_grid, 1, "X1Sigma+", phi_perp)
    !phi_perp = phi_perp/norm_X
    call read_dip("interpolated_dipole.txt", n_grid, dipole)


    print *, "First 5 values of phi_perp:"
    do i=1, min(5, n_grid)
        print *, i, phi_perp(i)
    end do
    
    print *, "First 5 values of dipole:"
    do i=1, min(5, n_grid)
        print *, i, dipole(i)
    end do

    open(unit=1, file="integrals_without_R2.int", status="replace", action="write")

    do i=1, nroots
        wf_A = 0.0
        wf_b = 0.0
        call read_wf("nroot_100_vmax_300.wf", n_grid, i,  "A1Sigma+", wf_A)  ! Removed extra parameter
        !call read_wf("nroot_100_vmax_300.wf", n_grid, i,  "b3pi0", wf_b)  ! Removed extra parameter

        !norm = norm_wf(wf_A, wf_b, grid, n_grid)

        !wf_A = wf_A/sqrt(norm)

        integral = calculate_integral(grid, wf_A, phi_perp, dipole, n_grid)
        !print *, integral, 1/sqrt(norm)
        write(1, '(I5,F20.8)') i, integral
    end do
    
    ! Clean up
    if (allocated(grid)) deallocate(grid)
    if (allocated(wf_A)) deallocate(wf_A)
    if (allocated(wf_b)) deallocate(wf_b)
    if (allocated(phi_perp)) deallocate(phi_perp)
    if (allocated(dipole)) deallocate(dipole)
    close(1)
end program integral_calculator