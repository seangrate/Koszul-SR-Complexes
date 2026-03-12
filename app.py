import numpy as np
import networkx as nx
from scipy.spatial import ConvexHull
from scipy.spatial.qhull import QhullError
import matplotlib.path as mpath
from math import dist
from bokeh.plotting import figure, curdoc
from bokeh.models import ColumnDataSource, Div, Button, PreText
from bokeh.events import Tap, DoubleTap
from bokeh.layouts import row, column

from simplicial import SimplicialComplex

import re
import os
import sys

node_coords = {}
maximal_faces = []
selected_nodes = set()
sc_instance = SimplicialComplex([])

source_nodes = ColumnDataSource(data=dict(x=[], y=[], id=[], color=[]))
source_edges = ColumnDataSource(data=dict(xs=[], ys=[], face_tuple=[]))
source_faces = ColumnDataSource(data=dict(xs=[], ys=[], fill_color=[], face_tuple=[]))

def get_maximal_faces(faces):
    if not faces:
        return []
    return [face for face in faces if sum(set(face) <= set(other) for other in faces) == 1]

def update_complex(run_m2=True):
    global sc_instance, maximal_faces

    if not run_m2:
        colors = ["red" if nid in selected_nodes else "navy" for nid in node_coords.keys()]
        source_nodes.data.update(color=colors)
        return

    sc_instance = SimplicialComplex(maximal_faces)
    
    colors = ["red" if nid in selected_nodes else "navy" for nid in node_coords.keys()]
    source_nodes.data = dict(
        x=[coords[0] for coords in node_coords.values()],
        y=[coords[1] for coords in node_coords.values()],
        id=list(node_coords.keys()),
        color=colors
    )

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
    
    auto_complex()

    source_faces.data = dict(xs=face_xs, ys=face_ys, fill_color=face_colors, face_tuple=face_tuples)

    edge_xs, edge_ys, edge_tuples = [], [], []
    for e in sc_instance.k_faces(1):
        edge_xs.append([node_coords[e[0]][0], node_coords[e[1]][0]])
        edge_ys.append([node_coords[e[0]][1], node_coords[e[1]][1]])
        edge_tuples.append(tuple(sorted(e)))
    
    source_edges.data = dict(xs=edge_xs, ys=edge_ys, face_tuple=edge_tuples)

    if maximal_faces:
        stats_text = f"<b>Maximal Faces:</b> {maximal_faces}<br>"
        stats_text += f"<b>Dimension:</b> {sc_instance.dim}<br>"
        stats_text += f"<b>f-vector:</b> {sc_instance.f_vector}<br>"
        stats_text += f"<b>h-vector:</b> {sc_instance.h_vector}<br>"
        stats_text += f"<b>Is Acyclic:</b> {sc_instance.is_acyclic}<br>"
    else:
        stats_text = "<b>Complex is empty.</b>"
    stats_div.text = stats_text

def on_tap(event):
    px, py = event.x, event.y
    
    for nid, coords in node_coords.items():
        if dist((px, py), coords) < 0.5:
            if nid in selected_nodes:
                selected_nodes.remove(nid)
            else:
                selected_nodes.add(nid)
            update_complex(run_m2=False)
            return

    for idx, e_tuple in enumerate(source_edges.data['face_tuple']):
        v = (source_edges.data['xs'][idx][0], source_edges.data['ys'][idx][0])
        w = (source_edges.data['xs'][idx][1], source_edges.data['ys'][idx][1])
        if dist_to_segment((px, py), v, w) < 0.2:
            perform_cascading_delete(e_tuple)
            update_complex()
            return
            
    for idx in range(len(source_faces.data['face_tuple'])-1, -1, -1):
        f_tuple = source_faces.data['face_tuple'][idx]
        poly_path = mpath.Path(np.column_stack((source_faces.data['xs'][idx], source_faces.data['ys'][idx])))
        if poly_path.contains_point((px, py)):
            perform_cascading_delete(f_tuple)
            update_complex()
            return

    new_id = max(node_coords.keys(), default=-1) + 1
    node_coords[new_id] = (px, py)
    maximal_faces.append({new_id})
    update_complex()

def test_complex():
    data_display_div.text = "<div style='color: #dc3545; font-weight: bold; padding: 10px;'>Running test computation...</div>"
    sc_instance.open_m2_interactive()

def auto_complex():
    auto_display_div.text = "<div style='color: #007bff; font-weight: bold; padding: 10px;'>Loading automatic overview...</div>"
    sc_instance.open_m2_interactive(is_test=False)

