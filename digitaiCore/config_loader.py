import yaml

class ConfigLoader:
    def __init__(self, config_path):
        if not config_path.endswith(".yaml") and not config_path.endswith(".yml"):
            raise ValueError("Config file must be a .yaml or .yml file")

        try:
            with open(config_path, "r") as f:
                self.config = yaml.safe_load(f)
        except FileNotFoundError:
            raise FileNotFoundError(f"[ERROR] Config file not found: {config_path}")
        except yaml.YAMLError as e:
            raise ValueError(f"[ERROR] YAML parsing error: {e}")

    def get(self, key_path):
        keys = key_path.split(".")
        value = self.config
        for key in keys:
            if key not in value:
                raise KeyError(f"[ERROR] Key '{key}' not found in config path '{key_path}'")
            value = value[key]
        return value