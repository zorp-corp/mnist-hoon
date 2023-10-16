import os
import numpy as np
import torch
import torchvision.transforms as transforms
from torchvision import datasets

def load_and_normalize_mnist():
    # Define a transform to normalize the data
    transform = transforms.Compose([
        transforms.ToTensor(),
    ])
    
    # Download and load the training data
    test_set = datasets.MNIST('./data', download=True, train=False, transform=transform)
    
    return test_set

def save_images_to_disk(dataset, save_path):
    if not os.path.exists(save_path):
        os.makedirs(save_path)
    
    for i, (image, label) in enumerate(dataset):
        label_path = os.path.join(save_path, str(label))
        
        if not os.path.exists(label_path):
            os.makedirs(label_path)
            
        image_file_path = os.path.join(label_path, f"{i}.mnist")
        save_image_as_float32(image, image_file_path)

def save_image_as_float32(tensor, filename):
    tensor = tensor.squeeze(0).detach().numpy() # Remove batch dimension and detach
    with open(filename, 'wb') as f:
        f.write(tensor.astype(np.float32).tobytes())

# Load and normalize the MNIST data
train_set = load_and_normalize_mnist()

# Define path to save images
save_path = './normalized-mnist-images'

# Save images to disk
save_images_to_disk(train_set, save_path)
