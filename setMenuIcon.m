function setMenuIcon(menuObject,iconFile)
% SETMENUICON  Add icons to UIMENU items.
%   SETMENUICON(MENUOBJECT,ICONFILE) sets the icon of MENUOBJECT to
%   ICONFILE. MENUOBJECT is a menu item created with MATLAB's own UIMENU.
%   ICONFILE denotes the path to an image file containing the desired icon.
%   This should work with GIF, JPEG and PNG images.

%   Copyright (C) 2020 Florian Rau
%
%   setMenuIcon is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version.
%
%   setMenuIcon is distributed in the hope that it will be useful, but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
%
%   You should have received a copy of the GNU General Public License along
%   with setMenuIcon.  If not, see <https://www.gnu.org/licenses/>.


% validate inputs
validateattributes(menuObject,{'matlab.ui.container.Menu'},{'scalar'})
validateattributes(iconFile,{'char'},{'row'})
if ~exist(iconFile,'file')
    error('File not found: %s',iconFile)
end

% build stack of Menu objects
menuStack = menuObject;
while isa(menuStack(1).Parent,'matlab.ui.container.Menu')
    menuStack = [menuStack(1).Parent menuStack]; %#ok<AGROW>
end

% obtain the position of UIStack elements within their parent container
positions = [menuStack.Position];

% obtain jFrame (temporarily disabling the respective warning)
warnID  = 'MATLAB:ui:javaframe:PropertyToBeRemoved';
tmp     = warning('query',warnID);
warning('off',warnID)
jFrame  = get(menuStack(1).Parent,'JavaFrame'); %#ok<JAVFM>
warning(tmp.state,warnID)

% get jMenuBar
tmp      = fieldnames(jFrame);
tmp      = tmp(~cellfun(@isempty,regexp(tmp,'fHG\dClient|fFigureClient')));
jMenuBar = jFrame.(tmp{1}).getMenuBar;

% obtain jMenuItem
while jMenuBar.getMenuCount < positions(1)
    pause(0.05)
end
jMenuItem = jMenuBar.getMenu(positions(1)-1);
for ii = 2:numel(menuStack)
    if jMenuItem.getMenuComponentCount < positions(ii)
        jMenuItem.doClick;
        pause(0.05)
        jMenuItem.doClick;
    end
    tmp       = jMenuItem.getMenuComponents;
    tmp       = tmp(arrayfun(@(x) contains(class(x),'JMenu'),tmp));
    jMenuItem = tmp(positions(ii));
end

% set icon
jMenuItem.setIcon(javax.swing.ImageIcon(iconFile));