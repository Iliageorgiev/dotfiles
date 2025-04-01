import sys
import os
import subprocess
import threading
import json

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QVBoxLayout, QHBoxLayout, QWidget,
    QPushButton, QLabel, QGridLayout, QSizePolicy, QFrame , QScrollArea
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QPixmap


        

        


                 
class VideoThumbnailGenerator(threading.Thread):
    def __init__(self, video_file, thumbnail_path):
        super().__init__()
        self.video_file = video_file
        self.thumbnail_path = thumbnail_path
        self.pixmap = None

    def run(self):
        # Generate a unique temporary preview image for each video
        if os.path.exists(self.thumbnail_path):
            self.pixmap = QPixmap(self.thumbnail_path)
        else:
            command = [
                "ffmpeg", "-i", self.video_file, "-ss", "00:00:01.000",
                 "-s", "300:200", "-vframes", "1", self.thumbnail_path, "-y"
            ]
            try:
                subprocess.run(command, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                if os.path.exists(self.thumbnail_path):
                    self.pixmap = QPixmap(self.thumbnail_path)
                else:
                    print(f"Error generating preview for {self.video_file}")

            except subprocess.CalledProcessError as e:
                print(f"Error generating preview for {self.video_file}: {e}")



class VideoWallApp(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("shitamari")
        
        self.setGeometry(100, 100, 910, 600)
        self.frames = [] # Initialize an empty list to store frames
        # Main layout
        self.central_widget = QWidget()
        self.setCentralWidget(self.central_widget)
        main_layout = QVBoxLayout(self.central_widget)
        
        # Scroll area       
        self.scroll_area = QScrollArea()
        self.scroll_area.setWidgetResizable(True)
        main_layout.addWidget(self.scroll_area)
        
        # Scroll area content       
        self.scroll_content = QWidget()
        self.scroll_area.setWidget(self.scroll_content)
        scroll_layout = QVBoxLayout(self.scroll_content)
        
        # Grid layout for video thumbnails
        self.grid_layout = QGridLayout()
        scroll_layout.addLayout(self.grid_layout)
        

        # Bottom-right buttons
        button_layout = QHBoxLayout()
        button_layout.addStretch()  # Push buttons to the right

        self.ok_button = QPushButton("OK")
        self.ok_button.clicked.connect(self.on_ok_clicked)
        self.ok_button.setEnabled(False)  # Disabled until a video is selected
        button_layout.addWidget(self.ok_button)

        self.cancel_button = QPushButton("Cancel")
        self.cancel_button.clicked.connect(self.on_cancel_clicked)
        button_layout.addWidget(self.cancel_button)

        main_layout.addLayout(button_layout)

        # Placeholder for selected file path
        self.selected_file = None
        self.selected_label = None  # Keep track of the selected QLabel

        # Load video files from the static directory and display thumbnails
        self.load_video_files()
    def load_usage_data(self, usage_data=None):
        """Load video usage data from a JSON file."""
        usage_file = "video_usage.json"
        if usage_data is None:
            if os.path.exists(usage_file):
                with open(usage_file, "r") as f:
                    return json.load(f)
            else:
                return {}
        else:
            return usage_data
                
    def load_video_files(self):
        """Load .mp4 files from the static directory into a grid with image previews."""
        video_extensions = (".mp4")
        video_directory = "/mnt/4d106a33-00b7-4b0f-9386-d7bb389d3bcc/backup/Videos/Hidamari/"

        # Load usage data
        usage_data = self.load_usage_data()
        
         
        # Limit the maximum visible images to 6
        self.grid_layout.setColumnStretch(6, 1) # Add a stretch column to push the thumnails to the left
        if os.path.exists(video_directory):
        # Collect video files and their usage
            video_files = []
            for filename in os.listdir(video_directory):
                if filename.endswith(video_extensions):
                    file_path = os.path.join(video_directory, filename)
                    usage_count = usage_data.get(filename, 0)
                    video_files.append((file_path, usage_count))
            
            # Sort video files by usage count (most-used first)
            video_files.sort(key=lambda x: x[1], reverse=True)
            
            # Display thumbnails
            row, col = 0, 0
            thumbnail_directory = os.path.join(video_directory, "thumbnails")
            if not os.path.exists(thumbnail_directory):
                os.makedirs(thumbnail_directory)
            
            for video_file, _ in video_files:
                filename = os.path.basename(video_file)
                thumbnail_path = os.path.join(thumbnail_directory, filename[:-4] + ".jpg")
                self.add_video_thumbnail(video_file, thumbnail_path, row, col)
                col += 1
                if col > 3:
                    col = 0
                    row += 1
        else:
            print(f"Directory {video_directory} does not exist!")
            
    
    def add_video_thumbnail(self, video_file, thumbnail_path, row, col):
        """Generate a unique video thumbnail and add it to the grid."""
        # Create a VideoThumbnailGenerator instance
        generator = VideoThumbnailGenerator(video_file, thumbnail_path)

        # Start the thumbnail generation thread
        generator.start()

        # Wait for the thumbnail generation thread to finish
        generator.join()

        if generator.pixmap.isNull():
            return

        # Create a frame to hold the thumbnail for highlighting
        frame = QFrame(self)
        frame.setLineWidth(1)
        frame.setFrameShape(QFrame.Shape.Box)
        frame.setLineWidth(1)
        self.frames.append(frame) # Store the frame in our list

        # Create a label to hold the thumbnail inside the frame
        label = QLabel(self)
        label.setPixmap(generator.pixmap.scaled(200, 150, Qt.AspectRatioMode.KeepAspectRatio))
        label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        label.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
        label.mousePressEvent = lambda event, file=video_file, lbl=label, frm=self.frames[-1]: self.on_thumbnail_clicked(file, lbl, frm)
        frame.setLayout(QVBoxLayout())
        frame.layout().addWidget(label)

        # Add the frame (with the thumbnail) to the grid layout
        self.grid_layout.addWidget(frame, row, col)
        

    def on_thumbnail_clicked(self, video_file, label, frame):
            """Handle thumbnail click, mark video as selected, and highlight."""
            self.selected_file = video_file
            # Reset previous selection highlight
            if self.selected_label is not None:
                self.selected_label.parentWidget().setStyleSheet("")
            # Highlight the selected thumbnail
            frame.setStyleSheet("border: 2px ridge rgba(128, 0, 128, 0); border-radius:5px;background-color: rgba(128, 0, 128, 0.6);")
            self.selected_label = label
            # Enable the OK button
            self.ok_button.setEnabled(True)
        
        
    def save_usage_data(self, usage_data):
        """Save video usage data to a JSON file."""
        usage_file = "video_usage.json"
        with open(usage_file, "w") as f:
            json.dump(usage_data, f)    
       
        
        

    def on_ok_clicked(self):
                """Handle the OK button click event."""
                if self.selected_file:
                    # Load and update usage data
                    filename = os.path.basename(self.selected_file)
                    usage_data = self.load_usage_data()
                    usage_data[filename] = usage_data.get(filename, 0) + 1
                    self.save_usage_data(usage_data)
                    print(f"{self.selected_file}")
                    self.close()
                else:
                    print("No file selected!")
            

    def on_cancel_clicked(self):
        """Handle the Cancel button click event."""
        print("Selection canceled.")
        self.close()


os.environ["QT_QPA_PLATFORMTHEME"] = "gtk3"

def main():
    # Set environment variable to use GTK theme with Qt6
    
    # Create the application
    app = QApplication(sys.argv)
    app.setOrganizationName("Qjmiuq")
    app.setOrganizationDomain("Shitamari")
    app.setApplicationName("shitamari")
    

    # Apply a GTK style to the app (optional)
    app.setStyle("Adwaita-Dark")  # or "Windows", "Fusion", etc., based on what's available in your environment

    # Create the main window
    window = VideoWallApp()
    window.show()

    # Run the application
    sys.exit(app.exec())

if __name__ == "__main__":
    main()






