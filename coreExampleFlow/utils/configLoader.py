import yaml

class ConfigLoader:
    def __init__(self, configPath):
        with open(configPath, 'r') as f:
            self.config = yaml.safe_load(f)

    def get(self, keyPath):
        keys = keyPath.split('.')
        value = self.config
        for key in keys:
            value = value[key]
        return value