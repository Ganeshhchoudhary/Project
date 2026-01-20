"""
Model Conversion Script
Converts trained TensorFlow models to TensorFlow Lite format with optimization
"""

import tensorflow as tf
import numpy as np
import os
from tensorflow import keras
# from tensorflow_model_optimization import quantization
# from tensorflow_model_optimization.sparsity import keras as sparsity


class ModelConverter:
    """Converts TensorFlow models to TensorFlow Lite with optimization"""
    
    def __init__(self, model_path: str):
        self.model_path = model_path
        self.model = None
    
    def load_model(self):
        """Load the trained model"""
        self.model = keras.models.load_model(self.model_path)
        print(f"Model loaded from {self.model_path}")
        print(f"Model input shape: {self.model.input_shape}")
        print(f"Model output shape: {self.model.output_shape}")
    
    def convert_to_tflite_basic(self, output_path: str):
        """Convert model to basic TensorFlow Lite format"""
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS, tf.lite.OpsSet.SELECT_TF_OPS]
        converter._experimental_lower_tensor_list_ops = False
        tflite_model = converter.convert()
        
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"Basic TFLite model saved to {output_path}")
        print(f"Model size: {len(tflite_model) / 1024:.2f} KB")
    
    def convert_to_tflite_quantized(self, output_path: str, quantization_type: str = "dynamic"):
        """
        Convert model to quantized TensorFlow Lite format
        
        Args:
            output_path: Output file path
            quantization_type: 'dynamic', 'float16', or 'int8'
        """
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        
        if quantization_type == "dynamic":
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
        elif quantization_type == "float16":
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            converter.target_spec.supported_types = [tf.float16]
        elif quantization_type == "int8":
            # For INT8 quantization, representative dataset is needed
            converter.optimizations = [tf.lite.Optimize.DEFAULT]
            # Note: For full INT8 quantization, provide representative_dataset
            # converter.representative_dataset = representative_dataset_gen
        
        tflite_model = converter.convert()
        
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"Quantized TFLite model ({quantization_type}) saved to {output_path}")
        print(f"Model size: {len(tflite_model) / 1024:.2f} KB")
        
        return tflite_model
    
    def convert_with_post_training_quantization(self, output_path: str, representative_dataset):
        """
        Convert with post-training quantization using representative dataset
        
        Args:
            output_path: Output file path
            representative_dataset: Generator function providing representative samples
        """
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.representative_dataset = representative_dataset
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
        converter.inference_input_type = tf.uint8
        converter.inference_output_type = tf.uint8
        
        tflite_model = converter.convert()
        
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"INT8 Quantized TFLite model saved to {output_path}")
        print(f"Model size: {len(tflite_model) / 1024:.2f} KB")
        
        return tflite_model
    
    def test_tflite_model(self, tflite_path: str, test_input: np.ndarray):
        """
        Test the converted TFLite model
        
        Args:
            tflite_path: Path to TFLite model
            test_input: Sample input for testing
        """
        interpreter = tf.lite.Interpreter(model_path=tflite_path)
        interpreter.allocate_tensors()
        
        # Get input and output tensors
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        # Prepare input
        interpreter.set_tensor(input_details[0]['index'], test_input.astype(np.float32))
        
        # Run inference
        interpreter.invoke()
        
        # Get output
        output_data = interpreter.get_tensor(output_details[0]['index'])
        
        print(f"TFLite model tested successfully")
        print(f"Input shape: {test_input.shape}")
        print(f"Output shape: {output_data.shape}")
        print(f"Output: {output_data}")
        
        return output_data


def create_representative_dataset(model_input_shape, num_samples=100):
    """
    Create representative dataset for quantization
    
    Args:
        model_input_shape: Input shape of the model (seq_length, features)
        num_samples: Number of representative samples
    """
    def representative_dataset_gen():
        for _ in range(num_samples):
            # Generate random samples matching model input shape
            yield [np.random.randn(*model_input_shape).astype(np.float32)]
    
    return representative_dataset_gen


def main():
    """Main conversion function"""
    model_path = "../../models/trading_model.h5"
    
    if not os.path.exists(model_path):
        print(f"Model not found at {model_path}")
        print("Please train the model first using train_trading_model.py")
        return
    
    converter = ModelConverter(model_path)
    converter.load_model()
    
    # Convert to basic TFLite
    output_basic = "../../models/trading_model.tflite"
    converter.convert_to_tflite_basic(output_basic)
    
    # # Convert to dynamic quantized TFLite (recommended for mobile)
    # output_quantized = "../../models/trading_model_quantized.tflite"
    # converter.convert_to_tflite_quantized(output_quantized, quantization_type="dynamic")
    
    # # Convert to float16 quantized (smaller size, good accuracy)
    # output_float16 = "../../models/trading_model_float16.tflite"
    # converter.convert_to_tflite_quantized(output_float16, quantization_type="float16")
    
    # # Test the quantized model
    # print("\nTesting quantized model...")
    # test_input = np.random.randn(1, 60, 17).astype(np.float32)  # (batch, sequence, features)
    # converter.test_tflite_model(output_quantized, test_input)
    
    print("\nModel conversion completed!")
    print("Model saved as trading_model.tflite")


if __name__ == "__main__":
    main()

