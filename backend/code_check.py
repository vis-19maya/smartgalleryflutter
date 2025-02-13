from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import face_recognition
import shutil
import numpy as np

# Flask app setup
app = Flask(__name__)
CORS(app)  # To handle CORS for Flutter requests

# Directory to save uploaded images
UPLOAD_FOLDER = 'static\\images\\uploaded_images'
GROUPED_FOLDER = 'static\\images\\grouped_photos'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(GROUPED_FOLDER, exist_ok=True)


@app.route('/upload', methods=['POST'])
def upload():
    try:
        for file in os.listdir(UPLOAD_FOLDER):
            try:
                file_path = os.path.join(UPLOAD_FOLDER, file)
                os.remove(file_path)
            except Exception as e:
                print(f"Error deleting file {file_path}: {e}")

        # Cleanup: Delete GROUPED_FOLDER and its contents
        try:
            shutil.rmtree(GROUPED_FOLDER)
            os.makedirs(GROUPED_FOLDER, exist_ok=True)  # Recreate the folder
        except Exception as e:
            print(f"Error deleting grouped folder {GROUPED_FOLDER}: {e}")

        if 'files' not in request.files:
            return jsonify({"error": "No files part in the request"}), 400

        files = request.files.getlist('files')
        saved_files = []

        for file in files:
            filename = file.filename
            file_path = os.path.join(UPLOAD_FOLDER, filename)
            file.save(file_path)
            saved_files.append(filename)

        # Process the uploaded image for face grouping and get response data
        response_data = check(UPLOAD_FOLDER, GROUPED_FOLDER)

        

        return jsonify(response_data), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


# def check(input_folder, output_folder):
#     """
#     Groups images based on facial similarity and returns a structured response.
#     """
#     try:
#         no_face_folder = os.path.join(output_folder, "no_faces")
#         distance_threshold = 0.5

#         os.makedirs(output_folder, exist_ok=True)
#         os.makedirs(no_face_folder, exist_ok=True)

#         # Get a list of all image files in the input folder
#         image_files = [f for f in os.listdir(input_folder) if f.lower().endswith(('jpg', 'jpeg', 'png'))]

#         # Initialize lists to keep track of face encodings and groups
#         face_groups = []
#         grouped_images = {"no_faces": []}  # Dictionary to store response data

#         # Process each image in the input folder
#         for image_file in image_files:
#             image_path = os.path.join(input_folder, image_file)
#             try:
#                 image = face_recognition.load_image_file(image_path)
#                 face_encodings = face_recognition.face_encodings(image)

#                 if face_encodings:
#                     # Handle only the first face encoding in case of multiple faces
#                     face_encoding = face_encodings[0]
#                     matched_group = None

#                     # Compare the current face encoding to existing groups
#                     for group_index, group_encodings in enumerate(face_groups):
#                         distances = face_recognition.face_distance(group_encodings, face_encoding)
#                         if np.any(distances < distance_threshold):
#                             matched_group = group_index
#                             break

#                     if matched_group is not None:
#                         # Add the image to the matching group
#                         face_groups[matched_group].append(face_encoding)
#                         group_name = f"person_{matched_group + 1}"
#                     else:
#                         # Create a new group
#                         face_groups.append([face_encoding])
#                         group_name = f"person_{len(face_groups)}"
#                         os.makedirs(os.path.join(output_folder, group_name), exist_ok=True)

#                     # Copy the image to the corresponding group folder
#                     shutil.copy2(image_path, os.path.join(output_folder, group_name, image_file))

#                     # Add the image to the grouped_images dictionary with relative path
#                     if group_name not in grouped_images:
#                         grouped_images[group_name] = []
#                     grouped_images[group_name].append(f"{group_name}/{image_file}")
#                 else:
#                     # If no faces are detected, add to the no_face_images list with relative path
#                     shutil.copy2(image_path, os.path.join(no_face_folder, image_file))
#                     grouped_images["no_faces"].append(f"no_faces/{image_file}")

#             except Exception as e:
#                 print(f"Error processing image {image_file}: {e}")

