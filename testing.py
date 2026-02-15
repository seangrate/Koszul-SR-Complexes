from simplicial import SimplicialComplex

def main():
    # Example usage
    delta = SimplicialComplex([{0, 1, 2, 3, 4, 5}])
    print(f'Faces: {delta.maximal_faces}')
    print(f'Dimension: {delta.dim}')
    print(f'F-vector: {delta.f_vector}')
    print(f'H-vector: {delta.h_vector}')
    print(f'Is Acyclic: {delta.is_acyclic}')
    delta.open_m2_interactive()

main()