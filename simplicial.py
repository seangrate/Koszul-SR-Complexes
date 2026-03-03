import functools as ft
import itertools as it
import more_itertools as mit
from typing import List, Set
from itertools import combinations
import matplotlib.pyplot as plt
from matplotlib.collections import PolyCollection
import networkx as nx
import numpy as np
from scipy.optimize import linprog
import subprocess
import os
import time
import tempfile
from utils import smith_normal_form
import json
import threading
import subprocess
import time

class M2Controller:
    _instance = None
    
    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def __init__(self):
        # Invoking bash -lc ensures the WSL environment loads necessary PATH variables
        self.process = subprocess.Popen(
            ["wsl", "bash", "-lc", "M2 --no-readline --quiet"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )
        self.initialized = False
        self.lock = threading.Lock()
        
        # Allow WSL a moment to initialize and verify the process remains active
        time.sleep(1.0)
        if self.process.poll() is not None:
            error_log = self.process.stderr.read()
            print(f"CRITICAL ERROR: M2 Boot Failure. Output:\n{error_log}")

    def run_script(self, script_path):
        with self.lock:
            if self.process.poll() is not None:
                print("Error: The background M2 process has terminated unexpectedly.")
                return

            cmd = f'load "{script_path}"'
            self.process.stdin.write(cmd + '\n')
            self.process.stdin.flush()
            
            delimiter = "---M2_EXECUTION_COMPLETE---"
            self.process.stdin.write(f'print "{delimiter}"\n')
            self.process.stdin.flush()
            
            while True:
                line = self.process.stdout.readline()
                if delimiter in line or not line:
                    break

class SimplicialComplex:
    def __init__(self, faces: List[Set]):
        self.maximal_faces = [face for face in faces if sum(face <= other_face for other_face in faces) == 1]
        self.vertices = sorted(list({v for face in self.maximal_faces for v in face}))

        self.graph = nx.from_edgelist([edge for max_face in self.maximal_faces for edge in it.combinations(max_face, 2)])
        self.graph.add_nodes_from([node for face in self.maximal_faces if len(face) == 1 for node in face]) # add isolates

    def __repr__(self):
        return f'{self.__class__.__name__}({self.maximal_faces})'
    
    def __contains__(self, item):
        if isinstance(item, self.__class__):
            return all(any(item_face <= face for face in self.maximal_faces) for item_face in item.maximal_faces)
        elif isinstance(item, set):
            return any(item <= face for face in self.maximal_faces)
        else:
            raise NotImplementedError(f'Cannot check if {item} is contained in {self.__class__.__name__}')
    
    def __and__(self, other):
        if isinstance(other, self.__class__):
            shared_faces = [self_face & other_face for (self_face, other_face) in it.product(self.maximal_faces, other.maximal_faces)]
            # remove duplicate faces so maximal faces are calculated correctly
            # https://stackoverflow.com/a/32296966            
            return self.__class__([set(unique_face) for unique_face in set(frozenset(face) for face in shared_faces)])
        elif isinstance(other, set):
            return self.__class__([other & face for face in self.maximal_faces])
        else:
            raise NotImplementedError(f'Cannot intersect {other} and {self}')
        
    def __or__(self, other):
        if isinstance(other, self.__class__):
            # remove duplicate faces so maximal faces are calculated correctly
            # https://stackoverflow.com/a/32296966
            return self.__class__([set(unique_face) for unique_face in set(frozenset(face) for face in self.maximal_faces + other.maximal_faces)])
        elif isinstance(other, set):
            return self.__class__(self.maximal_faces + [other])
        else:
            raise NotImplementedError(f'Cannot union {other} and {self}')

    def restriction(self, vertices):
        """Returns the simplicial complex induced by a set of vertices."""    
        return SimplicialComplex([set(subset) for subset in mit.powerset(vertices) if set(subset) in self])

    @ft.cached_property
    def dim(self):
        if not self.maximal_faces:
            return -1
        return max(len(face) for face in self.maximal_faces) - 1

    @ft.cached_property
    def is_pure(self):
        return len(set(len(face) for face in self.maximal_faces)) == 1

    @ft.cached_property
    def is_connected(self):
        if not self.maximal_faces:
            return True
        return nx.is_connected(self.graph)

    @ft.cached_property
    def num_components(self):
        if not self.maximal_faces:
            return 1
        return nx.number_connected_components(self.graph)

    @ft.cached_property
    def is_shellable(self):
        """See shellable iff inductive and pure at each step...?"""
        raise NotImplementedError

    def k_faces(self, k):
        k_faces = {face for max_face in self.maximal_faces for face in it.combinations(max_face, k+1)}
        k_faces = [set(unique_face) for unique_face in set(frozenset(face) for face in k_faces)]
        return [sorted(list(face)) for face in k_faces]
    
    @staticmethod
    def boundary(face):
        return [face[:idx] + face[idx+1:] for idx, _ in enumerate(face)]

    def boundary_matrix(self, k):
        """Returns the differential mapping k-chains to (k-1)-chains with correct alternating signs."""
        k_faces = self.k_faces(k)
        k_minus_one_faces = self.k_faces(k-1)
        
        if not k_faces or not k_minus_one_faces:
            return np.zeros((max(1, len(k_minus_one_faces)), max(1, len(k_faces))))
            
        matrix = np.zeros((len(k_minus_one_faces), len(k_faces)))
        for j, k_face in enumerate(k_faces):
            for i, _ in enumerate(k_face):
                # k_faces are sorted, ensuring valid orientation
                sub_face = k_face[:i] + k_face[i+1:]
                if sub_face in k_minus_one_faces:
                    row_idx = k_minus_one_faces.index(sub_face)
                    matrix[row_idx, j] = (-1)**i
                    
        return matrix

    def betti(self, k: int):
        num_k_faces = len(self.k_faces(k))
        if num_k_faces == 0:
            return 0
            
        # Rank-Nullity Theorem: dim(Ker) - dim(Im)
        rank_k = np.linalg.matrix_rank(self.boundary_matrix(k)) if k > 0 else 0
        
        k_plus_1_faces = self.k_faces(k+1)
        rank_kplus1 = np.linalg.matrix_rank(self.boundary_matrix(k+1)) if k_plus_1_faces else 0
            
        return num_k_faces - rank_k - rank_kplus1

    @ft.cached_property
    def betti_numbers(self):
        return {k: self.betti(k) for k in range(self.dim + 1)}

    @ft.cached_property
    def reduced_betti_numbers(self):
        return {k: betti_number-1 if k == 0 else betti_number for k, betti_number in self.betti_numbers.items()}
    
    @ft.cached_property
    def f_vector(self):
        if not self.maximal_faces:
            return (1,)
        return (1,) + tuple(len(self.k_faces(k)) for k in range(self.dim+1))
    
    @ft.cached_property
    def h_vector(self):
        if not self.maximal_faces:
            return (1,)
        # Stanley's trick can be made into a triangluar array
        # https://stackoverflow.com/a/27682124
        stanleys_trick_array = np.array([0 for _ in range(sum(range(1, self.dim+4))-1)])
        offset = lambda r: (r*(r+1)) // 2
        array_index = lambda r,c: offset(r) + c
        for i, f_i in enumerate(self.f_vector):
            # column of ones
            idx = array_index(i, 0)
            stanleys_trick_array[idx] = 1
            # row of f-vector
            idx = array_index(self.dim+2, i)
            stanleys_trick_array[idx] = f_i
        # compute h-vector via Stanley's trick
        for i in reversed(range(1, self.dim+2)):
            for j in range(1, i+1):
                idx = array_index(i, j)
                left_idx = array_index(i, j-1)
                below_idx = array_index(i+1, j)
                stanleys_trick_array[idx] = stanleys_trick_array[below_idx] - stanleys_trick_array[left_idx]
        # indices on diagonal correspond to triangular numbers: https://oeis.org/A000096
        return tuple(stanleys_trick_array[(i*(i+3)) // 2] for i in range(self.dim+2))


    @ft.cached_property
    def is_acyclic(self):
        return not any(self.reduced_betti_numbers.values())
    
    def draw(self, show: bool = True, **kwargs):
        # Pop custom arguments to prevent NetworkX ValueError
        shade = kwargs.pop('shade', False)
        shade_alpha = kwargs.pop('alpha', 0.2)  # Lower alpha looks better for overlapping faces
        shade_color = kwargs.pop('facecolor', 'skyblue')
        
        # Generate layout
        pos = nx.spring_layout(self.graph, seed=42) # Seed for reproducibility
        
        # Draw 1-skeleton
        nx.draw(self.graph, pos=pos, **kwargs)
        
        if shade:
            self._draw_filled_simplices(pos, shade_color, shade_alpha)
            
        if show:
            plt.show()

    def _draw_filled_simplices(self, pos, color, alpha):
        ax = plt.gca()
        triangles = []
        
        for face in self.maximal_faces:
            if len(face) < 3:
                continue
                
            # For any face of dimension >= 2, we decompose it into triangles (2-simplices)
            # This allows us to visualize the "surface" of high-dim simplices in 2D
            for sub_face in combinations(face, 3):
                coords = [pos[node] for node in sub_face]
                triangles.append(coords)

        # Use zorder=0 to ensure faces are behind nodes/edges
        poly_col = PolyCollection(
            triangles, 
            facecolors=color, 
            edgecolors='none', 
            alpha=alpha, 
            zorder=0
        )
        ax.add_collection(poly_col)
    # ----------------------------------------------------
    # MACAULAY2 INTEGRATION (WSL) - Updated for Monomials
    # ----------------------------------------------------

    def _generate_m2_setup(self):
        """
        Generates the M2 code block that defines the Ring and the Complex.
        Returns a string of M2 code.
        """
        # 1. Determine the range of variables needed
        # We assume vertices are integers. We find the min and max to define the ring.
        all_vertices = sorted(list(set().union(*self.maximal_faces)))
        
        if not all_vertices:
            return 'R = QQ[x_1]; K = simplicialComplex {};'

        min_v = min(all_vertices)
        max_v = max(all_vertices)
        
        # 2. Define the Ring (e.g., R = ZZ/32749[x_1..x_6])
        # We use 'QQ' (rationals) as the base field.
        ring_def = f"R = (ZZ/32749)[x_{min_v}..x_{max_v}];"

        # 3. Convert faces to monomials
        # Python {1, 2, 5} -> M2 "x_1*x_2*x_5"
        monomials = []
        for face in self.maximal_faces:
            # Sort indices to ensure x_1*x_2, not x_2*x_1
            sorted_indices = sorted(list(face))
            # Create the term string
            term = "*".join([f"x_{i}" for i in sorted_indices])
            monomials.append(term)
        
        monomials_str = ", ".join(monomials)
        
        # 4. Define the Complex
        complex_def = f"K = simplicialComplex {{{monomials_str}}};"
        
        return f"{ring_def}\n{complex_def}"
    def open_m2_interactive(self, is_test=True):
        project_dir = r"C:\Users\remem\OneDrive\Desktop\Math\Koszul-SR-Complexes"
        
        def to_wsl(win_path):
            return win_path.replace("C:", "/mnt/c").replace("\\", "/")
        
        wsl_project_path = to_wsl(project_dir)
        temp_filename = "temp_m2_interactive.m2"
        win_temp_path = os.path.join(project_dir, temp_filename)
        wsl_temp_path = f"{wsl_project_path}/{temp_filename}"
        session_name = "M2_Session"

        check_session = subprocess.run(
            ["wsl", "tmux", "has-session", "-t", session_name], 
            capture_output=True, text=True
        )
        session_exists = (check_session.returncode == 0)

        init_script = f"""
        print "--- INITIALIZING M2 SESSION ---";
        path = path | {{"{wsl_project_path}/"}};
        loadPackage "SimplicialComplexes";
        print "-- LOADED SIMPLICIAL COMPLEXES PACKAGE --";
        load "{wsl_project_path}/LefschetzProperties/Code/bars.m2";
        load "{wsl_project_path}/LefschetzProperties/Code/hessians.m2";
        load "{wsl_project_path}/LefschetzProperties/Code/koszulTails.m2";
        load "{wsl_project_path}/LefschetzProperties/Code/lefschetz.m2";
        print "-- LOADED LEFSCHETZ PROPERTIES PACKAGE --";
        """

        setup_script = self._generate_m2_setup()
        
        if is_test:
            action_script = f"""
            {setup_script}
            print "--- SUCCESS: K IS DEFINED ---";
            load "{wsl_project_path}/datacollection.m2";
            print "-- LOADED DATA COLLECTION PACKAGE --";
            dataList = dataCollection(R, K);
            outputText = "./data.txt";
            outputJSON = "./data.json";
            headers = {{"{ '", "'.join(["Name", "H-Vector", "Hilbert Series", "Hilbert Multiplicity", "Betti Table", "Is Artinian", "HasWLP", "HasSLP", "HasKoszulTail", "KoszulTails", "HasMaximalKoszulTail"]) }"}}
            for data in dataList do (
                apply(headers, data, (headerName, dataEntry) -> (
                    outputText << headerName | ": " << toString(dataEntry) << endl;
                ));
                outputText << endl;
            );
            outputText << close;
            outputJSON << toString dataList << close;
            print "--- DATA COLLECTION COMPLETE ---";
            """
        else:
            action_script = f"""
            {setup_script}
            print "--- SUCCESS: K IS DEFINED ---";
            load "{wsl_project_path}/autooverview.m2";
            print "-- LOADED AUTO-OVERVIEW PACKAGE --";
            dataList = autoOverview(R, K);
            outputText = "./auto.txt";
            outputJSON = "./auto.json";
            headers = {{"{ '", "'.join(["Name", "H-Vector", "Hilbert Series", "Hilbert Multiplicity", "Betti Table", "Is Artinian", "HasWLP", "HasSLP", "HasKoszulTail", "KoszulTails", "HasMaximalKoszulTail"]) }"}}
            for data in dataList do (
                apply(headers, data, (headerName, dataEntry) -> (
                    outputText << headerName | ": " << toString(dataEntry) << endl;
                ));
                outputText << endl;
            );
            outputText << close;
            outputJSON << toString dataList << close;
            print "--- DATA COLLECTION COMPLETE ---";
            """

        if session_exists:
            script_content = action_script
        else:
            script_content = init_script + action_script

        script_content = script_content.replace('\r\n', '\n')
        
        with open(win_temp_path, "w", newline='\n') as f:
            f.write(script_content)

        def run_tmux_task():
            if session_exists:
                subprocess.run(["wsl", "tmux", "send-keys", "-t", session_name, f'load "{wsl_temp_path}"', "Enter"])
            else:
                subprocess.run(["wsl", "tmux", "kill-session", "-t", session_name], capture_output=True)
                
                robust_cmd = f"trap 'tmux kill-session -t {session_name}' EXIT; tmux new-session -s {session_name} M2"
                full_command = f'cmd /c start wsl --cd "{project_dir}" bash -c "{robust_cmd}"'
                
                subprocess.Popen(full_command, shell=True)
                
                # A sleep is solely required here to let the cold-boot environment settle
                time.sleep(3.0)
                subprocess.run(["wsl", "tmux", "send-keys", "-t", session_name, f'load "{wsl_temp_path}"', "Enter"])

        # Dispatch the terminal commands to a background thread to prevent UI freezing
        import threading
        threading.Thread(target=run_tmux_task, daemon=True).start()

class MultidegreeComplex(SimplicialComplex):
    def __init__(self, multidegree: np.ndarray, semigroup_generators: np.ndarray):
        super().__init__(self._compute_max_faces(multidegree, semigroup_generators))
        self.multidegree = multidegree
        self.semigroup_generators = semigroup_generators

    @staticmethod
    def is_in_cone(lattice_points, target_point):
        return linprog(np.zeros(lattice_points.shape[1]), A_eq=lattice_points, b_eq=target_point, bounds=(0, None), integrality=1).success
    
    def _compute_max_faces(self, multidegree, semigroup_generators):
        # faces are represented with indices
        all_faces = [set(face) for face in mit.powerset(range(semigroup_generators.shape[1]))
                                    if self.is_in_cone(semigroup_generators, multidegree - semigroup_generators[:, face].sum(axis=1))]
        all_faces = [face for face in all_faces if face]
        return [face for face in all_faces if sum(face <= other_face for other_face in all_faces) == 1]


class AlexanderDual(SimplicialComplex):
    def __init__(self, dual_maximal_faces):
        vertex_set = set(mit.flatten(dual_maximal_faces))
        super().__init__([set(A) for A in mit.powerset(vertex_set) if not any(vertex_set - set(A) <= dual_face for dual_face in dual_maximal_faces)])
        self.dual_maximal_faces = dual_maximal_faces


class StanleyReisnerComplex(SimplicialComplex):
    def __init__(self, nonfaces):
        vertex_set = set(mit.flatten(nonfaces))
        super().__init__([vertex_set - nonface for nonface in nonfaces])
        self.nonfaces = nonfaces