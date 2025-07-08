# Modelos TensorFlow Lite

## Estrutura dos Modelos

### gemma_3n_quantized.tflite (Não incluído)
- **Tamanho**: ~200MB (quantizado)
- **Formato**: TensorFlow Lite
- **Quantização**: INT8 para otimização móvel
- **Uso**: Geração de texto offline
- **Idiomas**: Português, Crioulo Bissau-guineense

### Como Obter o Modelo

1. **Converter modelo Gemma 3n para TFLite**:
```python
import tensorflow as tf
from transformers import AutoTokenizer, TFAutoModelForCausalLM

# Carregar modelo Gemma 3n
model = TFAutoModelForCausalLM.from_pretrained("google/gemma-3n-2b")
tokenizer = AutoTokenizer.from_pretrained("google/gemma-3n-2b")

# Converter para TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.lite.constants.INT8]

tflite_model = converter.convert()

# Salvar modelo
with open('gemma_3n_quantized.tflite', 'wb') as f:
    f.write(tflite_model)
```

2. **Colocar arquivo nesta pasta**:
   - `assets/models/gemma_3n_quantized.tflite`

### Configurações de Fallback

O app funcionará sem o modelo TFLite usando:
- Respostas contextuais pré-definidas
- Lógica baseada em palavras-chave
- Integração com backend quando online

### Otimizações Móveis

- **Quantização INT8**: Reduz tamanho em 75%
- **NNAPI**: Usa aceleração de hardware Android
- **Multi-threading**: 4 threads para inferência
- **Caching**: Cache de respostas frequentes