def clear_all_action():
    global maximal_faces, node_coords, selected_nodes
    maximal_faces.clear()
    node_coords.clear()
    selected_nodes.clear()
    update_complex()

def exit_action():
    sc_instance.reset_m2_session()
    os._exit(0)

def on_double_tap(event):
    px, py = event.x, event.y
    
    for nid, coords in list(node_coords.items()):
        if dist((px, py), coords) < 0.5:
            # 1. Strip from the mathematical complex
            perform_cascading_delete((nid,))
            
            # 2. Purge from graphical memory and selection state
            del node_coords[nid]
            if nid in selected_nodes:
                selected_nodes.remove(nid)
                
            update_complex()
            return

def dist_to_segment(p, v, w):
    # Squared length of segment vw
    l2 = (v[0] - w[0])**2 + (v[1] - w[1])**2
    
    # v == w case
    if l2 == 0:
        return dist(p, v)

    # Consider the line extending the segment, parameterized as v + t (w - v).
    # We find projection of point p onto the line. 
    # It falls where t = [(p-v) . (w-v)] / |w-v|^2
    # We clamp t from [0,1] to handle points outside the segment.
    t = ((p[0] - v[0]) * (w[0] - v[0]) + (p[1] - v[1]) * (w[1] - v[1])) / l2
    t = max(0, min(1, t))
    
    projection = (v[0] + t * (w[0] - v[0]), 
                  v[1] + t * (w[1] - v[1]))
    
    return dist(p, projection)

def perform_cascading_delete(target_simplex):
    global maximal_faces
    target_set = set(target_simplex)
    new_faces = []
    
    for face in maximal_faces:
        if face <= target_set:
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

def load_and_format_data(filepath="data.txt"):
    if not os.path.exists(filepath):
        return "<b>No data file found.</b>"
        
    with open(filepath, 'r') as f:
        content = f.read()
        
    # Split the document by double newlines to isolate each complex's data block
    blocks = content.strip().split('\n\n')
    html_output = "<div style='font-family: monospace;'>"
    
    for block in blocks:
        lines = block.split('\n')
        html_output += "<div style='margin-bottom: 25px; padding-bottom: 15px; border-bottom: 1px solid #ccc;'>"
        
        for line in lines:
            if not line.strip() or ": " not in line:
                continue
                
            key, val = line.split(": ", 1)
            
            if "Betti Table" in key:
                html_output += f"<b>{key}:</b><br>"
                html_output += format_betti_table(val)
            else:
                html_output += f"<b>{key}:</b> {val}<br>"
                
        html_output += "</div>"
    html_output += "</div>"
    
    return html_output

def format_betti_table(betti_str):
    # Extract tuples: (i, {j}, k) => v
    pattern = r"\((\d+),\{(\d+)\},\d+\)\s*=>\s*(\d+)"
    matches = re.findall(pattern, betti_str)
    
    if not matches:
        return "<i style='color: gray;'>Empty or unparseable Betti table</i><br>"
        
    data = [(int(i), int(j), int(v)) for i, j, v in matches]
    max_i = max(d[0] for d in data)
    
    # Structure rows by j - i to match standard algebraic conventions
    rows = {}
    for i, j, v in data:
        row_idx = j - i
        if row_idx not in rows:
            rows[row_idx] = {}
        rows[row_idx][i] = v
        
    min_row = min(rows.keys())
    max_row = max(rows.keys())
    
    # Construct the HTML table
    table_html = "<table style='border-collapse: collapse; margin-top: 8px; margin-bottom: 12px; text-align: center; font-size: 14px;'>"
    
    # Header row (homological degrees)
    table_html += "<tr><th style='border-right: 1px solid black; padding: 2px 8px;'></th>"
    for col in range(max_i + 1):
        table_html += f"<th style='padding: 2px 8px;'>{col}</th>"
    table_html += "</tr>"
    
    # Underline beneath header
    table_html += f"<tr><td colspan='{max_i + 2}' style='border-top: 1px solid black; height: 4px;'></td></tr>"
    
    # Data rows
    for r in range(min_row, max_row + 1):
        table_html += f"<tr><td style='border-right: 1px solid black; padding: 2px 8px;'><b>{r}</b></td>"
        for col in range(max_i + 1):
            val = rows.get(r, {}).get(col, "-")
            table_html += f"<td style='padding: 2px 8px;'>{val}</td>"
        table_html += "</tr>"
        
    table_html += "</table>"
    return table_html

last_mtime_data = 0
last_mtime_auto = 0

