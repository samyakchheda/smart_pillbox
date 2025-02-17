import numpy as np
from stl import mesh

# ---------------------------
# Helper Functions
# ---------------------------

def create_cylindrical_shell_open(outer_radius, inner_radius, height, center, num_segments=72):
    """
    Creates an open cylindrical shell (only the side faces) without top and bottom rims.
    
    Parameters:
      outer_radius - Outer radius of the shell.
      inner_radius - Inner radius of the shell.
      height       - Height of the shell.
      center       - [x, y, z] coordinate of the bottom of the shell.
      num_segments - Number of segments used to approximate the circles.
      
    Returns:
      vertices, faces as numpy arrays.
    """
    outer_bottom = []
    outer_top = []
    inner_bottom = []
    inner_top = []
    
    for i in range(num_segments):
        angle = 2 * np.pi * i / num_segments
        # Outer circle vertices
        ob_x = center[0] + outer_radius * np.cos(angle)
        ob_y = center[1] + outer_radius * np.sin(angle)
        outer_bottom.append([ob_x, ob_y, center[2]])
        outer_top.append([ob_x, ob_y, center[2] + height])
        # Inner circle vertices
        ib_x = center[0] + inner_radius * np.cos(angle)
        ib_y = center[1] + inner_radius * np.sin(angle)
        inner_bottom.append([ib_x, ib_y, center[2]])
        inner_top.append([ib_x, ib_y, center[2] + height])
    
    # Combine vertices in order:
    #   outer_bottom: indices 0 .. num_segments-1
    #   outer_top:    indices num_segments .. 2*num_segments-1
    #   inner_bottom: indices 2*num_segments .. 3*num_segments-1
    #   inner_top:    indices 3*num_segments .. 4*num_segments-1
    vertices = outer_bottom + outer_top + inner_bottom + inner_top
    faces = []
    
    # Create side faces for the outer wall
    for i in range(num_segments):
        next_i = (i + 1) % num_segments
        faces.append([i, next_i, num_segments + i])
        faces.append([next_i, num_segments + next_i, num_segments + i])
    
    # Create side faces for the inner wall (flip order so normals point inward)
    for i in range(num_segments):
        next_i = (i + 1) % num_segments
        faces.append([2*num_segments + i, 3*num_segments + i, 3*num_segments + next_i])
        faces.append([2*num_segments + i, 3*num_segments + next_i, 2*num_segments + next_i])
    
    return np.array(vertices), np.array(faces)

def create_rectangular_prism(corners):
    """
    Creates a rectangular prism (box) given 8 corner points.
    
    The corners should be provided in order:
      - Bottom face: v0, v1, v2, v3 (clockwise order)
      - Top face: v4, v5, v6, v7 (corresponding to v0, v1, v2, v3)
      
    Returns:
      vertices, faces as numpy arrays.
    """
    faces = []
    # Bottom face (2 triangles)
    faces.append([0, 1, 2])
    faces.append([0, 2, 3])
    # Top face (2 triangles; reversed order for proper normals)
    faces.append([4, 6, 5])
    faces.append([4, 7, 6])
    # Side faces (each side as 2 triangles)
    faces.append([0, 1, 5])
    faces.append([0, 5, 4])
    
    faces.append([1, 2, 6])
    faces.append([1, 6, 5])
    
    faces.append([2, 3, 7])
    faces.append([2, 7, 6])
    
    faces.append([3, 0, 4])
    faces.append([3, 4, 7])
    
    return np.array(corners), np.array(faces)

