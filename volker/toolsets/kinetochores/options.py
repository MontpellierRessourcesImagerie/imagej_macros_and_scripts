import appdirs
import json
import os
from collections import OrderedDict
from copy import copy




class Options:


    def __init__(self, applicationName, optionsName):
        self.optionsName = optionsName
        self.applicationName = applicationName
        self.items = OrderedDict()
        self.defaultItems = None
        appName = self.applicationName.replace(' ', '_')
        self.dataFolder = appdirs.user_data_dir(appName)
        if not os.path.exists(self.dataFolder):
            os.makedirs(self.dataFolder)
        optName = self.optionsName.replace(' ', '_').lower()
        self.optionsPath = os.path.join(self.dataFolder, optName + "_options.json")


    def setDefaultValues(self, defaultItems):
        self.defaultItems = defaultItems


    def getItems(self):
        if not self.items and self.defaultItems:
            self.items = copy(self.defaultItems)
        return self.items


    def save(self):
        with open(self.optionsPath, 'w') as f:
            json.dump(self.getItems(), f)


    def load(self):
        if not os.path.exists(self.optionsPath):
            self.save()
        with open(self.optionsPath) as f:
            items = json.load(f)
        for key, value in items.items():
            if value['transient']:
                continue
            self.items[key] = value


    def get(self, name):
        return self.items[name]


    def value(self, name):
        return self.get(name)['value']


    def set(self, name, value):
        self.items[name] = value


    def addImage(self, name='image', value=None, transient=True, position=None, callback=None):
        position = self._getPosition(position)
        self.items[name] = {'value': value,
                            'type': 'image',
                            'transient': transient,
                            'position': position,
                            'callback': callback}


    def addFFT(self, name='image', value=None, transient=True, position=None, callback=None):
        position = self._getPosition(position)
        self.items[name] = {'value': value,
                            'type': 'fft',
                            'transient': transient,
                            'position': position,
                            'callback': callback}


    def addInt(self, name, value=1, transient=False, position=None, widget="input", callback=None):
        position = self._getPosition(position)
        self.items[name] = {'type': 'int',
                            'value': value,
                            'transient': transient,
                            'position': position,
                            'widget': widget,
                            'callback': callback}


    def addFloat(self, name, value=0.0, transient=False, position=None, widget="input", callback=None):
        position = self._getPosition(position)
        self.items[name] = {'type': 'float',
                            'value': value,
                            'transient': transient,
                            'position': position,
                            'widget': widget,
                            'callback': callback}


    def addChoice(self, name="footprint", value=None, choices=None, transient=False, position=None, callback=None):
        position = self._getPosition(position)
        if not choices:
            choices = []
        self.items[name] = {
            'name': name,
            'value': value,
            'type': 'choice',
            'choices': choices,
            'transient': transient,
            'position': position,
            'callback': callback
        }


    def addStr(self, name, value="", transient=False, position=None, callback=None):
        position = self._getPosition(position)
        self.items[name] = {'type': 'str',
                            'value': value,
                            'transient': transient,
                            'position': position,
                            'widget': "input",
                            'callback': callback}


    def addBool(self, name, value=False, transient=False, position=None, callback=None):
        position = self._getPosition(position)
        self.items[name] = {'type': 'bool',
                            'value': value,
                            'transient': transient,
                            'position': position,
                            'widget': "checkbox",
                            'callback': callback}


    def asString(self):
        items = [(name, item, item['position']) for name, item in self.items.items()]
        items.sort(key=lambda x: x[2])
        options = ""
        booleanOptions = ""
        for name, item, _ in items:
            if item['type'] in ['int', 'float', 'str', 'choice']:
                value = str(item['value'])
                if ' ' in value:
                    value = '[' + value + ']'
                options = options + " " + name.split()[0] + "=" + value
            if item['type'] == 'bool' and item['value']==True:
                booleanOptions = booleanOptions + " " + name.split()[0]
        options = options + booleanOptions
        options = options.strip()
        return options
        
        
    def _getPosition(self, position):
        if not position:
            position = len(self.items.keys())
        return position

