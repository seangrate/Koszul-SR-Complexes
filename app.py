import numpy as np
import networkx as nx
from scipy.spatial import ConvexHull
from scipy.spatial.qhull import QhullError
import matplotlib.path as mpath

from bokeh.plotting import figure, curdoc
from bokeh.models import ColumnDataSource, Div, Button, PreText
from bokeh.events import Tap
from bokeh.layouts import row, column

from simplicial import SimplicialComplex

# --- State Management ---
node_coords = {}
maximal_faces = []
selected_nodes = set()
sc_instance = SimplicialComplex([])

# --- Data Sources ---
source_nodes = ColumnDataSource(data=dict(x=[], y=[], id=[], color=[]))
source_edges = ColumnDataSource(data=dict(xs=[], ys=[], face_tuple=[]))
source_faces = ColumnDataSource(data=dict(xs=[], ys=[], fill_color=[], face_tuple=[]))

def get_maximal_faces(faces):
    if not faces:
        return []
    return [face for face in faces if sum(set(face) <= set(other) for other in faces) == 1]

def update_complex():
    global sc_instance, maximal_faces
    sc_instance = SimplicialComplex(maximal_faces)
    
    # 1. Update Nodes
    colors = ["red" if nid in selected_nodes else "navy" for nid in node_coords.keys()]
    source_nodes.data = dict(
        x=[coords[0] for coords in node_coords.values()],
        y=[coords[1] for coords in node_coords.values()],
        id=list(node_coords.keys()),
        color=colors
    )

    # 2. Update Faces (k >= 2) - Iterate UPWARDS so higher dims draw ON TOP
    face_xs, face_ys, face_colors, face_tuples = [], [], [], []
    color_map = {2: "red", 3: "orange", 4: "yellow", 5: "green", 6: "blue"}

    for k in range(2, sc_instance.dim + 1):
        for face in sc_instance.k_faces(k):
            pts = np.array([node_coords[v] for v in face])
            try:
                hull = ConvexHull(pts)
                hull_pts = pts[hull.vertices]
                face_xs.append(hull_pts[:, 0].tolist())
                face_ys.append(hull_pts[:, 1].tolist())
                face_colors.append(color_map.get(k, "purple"))
                face_tuples.append(tuple(sorted(face)))
            except QhullError:
                pass

    source_faces.data = dict(xs=face_xs, ys=face_ys, fill_color=face_colors, face_tuple=face_tuples)

    # 3. Update Edges (1-simplices)
    edge_xs, edge_ys, edge_tuples = [], [], []
    for e in sc_instance.k_faces(1):
        edge_xs.append([node_coords[e[0]][0], node_coords[e[1]][0]])
        edge_ys.append([node_coords[e[0]][1], node_coords[e[1]][1]])
        edge_tuples.append(tuple(sorted(e)))
    
    source_edges.data = dict(xs=edge_xs, ys=edge_ys, face_tuple=edge_tuples)

    # 4. Update Stats
    if maximal_faces:
        stats_text = f"<b>Dimension:</b> {sc_instance.dim}<br>"
        stats_text += f"<b>f-vector:</b> {sc_instance.f_vector}<br>"
        stats_text += f"<b>Betti Numbers:</b> {sc_instance.betti_numbers}<br>"
    else:
        stats_text = "<b>Complex is empty.</b>"
    stats_div.text = stats_text

def on_tap(event):
    px, py = event.x, event.y
    
    # Hierarchy 1: Check Nodes (Select/Deselect)
    for nid, coords in node_coords.items():
        if dist((px, py), coords) < 0.5:
            if nid in selected_nodes:
                selected_nodes.remove(nid)
            else:
                selected_nodes.add(nid)
            update_complex()
            return

    # Hierarchy 2: Check Edges (Delete)
    for idx, e_tuple in enumerate(source_edges.data['face_tuple']):
        v = (source_edges.data['xs'][idx][0], source_edges.data['ys'][idx][0])
        w = (source_edges.data['xs'][idx][1], source_edges.data['ys'][idx][1])
        if dist_to_segment((px, py), v, w) < 0.2:
            perform_cascading_delete(e_tuple)
            update_complex()
            return
            
    # Hierarchy 3: Check Faces (Delete)
    # Iterate backwards through drawn faces so we click the top-most (highest dimension) first
    for idx in range(len(source_faces.data['face_tuple'])-1, -1, -1):
        f_tuple = source_faces.data['face_tuple'][idx]
        poly_path = mpath.Path(np.column_stack((source_faces.data['xs'][idx], source_faces.data['ys'][idx])))
        if poly_path.contains_point((px, py)):
            perform_cascading_delete(f_tuple)
            update_complex()
            return

    # Hierarchy 4: Empty Canvas (Create Node)
    new_id = max(node_coords.keys(), default=-1) + 1
    node_coords[new_id] = (px, py)
    maximal_faces.append({new_id})
    update_complex()