def create_radial_partition(theta, r_inner, r_outer, height, z_base, wall_thickness):
    """
    Creates a radial partition (a thin wall) as a rectangular prism.
    
    The wall is placed along the line at angle theta from the center,
    extending from radius r_inner to r_outer.
    
    Parameters:
      theta         - Angle (in radians) where the partition is placed.
      r_inner       - Inner radius (start of the wall).
      r_outer       - Outer radius (end of the wall).
      height        - Height of the partition.
      z_base        - Z coordinate for the bottom of the partition.
      wall_thickness- Thickness of the wall.
      
    Returns:
      vertices, faces for the partition prism.
    """
    # Compute the radial direction unit vector
    r_vec = np.array([np.cos(theta), np.sin(theta)])
    # Compute the perpendicular (tangent) unit vector
    perp = np.array([-np.sin(theta), np.cos(theta)])
    
    # Determine the centerline endpoints of the wall in 2D
    inner_point = np.array([r_inner * np.cos(theta), r_inner * np.sin(theta)])
    outer_point = np.array([r_outer * np.cos(theta), r_outer * np.sin(theta)])
    
    # Offset for half the wall thickness in the perpendicular direction
    offset = (wall_thickness / 2.0) * perp
    
    # Define the 4 corners of the bottom face in 2D
    p0 = inner_point + offset
    p1 = inner_point - offset
    p2 = outer_point - offset
    p3 = outer_point + offset
    
    # Bottom face (z = z_base) and top face (z = z_base + height)
    bottom_corners = [
        [p0[0], p0[1], z_base],
        [p1[0], p1[1], z_base],
        [p2[0], p2[1], z_base],
        [p3[0], p3[1], z_base]
    ]
    top_corners = [
        [p0[0], p0[1], z_base + height],
        [p1[0], p1[1], z_base + height],
        [p2[0], p2[1], z_base + height],
        [p3[0], p3[1], z_base + height]
    ]
    corners_all = bottom_corners + top_corners
    return create_rectangular_prism(corners_all)

def combine_meshes(mesh_list):
    """
    Combines multiple meshes (each as (vertices, faces)) into a single mesh.
    
    This function adjusts face indices for each mesh and concatenates them.
    """
    all_vertices = []
    all_faces = []
    for vertices, faces in mesh_list:
        offset = len(all_vertices)
        all_vertices.extend(vertices)
        all_faces.extend(faces + offset)
    return np.array(all_vertices), np.array(all_faces)

# ---------------------------
# Parameters for the Middle Part (Compartments)
# ---------------------------
wall_height = 1.0              # Height of the open container (compartments area)
outer_wall_outer_radius = 5    # Outer radius of the container wall
outer_wall_inner_radius = 4.5  # Inner radius of the container wall

# Parameters for radial partitions (compartment dividers)
compartment_height = wall_height  # Partitions span the entire height
r_inner_comp = 0.5                # Inner radius where compartments begin
r_outer_comp = outer_wall_inner_radius  # Outer radius for compartments (touching the inner wall)
wall_thickness = 0.2              # Thickness of each radial partition wall
num_partitions = 21               # 21 compartments => 21 radial partitions

# ---------------------------
# Mesh Creation for the Middle Part
# ---------------------------

# Create the outer container wall as an open cylindrical shell (no top and bottom rims)
wall_vertices, wall_faces = create_cylindrical_shell_open(
    outer_wall_outer_radius,
    outer_wall_inner_radius, 
    wall_height, 
    center=[0, 0, 0],
)

# Create the 21 radial partitions (compartment dividers)

partitions = []
angle_step = 2 * np.pi / num_partitions

for i in range(num_partitions):
    theta = i * angle_step
    # For an open container, partitions start at z=0.
    part_vertices, part_faces = create_radial_partition(
        theta, r_inner_comp, r_outer_comp, compartment_height, 0, wall_thickness
    )
    partitions.append((part_vertices, part_faces))

# Combine the outer wall and all partitions into one mesh
mesh_list = []
mesh_list.append((wall_vertices, wall_faces))
for part in partitions:
    mesh_list.append(part)

all_vertices, all_faces = combine_meshes(mesh_list)

# ---------------------------
# Generate and Save the STL Mesh
# ---------------------------

pillbox_mesh = mesh.Mesh(np.zeros(all_faces.shape[0], dtype=mesh.Mesh.dtype))
for i, f in enumerate(all_faces):
    for j in range(3):
        pillbox_mesh.vectors[i][j] = all_vertices[f[j]]

pillbox_mesh.save('smart_pillbox_middle.stl')
print("Smart Pillbox middle part with 21 compartments created as 'smart_pillbox_middle.stl'!")
