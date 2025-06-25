import yaml  # used to read YAML config files
import os  # used to check if a file exists


# Loads a base config file and an optional override file
# Allows access using dot notation like "dataPaths.p5GraphExport"
class ConfigLoader:

    # Runs when a new ConfigLoader is created
    def __init__(self, defaultPath, overridePath="local.yaml"):

        # Load the main config
        with open(defaultPath, "r") as f:
            self.config = yaml.safe_load(f)  # convert YAML to nested Python dict

        # If an override config exists, load and merge it
        if os.path.exists(overridePath):
            with open(overridePath, "r") as f:
                overrides = yaml.safe_load(f)
                self._merge(self.config, overrides)  # apply overrides to base config

    # Recursively merge two dictionaries
    def _merge(self, base, overrides):
        for k, v in overrides.items():
            if isinstance(v, dict) and k in base:
                self._merge(base[k], v)  # go deeper if value is a nested dict
            else:
                base[k] = v  # override or add value

    # Access nested config values using dot notation
    def get(self, keyPath):
        keys = keyPath.split(".")  # split key into parts
        value = self.config
        for key in keys:
            value = value[key]  # step through dictionary layers
        return value