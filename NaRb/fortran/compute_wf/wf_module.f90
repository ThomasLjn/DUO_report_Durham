module wavefunction_module
use io_module, only: vector_type, basis_type
implicit none

contains

subroutine calculate_psi(vectors, n_vectors, basis, n_basis_funcs, n_grid, &
                         current_j, current_p, root, state_idx, psi)

    integer, intent(in) :: n_vectors, n_basis_funcs, n_grid
    type(vector_type), intent(in) :: vectors(n_vectors)
    type(basis_type), intent(in) :: basis(n_basis_funcs) ! Note size is now number of functions
    integer, intent(in) :: current_j, current_p, root, state_idx
    real, intent(out) :: psi(n_grid)

    integer :: i, j
    real :: current_coeff
    integer :: current_vib_qn ! Vibrational quantum number from vector
    logical :: found_basis

    ! Initial value: 0
    psi = 0.0

    ! Loop over all vector components for the desired state (J, p, root)
    do i = 1, n_vectors
    
        if (vectors(i)%j    == current_j .and. &
            vectors(i)%p    == current_p .and. &
            vectors(i)%root == root      .and. &
            vectors(i)%st   == state_idx) then

            current_coeff = vectors(i)%coeff
            current_vib_qn = vectors(i)%ivib ! Use the vibrational quantum number
            !print *, "Found matching vector: i=", i, ", coeff=", current_coeff, ", vib=", current_vib_qn

            ! Find the corresponding basis function (state and vib number)
            found_basis = .false.
            !print *, "Found vector with coeff =", current_coeff, ", vib_qn =", current_vib_qn

            do j = 1, n_basis_funcs
                if (basis(j)%num == current_vib_qn .and. basis(j)%state == state_idx) then
                ! if (current_coeff >= 0.0001) then 
            !    print *, "Found matching basis function j=", j, ", state=", basis(j)%state, ", ivib=", basis(j)%num
                ! print *, "Basis function values min/max:", minval(basis(j)%values), maxval(basis(j)%values)
                ! end if
                    ! Add contribution: coeff * basis_function_values
                    psi = psi + current_coeff * basis(j)%values
                    found_basis = .true.
                    exit ! Found the unique basis function, exit inner loop
                end if
            end do

            ! Optional: Warning if a basis function listed in vectors is not found
            if (.not. found_basis) then
                print *, "Warning: Basis function (state=", state_idx, ", ivib=", current_vib_qn, &
                         ") from vectors file not found in basis data."
            end if
        end if
    end do
!    print *, "Final psi min/max:", minval(psi), maxval(psi)

    ! Debug check (optional)
    ! if (all(psi == 0.0)) then
    !     print *, "Warning: Psi is all zeros after calculation for J=", current_j, ", p=", current_p, ", root=", root, ", state=", state_idx
    ! end if

end subroutine calculate_psi
end module wavefunction_module