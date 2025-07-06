# 🖼️ Image Detection GUI (Made with MATLAB)

Welcome! This project is a simple, interactive MATLAB GUI that helps detect **people**, **lights**, and **ceiling fans** in any image you upload. It's built using a mix of deep learning and traditional image processing techniques.

The goal? To help identify if electrical appliances are left on when no one's in the room — saving energy, time, and maybe even a little guilt!

---

## 🔍 What This App Can Do

- 📷 **Upload an image** of a room from your system.
- 🌀 **Fan detection** using circle detection and edge analysis.
- 💡 **Light detection** by checking for bright spots in the ceiling region.
- 👤 **Person detection** using a pre-trained **YOLOv4** model.
- ⚠️ **Smart alert** if the room is empty but the lights or fans are still on.

Everything is neatly visualized in the GUI with real-time status updates.

---

## 🧰 Tools & Tech Behind the Scenes

- MATLAB (of course!)
- **Image Processing Toolbox**
- **Computer Vision Toolbox**
- **Deep Learning Toolbox**
- `yolov4ObjectDetector` with `csp-darknet53-coco` for human detection

---

## 💻 How to Run It

1. Make sure you have MATLAB R2021b (or newer) installed.
2. Install these toolboxes if you haven’t already:
   - Image Processing Toolbox
   - Computer Vision Toolbox
   - Deep Learning Toolbox
3. Download the YOLOv4 model (if you haven’t):
   ```matlab
   yolov4ObjectDetector('csp-darknet53-coco');
