function varargout = maze_UI(varargin)
% MAZE_UI MATLAB code for maze_UI.fig
%      MAZE_UI, by itself, creates a new MAZE_UI or raises the existing
%      singleton*.
%
%      H = MAZE_UI returns the handle to a new MAZE_UI or the handle to
%      the existing singleton*.
%
%      MAZE_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAZE_UI.M with the given input arguments.
%
%      MAZE_UI('Property','Value',...) creates a new MAZE_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before maze_UI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to maze_UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help maze_UI

% Last Modified by GUIDE v2.5 06-Apr-2017 14:11:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @maze_UI_OpeningFcn, ...
                   'gui_OutputFcn',  @maze_UI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before maze_UI is made visible.
function maze_UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to maze_UI (see VARARGIN)

handles.Maze = maze;


% Choose default command line output for maze_UI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maze_UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = maze_UI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


g= imread('maze.png');
imshow(g);



% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
holder = handles.Maze;

disp(eventdata.Key);
xPos = 0;
yPos = 0;

if strcmp(eventdata.Key , 'leftarrow')
    if maze.checkWallLeft(holder)
        xPos = xPos -.1425;
        holder.IndexJ = holder.IndexJ -1;
    end
end
if strcmp(eventdata.Key , 'rightarrow')
    if maze.checkWallRight(holder)
        xPos = xPos +.1425;
        holder.IndexJ = holder.IndexJ +1;
    end
end
if strcmp(eventdata.Key , 'uparrow')
    if maze.checkWallTop(holder)
    yPos = yPos +.155;
     holder.IndexI = holder.IndexI -1;
    end
end
if strcmp(eventdata.Key , 'downarrow')
    if maze.checkWallBottom(holder)
    yPos = yPos -.155;
    holder.IndexI = holder.IndexI +1;
    end
end

MatrixPos = get(handles.Person, 'Position');

x = MatrixPos(1) +xPos;
y = MatrixPos(2) +yPos;

MatrixPos(1) = x;
MatrixPos(2) = y;
set(handles.Person,'Position',MatrixPos);
Walls = maze.showPos(holder);
playmusic(Walls);
handles.Maze = holder; 
guidata(hObject,handles);


function [] = playmusic(Walls);
    f=130.81;
    fs=44100;
    t=0:1/fs:1;
    s=sin(2*pi*f*t);
    soundsc(s,fs);
 
    
