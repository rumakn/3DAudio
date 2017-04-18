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

% Last Modified by GUIDE v2.5 13-Apr-2017 20:15:30

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
handles.guifig = gcf;
handles.Maze = maze;
handles.Maze = maze.setSize(handles.Maze, 1.752,2.693);
handles.counter = 0;
guidata(hObject, handles);
handles.t = timer('TimerFcn',{@TmrFcn,handles.guifig},'ExecutionMode','FixedRate','Period', .01);
start(handles.t);

g= imread('newmaze.png');
imshow(g);
% Choose default command line output for maze_UI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maze_UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
    
end
end


%%% Timer Function
function TmrFcn(src, event, handles)
    handles = guidata(handles);
    hold = handles.Maze;
    global playerPos;
    global fracLeft; 
    global fracBott; 
    global CellWalls;
    
    xPos = playerPos(1);
    yPos = playerPos(2);
    
    xPos = maze.convertX(hold,xPos);
    yPos = maze.convertY(hold,yPos);
    
   
    MatrixPos = get(handles.Person, 'Position');
    MatrixPos(1) = xPos - (.07/2);
    MatrixPos(2) = yPos - (.07/2);
    
    hold.IndexJ = floor((xPos -.155)/.138) + 1;
    hold.IndexI = 5 - floor((yPos -.144)/.149);
    
    
    % GET DIFFERENCES FROM WALLS
    WallLeftPos = ((hold.IndexJ - 1) * .138) + .155;
    WallBottomPos = ((5 - hold.IndexI) * .149) + .144;
    
    fracLeft = ((xPos - WallLeftPos)/.138);
    fracBott = ((yPos - WallBottomPos)/.149);
    
    
    
    
    % gives cell walls
    CellWalls = [false;false;false;false];
    CellWalls(1) = maze.checkWallLeft(hold);
    CellWalls(2) = maze.checkWallRight(hold);
    CellWalls(3) = maze.checkWallTop(hold);
    CellWalls(4) = maze.checkWallBottom(hold);
    
    
    handles.Maze = hold;
    %updates handles
    set(handles.Person,'Position',MatrixPos);
    
    handles.counter = handles.counter+1;
    %disp(handles.counter);
    guidata(handles.guifig,handles);
	
	drawnow;
    
end


% --- Outputs from this function are returned to the command line.
function varargout = maze_UI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end




% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

hold = handles.Maze;

if strcmp(eventdata.Key , 'leftarrow')
    disp(hold.IndexI);
    disp(hold.IndexJ);
   disp( maze.checkWallLeft(hold));
end
if strcmp(eventdata.Key , 'rightarrow')
    disp(hold.IndexI);
    disp(hold.IndexJ);
      disp( maze.checkWallRight(hold));
end
if strcmp(eventdata.Key , 'uparrow')
    disp(hold.IndexI);
    disp(hold.IndexJ);
      disp(maze.checkWallTop(hold));
end
if strcmp(eventdata.Key , 'downarrow')
    disp(hold.IndexI);
    disp(hold.IndexJ);
      disp( maze.checkWallBottom(hold));
end
end


function [] = playmusic(Walls);
    f=130.81;
    fs=44100;
    t=0:1/fs:1;
    s=sin(2*pi*f*t);
    soundsc(s,fs);
 
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


stop(handles.t);
delete(handles.t);
end
