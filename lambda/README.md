### 1. Build Lambda layer

```sh
docker run --rm \
  --entrypoint "" \
  -v "$PWD/lambda/layer":/opt \
  -v "$PWD/lambda/layer":/lambda \
  public.ecr.aws/lambda/python:3.14 \
  /bin/bash -c "pip install -r /lambda/requirements.txt -t /opt/python"
```

### 2. Package the layer and script

```
cd lambda/script
zip -r lambda.zip resize_image.py
```

```
cd lambda/layer
zip -r layer.zip python
```