def watch_data_files():
    global last_mtime_data, last_mtime_auto
    
    filepath = "data.txt"
    if os.path.exists(filepath):
        current_mtime = os.path.getmtime(filepath)
        if current_mtime > last_mtime_data:
            last_mtime_data = current_mtime
            data_display_div.text = load_and_format_data(filepath)
            
    autofilepath = "auto.txt"
    if os.path.exists(autofilepath):
        current_mtime = os.path.getmtime(autofilepath)
        if current_mtime > last_mtime_auto:
            last_mtime_auto = current_mtime
            auto_display_div.text = load_and_format_data(autofilepath)

def export_action():
    if not maximal_faces:
        export_out.text = "No complex to export."
        return
        
    faces_str = ", ".join([str(set(f)) for f in maximal_faces])
    export_str = f"my_complex = SimplicialComplex([{faces_str}])"
    export_out.text = export_str
    print(f"\n--- EXPORT ---\n{export_str}\n--------------\n")

p = figure(
    title="Simplicial Complex GUI (Double-Click to Delete)", 
    tools="pan,wheel_zoom,reset", 
    match_aspect=True,
    width=800, 
    height=600,
    x_range=(-10, 10), # Initial zoom area
    y_range=(-10, 10)
)

face_renderer = p.patches('xs', 'ys', source=source_faces, 
                         fill_color='fill_color', fill_alpha=0.6, line_color=None)
edge_renderer = p.multi_line('xs', 'ys', source=source_edges, 
                            line_color="black", line_width=2, line_alpha=0.8)
node_renderer = p.circle('x', 'y', size=15, source=source_nodes, 
                        color='color', alpha=0.9, line_color="white", line_width=2)

node_renderer.level = 'overlay' 

color_map = {
    1: "black",
    2: "red", 
    3: "orange", 
    4: "yellow", 
    5: "green", 
    6: "blue",
    7: "purple",
    8: "pink" # Maybe more later? If we want to do higher dimensions
}

p.patches('xs', 'ys', source=source_faces, fill_color='fill_color', fill_alpha=0.6, line_color=None)
p.multi_line('xs', 'ys', source=source_edges, line_color="black", line_width=2, line_alpha=0.8)
p.circle('x', 'y', size=15, source=source_nodes, color='color', alpha=0.9)

p.on_event(Tap, on_tap)
p.on_event(DoubleTap, on_double_tap)

stats_div = Div(text="<b>Complex is empty.</b>", width=300, height=100)
btn_create = Button(label="Form Simplex from Selection", button_type="success", width=300)
btn_create.on_click(create_simplex_action)

btn_test = Button(label="Run Test Script", button_type="danger", width=300)
btn_test.on_click(test_complex)

btn_clear = Button(label="Clear All Simplices", button_type="warning", width=300)
btn_clear.on_click(clear_all_action)

btn_exit = Button(label="Exit Application", button_type="danger", width=300)
btn_exit.on_click(exit_action)

# --- NEW DATA DISPLAY DIV ---
parsed_html_data = load_and_format_data("data.txt")
data_display_div = Div(
    text=parsed_html_data, 
    width=300, 
    height=300, 
    styles={'overflow-y': 'auto', 'background-color': '#f9f9f9', 'padding': '10px', 'border': '1px solid #ddd'}
)
# ----------------------------

# --- AUTOMATIC OVERVIEW ---
auto_parsed_html_data = load_and_format_data("auto.txt")
auto_display_div = Div(
    text=auto_parsed_html_data, 
    width=300, 
    height=300, 
    styles={'overflow-y': 'auto', 'background-color': '#f9f9f9', 'padding': '10px', 'border': '1px solid #ddd'}
)
# ----------------------------

btn_export = Button(label="Export to Python", button_type="primary", width=300)
btn_export.on_click(export_action)
export_out = PreText(text="", width=300, height=100)

# Define the reset action
def reset_action():
    sc_instance.reset_m2_session()
    export_out.text = "M2 Session Reset. Next run will be a cold-boot."

# Create the button
btn_reset = Button(label="Hard Reset M2 Session", button_type="warning", width=300)
btn_reset.on_click(reset_action)

# Update your side_panel layout to include the new button
side_panel = column(
    btn_create, 
    stats_div, 
    auto_display_div, 
    btn_test, 
    data_display_div, 
    btn_export, 
    btn_clear,
    btn_reset, 
    btn_exit,
    export_out
)
layout = row(p, side_panel)

update_complex()
curdoc().add_root(layout)
curdoc().title = "Simplicial Complex GUI"
curdoc().add_periodic_callback(watch_data_files, 1000)