#         print(f"Grouped photos into {len(face_groups)} folders.")
#         print(f"Images with no faces detected saved in '{no_face_folder}'.")
#         return grouped_images

#     except Exception as e:
#         print(f"Error in face grouping: {e}")
#         return {"error": str(e)}

def check(input_folder, output_folder):
    """
    Groups images based on facial similarity and ensures no duplicate groups are created 
    for multiple faces in a single image.
    """
    try:
        no_face_folder = os.path.join(output_folder, "no_faces")
        distance_threshold = 0.5

        os.makedirs(output_folder, exist_ok=True)
        os.makedirs(no_face_folder, exist_ok=True)

        # Get a list of all image files in the input folder
        image_files = [f for f in os.listdir(input_folder) if f.lower().endswith(('jpg', 'jpeg', 'png','webp'))]

        # Initialize lists to keep track of face encodings and groups
        face_groups = []
        grouped_images = {"no_faces": []}  # Dictionary to store response data

        # Process each image in the input folder
        for image_file in image_files:
            image_path = os.path.join(input_folder, image_file)
            try:
                image = face_recognition.load_image_file(image_path)
                face_encodings = face_recognition.face_encodings(image)

                if face_encodings:
                    # Track which faces in the image have already been grouped
                    processed_faces = []

                    for face_index, face_encoding in enumerate(face_encodings):
                        matched_group = None

                        # Compare the current face encoding to existing groups
                        for group_index, group_encodings in enumerate(face_groups):
                            distances = face_recognition.face_distance(group_encodings, face_encoding)
                            if np.any(distances < distance_threshold):
                                matched_group = group_index
                                break

                        if matched_group is not None:
                            # Add this face to the matched group if not already processed
                            if matched_group not in processed_faces:
                                face_groups[matched_group].append(face_encoding)
                                group_name = f"person_{matched_group + 1}"
                                shutil.copy2(image_path, os.path.join(output_folder, group_name, image_file))

                                # Add the image to the grouped_images dictionary
                                if group_name not in grouped_images:
                                    grouped_images[group_name] = []
                                grouped_images[group_name].append(f"{group_name}/{image_file}")
                                processed_faces.append(matched_group)
                        else:
                            # Create a new group for this face
                            face_groups.append([face_encoding])
                            group_name = f"person_{len(face_groups)}"
                            os.makedirs(os.path.join(output_folder, group_name), exist_ok=True)
                            shutil.copy2(image_path, os.path.join(output_folder, group_name, image_file))

                            # Add the image to the grouped_images dictionary
                            if group_name not in grouped_images:
                                grouped_images[group_name] = []
                            grouped_images[group_name].append(f"{group_name}/{image_file}")
                            processed_faces.append(len(face_groups) - 1)
                else:
                    # If no faces are detected, add to the no_face_images list
                    shutil.copy2(image_path, os.path.join(no_face_folder, image_file))
                    grouped_images["no_faces"].append(f"no_faces/{image_file}")

            except Exception as e:
                print(f"Error processing image {image_file}: {e}")

        print(f"Grouped photos into {len(face_groups)} folders.")
        print(f"Images with no faces detected saved in '{no_face_folder}'.")
        return grouped_images

    except Exception as e:
        print(f"Error in face grouping: {e}")
        return {"error": str(e)}

# app.py
import cv2
import numpy as np
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import os


UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/detect', methods=['POST'])
def detect_fake_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    image = request.files['image']
    filename = secure_filename(image.filename)
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    image.save(filepath)

    # Convert image to OpenCV format
    np_img = np.frombuffer(image.read(), np.uint8)
    img = cv2.imdecode(np_img, cv2.IMREAD_COLOR)

    if img is None:
        return jsonify({'error': 'Invalid image'}), 400

    # FAKE IMAGE DETECTION (Blurriness Detection)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    laplacian_var = cv2.Laplacian(gray, cv2.CV_64F).var()

    # Threshold for sharp images (Adjust based on dataset)
    threshold = 50
    is_fake = laplacian_var < threshold

    result = {
        "image_name": filename,
        "blurriness_score": laplacian_var,
        "is_fake": is_fake
    }

    return jsonify(result), 200


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)
