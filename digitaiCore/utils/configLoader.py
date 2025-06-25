import yaml

#Load in config (Allows use of . notation vs bracketed)
class ConfigLoader:

    #Constructor for class, Auto-Runs when a ConfigLoader object is created
    def __init__(self, configPath):
        with open(configPath, "r") as configFile: #Read file
            self.config = yaml.safe_load(configFile) # Read and parse yaml into nested python directory

    #Split string path into parts, step through path
    def get(self, keyPath):
        keys = keyPath.split(".") # Splits string path into parts
        value = self.config
        for key in keys:
            value = value[key]
        return value