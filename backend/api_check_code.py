import os
from flask import Flask, request, jsonify

app = Flask(__name__)

UPLOAD_FOLDER = './uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/upload', methods=['POST'])
def upload():
    if 'files' not in request.files:
        return jsonify({"error": "No files part in the request"}), 400

    files = request.files.getlist('files')
    saved_files = []

    for file in files:
        filename = file.filename
        file_path = os.path.join(UPLOAD_FOLDER, filename)
        file.save(file_path)
        saved_files.append(filename)

    return jsonify({"message": "Files uploaded successfully", "files": saved_files}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
