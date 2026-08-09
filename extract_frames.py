import cv2
import os
from PIL import Image

video_path = r"C:\Users\MIDHUN\Downloads\watermark-removed-video.mp4"
output_dir = r"C:\Users\MIDHUN\.gemini\antigravity-ide\scratch\novus-web\assets\frames"
web_output_dir = r"C:\Users\MIDHUN\.gemini\antigravity-ide\scratch\novus-web\web\assets\frames"

os.makedirs(output_dir, exist_ok=True)
os.makedirs(web_output_dir, exist_ok=True)

cap = cv2.VideoCapture(video_path)
total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
fps = cap.get(cv2.CAP_PROP_FPS)

print(f"Total video frames: {total_frames}, FPS: {fps}")

target_frame_count = 240
frame_indices = [int(i * (total_frames - 1) / (target_frame_count - 1)) for i in range(target_frame_count)]

extracted_count = 0
for idx, target_idx in enumerate(frame_indices, start=1):
    cap.set(cv2.CAP_PROP_POS_FRAMES, target_idx)
    ret, frame = cap.read()
    if ret:
        # Convert BGR (OpenCV) to RGB (PIL)
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        img = Image.fromarray(rgb_frame)
        
        # Save as WebP
        filename = f"frame_{idx:03d}.webp"
        out_path = os.path.join(output_dir, filename)
        web_out_path = os.path.join(web_output_dir, filename)
        
        img.save(out_path, format="WEBP", quality=82, method=4)
        img.save(web_out_path, format="WEBP", quality=82, method=4)
        extracted_count += 1

cap.release()
print(f"Successfully extracted {extracted_count} WebP frames to {output_dir}")
