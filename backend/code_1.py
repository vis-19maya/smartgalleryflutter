import face_recognition
import os
import shutil
import numpy as np

# Paths for input and output folders
input_folder = "D:\\Flutter Coding\\gallery\\backend\\uploaded_images"
output_folder = "D:\\Flutter Coding\\gallery\\backend\\grouped_photos"
no_face_folder = os.path.join(output_folder, "no_faces")
distance_threshold = 0.5

os.makedirs(output_folder, exist_ok=True)
os.makedirs(no_face_folder, exist_ok=True)

# Get a list of all image files in the input folder
image_files = [f for f in os.listdir(input_folder) if f.endswith(('jpg', 'jpeg', 'png'))]

# Initialize lists to keep track of face encodings and groups
all_encodings = []
face_groups = []
grouped_image_paths = []
no_face_images = []

# Process each image in the input folder
for image_file in image_files:
    image_path = os.path.join(input_folder, image_file)
    image = face_recognition.load_image_file(image_path)
    face_encodings = face_recognition.face_encodings(image)

    if face_encodings:
        # Handle only the first face encoding in case of multiple faces
        face_encoding = face_encodings[0]
        matched_group = None

        # Compare the current face encoding to existing groups
        for group_index, group_encodings in enumerate(face_groups):
            distances = face_recognition.face_distance(group_encodings, face_encoding)
            if np.any(distances < distance_threshold):
                matched_group = group_index
                break

        if matched_group is not None:
            # Add the image to the matching group
            face_groups[matched_group].append(face_encoding)
            group_folder = os.path.join(output_folder, f"person_{matched_group + 1}")
        else:
            # Create a new group
            face_groups.append([face_encoding])
            group_folder = os.path.join(output_folder, f"person_{len(face_groups)}")
            os.makedirs(group_folder, exist_ok=True)

        # Copy the image to the corresponding group folder
        shutil.copy2(image_path, os.path.join(group_folder, image_file))
    else:
        # If no faces are detected, add to the no_face_images list
        no_face_images.append(image_path)

# Save images with no faces to the no_face_folder
for no_face_image in no_face_images:
    shutil.copy2(no_face_image, os.path.join(no_face_folder, os.path.basename(no_face_image)))

print(f"Grouped photos into {len(face_groups)} folders.")
print(f"Images with no faces detected saved in '{no_face_folder}'.")
