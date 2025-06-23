from setuptools import setup, find_packages

setup(
    name='digitai-core',
    version='0.1.0',
    description='DigitAI Core AI Fine-tuning Framework',
    packages=find_packages(),
    install_requires=[
        'pyyaml',
        'sentence-transformers',
        'neo4j'
    ],
    python_requires='>=3.9',
)