# --- Hit Detection Math ---
def dist(p1, p2):
    return np.sqrt((p1[0]-p2[0])**2 + (p1[1]-p2[1])**2)

def dist_to_segment(p, v, w):
    l2 = dist(v, w)**2
    if l2 == 0: return dist(p, v)
    t = max(0, min(1, np.dot(np.array(p) - np.array(v), np.array(w) - np.array(v)) / l2))
    proj = np.array(v) + t * (np.array(w) - np.array(v))
    return dist(p, proj)

def perform_cascading_delete(target_simplex):
    global maximal_faces
    target_set = set(target_simplex)
    new_faces = []
    
    for face in maximal_faces:
        if target_set.issubset(face):
            # Replace face with its boundaries that lack the target elements
            for v in target_set:
                sub_face = set(face) - {v}
                if sub_face:
                    new_faces.append(sub_face)
        else:
            new_faces.append(face)
            
    maximal_faces = get_maximal_faces(new_faces)

def create_simplex_action():
    global maximal_faces, selected_nodes
    if len(selected_nodes) > 1:
        maximal_faces.append(set(selected_nodes))
        maximal_faces = get_maximal_faces(maximal_faces)
        selected_nodes.clear()
        update_complex()

def export_action():
    if not maximal_faces:
        export_out.text = "No complex to export."
        return
        
    faces_str = ", ".join([str(set(f)) for f in maximal_faces])
    export_str = f"my_complex = SimplicialComplex([{faces_str}])"
    export_out.text = export_str
    print(f"\n--- EXPORT ---\n{export_str}\n--------------\n")

# --- UI Layout ---
# --- Figure Setup ---
# Use explicit ranges or let them auto-adjust
p = figure(
    title="Simplicial Complex GUI (Double-Click to Delete)", 
    tools="pan,wheel_zoom,reset", 
    match_aspect=True,
    width=800, 
    height=600,
    x_range=(-10, 10), # Initial zoom area
    y_range=(-10, 10)
)

# 1. Add Renderers in specific order: Faces -> Edges -> Nodes
# This ensures lines are on top of faces, and dots are on top of lines.
face_renderer = p.patches('xs', 'ys', source=source_faces, 
                         fill_color='fill_color', fill_alpha=0.6, line_color=None)
edge_renderer = p.multi_line('xs', 'ys', source=source_edges, 
                            line_color="black", line_width=2, line_alpha=0.8)
node_renderer = p.circle('x', 'y', size=15, source=source_nodes, 
                        color='color', alpha=0.9, line_color="white", line_width=2)

# 2. Force Nodes to the front
node_renderer.level = 'overlay' 

# 3. Update the update_complex logic for 1-simplices
# In your class, k_faces(1) returns the edges.
# Ensure the color_map includes higher dimensions
color_map = {
    1: "black",
    2: "red", 
    3: "orange", 
    4: "yellow", 
    5: "green", 
    6: "blue"
}

# Renderers
p.patches('xs', 'ys', source=source_faces, fill_color='fill_color', fill_alpha=0.6, line_color=None)
p.multi_line('xs', 'ys', source=source_edges, line_color="black", line_width=2, line_alpha=0.8)
p.circle('x', 'y', size=15, source=source_nodes, color='color', alpha=0.9)

# Events
p.on_event(Tap, on_tap)

# Side Panel
stats_div = Div(text="<b>Complex is empty.</b>", width=300, height=150)
btn_create = Button(label="Form Simplex from Selection", button_type="success", width=300)
btn_create.on_click(create_simplex_action)

btn_export = Button(label="Export to Python", button_type="primary", width=300)
btn_export.on_click(export_action)
export_out = PreText(text="", width=300, height=100)

side_panel = column(btn_create, stats_div, btn_export, export_out)
layout = row(p, side_panel)

update_complex()
curdoc().add_root(layout)
curdoc().title = "Simplicial Complex GUI"