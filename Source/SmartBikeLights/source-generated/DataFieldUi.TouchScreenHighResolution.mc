using Toybox.Math;
using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Application.Properties as Properties;

(:touchScreen :highResolution)
module DataFieldUi {

    var _openedMenus = [];
    var _menuIndex = -1;
    var _arrowsFont;
    var _iconsFont;
    var _fontPaddings;

    public function isMenuOpen() {
        return _openedMenus.size() > 0;
    }

    public function pushMenu(menu) {
        if (_arrowsFont == null) {
            _arrowsFont = WatchUi.loadResource(Rez.Fonts[:menuArrows]);
            _iconsFont = WatchUi.loadResource(Rez.Fonts[:menuIcons]);
            _fontPaddings = WatchUi.loadResource(Rez.JsonData.FontTopPaddings)[0];
        }

        _openedMenus.add(menu);
        _menuIndex++;
    }

    public function popMenu() {
        if (_menuIndex < 0) {
            return;
        }

        _openedMenus.remove(_openedMenus[_menuIndex]);
        _menuIndex--;
    }

    public function onUpdate(dc, fgColor, bgColor) {
        if (_menuIndex < 0) {
            return false;
        }

        var menu = _openedMenus[_menuIndex];
        menu.onUpdate(dc, fgColor, bgColor);
        return true;
    }

    public function onTap(location) {
        if (_menuIndex < 0) {
            return false;
        }

        var menu = _openedMenus[_menuIndex];
        return menu.onTap(location);
    }

    class ToggleMenuItem extends MenuItem {
        public var value;

        public function initialize(label, subLabel, identifier, value, options) {
            MenuItem.initialize(label, subLabel, identifier, options);
            self.type = 1;
            self.value = value;
        }

        public function setEnabled(enabled) {
            value = enabled;
        }

        public function getId() {
            return identifier;
        }
    }

    class MenuItem {

        public var identifier;
        public var type = 0;
        public var label;
        public var subLabel;

        public function initialize(label, subLabel, identifier, options) {
            self.type = type;
            setLabel(label);
            setSubLabel(subLabel);
            self.identifier = identifier;
        }

        public function getId() {
            return identifier;
        }

        public function setLabel(value) {
            label = value instanceof String ? value : WatchUi.loadResource(value);
        }

        public function setSubLabel(value) {
            subLabel = value instanceof String ? value
                : value != null ? WatchUi.loadResource(value)
                : null;
        }
    }

    class Menu2 {

        private var _title;
        private var _controlBarHeight = 70;
        private var _items = [];
        private var _itemHeight = 120;
        private var _startItemIndex = 0;
        private var _maxStartItemIndex = 0;
        private var _width;
        private var _height;
        private var _hasBottomBar = false;
        private var _initialized = false;

        public function initialize(options) {
        }

        public function setTitle(title) {
            _title = title;
        }

        public function addItem(item) {
            _items.add(item);
        }

        public function getItem(index) {
            return _items[index];
        }

        public function deleteItem(index) {
            _items.remove(getItem(index));
        }

