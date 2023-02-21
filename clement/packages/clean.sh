find . -type f -name '*py.class' -exec rm {} +;
find . -type f -name '*.pyc' -exec rm {} +;
find . -type d -name '__pycache__' -exec rm -R {} +;