        public function onUpdate(dc, fgColor, bgColor) {
            if (!_initialized) {
                preCalculate(dc);
            }

            var width = _width;
            var height = _height;
            var y = 0;
            if (_title != null) {
                dc.setColor(fgColor, -1);
                dc.fillRectangle(0, 0, width, _controlBarHeight);
                dc.setColor(bgColor, -1);
                dc.drawText(width / 2, _controlBarHeight / 2, 3, _title, 1 /* TEXT_JUSTIFY_CENTER */ | 4 /* TEXT_JUSTIFY_VCENTER */);
                dc.drawText(3, 6, _arrowsFont, "B", 2 /* TEXT_JUSTIFY_LEFT */);
                y += _controlBarHeight;
            }

            var labelX = width * 0.04f;
            dc.setPenWidth(2);
            for (var i = _startItemIndex; i < _items.size(); i++) {
                if (y > height) {
                    break;
                }

                var item = _items[i];
                dc.setColor(fgColor, -1);
                if (item.subLabel != null) {
                    var labelOffsetY = (_itemHeight * 0.2f) - StringHelper.getFontTopPadding(3, _fontPaddings);
                    var subLabelOffsetY = (_itemHeight * 0.6f) - StringHelper.getFontTopPadding(2, _fontPaddings);
                    dc.drawText(labelX, y + labelOffsetY, 3, item.label, 2 /* TEXT_JUSTIFY_LEFT */);
                    dc.drawText(labelX, y + subLabelOffsetY, 2, item.subLabel, 2 /* TEXT_JUSTIFY_LEFT */);
                } else {
                    dc.drawText(labelX, y + _itemHeight / 2, 3, item.label, 2 /* TEXT_JUSTIFY_LEFT */ | 4 /* TEXT_JUSTIFY_VCENTER */);
                }

                if (item.type == 1 /* Toggle */) {
                    var iconX = width * 0.75;
                    var iconY = y + _itemHeight / 2;
                    dc.drawText(iconX, iconY, _iconsFont, "T", 2 /* TEXT_JUSTIFY_LEFT */ | 4 /* TEXT_JUSTIFY_VCENTER */);
                    var text = item.value ? "1" : "0";
                    if (item.value) {
                        dc.setColor(0x00AA00 /* COLOR_DK_GREEN */, -1);
                    }

                    dc.drawText(iconX, iconY, _iconsFont, text, 2 /* TEXT_JUSTIFY_LEFT */ | 4 /* TEXT_JUSTIFY_VCENTER */);
                }

                y += _itemHeight;
                // Draw line
                dc.setColor(fgColor, -1);
                dc.drawLine(0, y, width, y);
            }

            if (_hasBottomBar) {
                var topY = height - _controlBarHeight;
                dc.setColor(fgColor, -1);
                dc.fillRectangle(0, topY, width, _controlBarHeight);

                // Draw up arrow
                dc.setColor(_startItemIndex > 0 ? bgColor : 0xAAAAAA /* COLOR_LT_GRAY */, -1);
                dc.drawText(width * 0.25, topY + 6, _arrowsFont, "U", 1 /* TEXT_JUSTIFY_CENTER */);

                // Draw down arrow
                dc.setColor(_startItemIndex < _maxStartItemIndex ? bgColor : 0xAAAAAA /* COLOR_LT_GRAY */, -1);
                dc.drawText(width * 0.75, topY + 6, _arrowsFont, "D", 1 /* TEXT_JUSTIFY_CENTER */);
            }
        }

        public function onTap(location) {
            if (!_initialized) {
                return false;
            }

            var tapX = location[0];
            var tapY = location[1];
            // Handle top bar
            if (tapY <= _controlBarHeight) {
                if (tapX < (_width / 3)) {
                    close(); // Tap on back button
                }

                return true;
            }

            // Handle bottom bar
            if (_hasBottomBar && tapY >= (_height - _controlBarHeight)) {
                if (tapX > (_width / 2)) {
                    // Scroll down
                    if (_startItemIndex < _maxStartItemIndex) {
                        _startItemIndex++;
                    }
                } else {
                    // Scroll up
                    if (_startItemIndex > 0) {
                        _startItemIndex--;
                    }
                }

                return true;
            }

            var index = (Math.floor((tapY - _controlBarHeight) / _itemHeight.toFloat()) + _startItemIndex).toNumber();
            if (index >= _items.size()) {
                return true; // Tapped on empty space
            }

            var item = _items[index];
            onSelect(item.identifier, item);
            return true;
        }

        public function onSelect(identifier, menuItem) {
        }

        public function close() {
        }

        private function preCalculate(dc) {
            _width = dc.getWidth();
            _height = dc.getHeight();
            var totalHeight = _controlBarHeight + (_items.size() * _itemHeight);
            _hasBottomBar = totalHeight > _height;
            if (_hasBottomBar) {
                _maxStartItemIndex = Math.ceil((totalHeight + _controlBarHeight - _height) / _itemHeight.toFloat());
            }

            _initialized = true;
        }
    }
}