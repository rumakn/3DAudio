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
handles.Maze = maze.setSize(handles.Maze, .871,.802);
handles.counter = 0;
guidata(hObject, handles);
handles.t = timer('TimerFcn',{@TmrFcn,handles.guifig},'BusyMode','Queue','ExecutionMode','FixedRate','Period', .50);
start(handles.t);

g= imread('maze.png');
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
    playerPos = [0;0];
    
    xPos = playerPos(1);
    yPos = playerPos(2);
    
    disp(xPos);
    disp(yPos);
    xPos = maze.convertX(hold,xPos);
    yPos = maze.convertY(hold,yPos);
  MatrixPos = get(handles.Person, 'Position');
    MatrixPos(1) = xPos;
    MatrixPos(2) = yPos;
    
    set(handles.Person,'Position',MatrixPos);
    
    handles.counter = handles.counter+1;
    disp(handles.counter);
    guidata(handles.guifig,handles);
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
holder = handles.Maze;

disp(eventdata.Key);

MatrixPos = get(handles.Person, 'Position');

xPos = MatrixPos(1);
yPos = MatrixPos(2);

if strcmp(eventdata.Key , 'leftarrow')
     
       xPos = xPos -(.1425/10);
        %xPos = xPos +.1425;
        if( abs((xPos - ((.1425)* (holder.SoundIndexJ-1) + .18))) >= (1/6 * .1425))
         if( abs((xPos - ((.1425)* (holder.SoundIndexJ-1) + .18))) > (3/4 * .1425))
                  
                    holder.SoundIndexJ = holder.SoundIndexJ -1;
                      disp('sound') ; disp(holder.SoundIndexJ);
         end
        end
        disp(xPos);
        disp(((.1425)* (holder.IndexJ-1) + .18));
        if( abs((xPos - ((.1425)* (holder.IndexJ) + .18))) >= (7/6 * .1425))
            if maze.checkWallLeft(holder)
                      
                  
                    if( abs((xPos - ((.1425)* (holder.IndexJ-1) + .18))) > (1/3 * .1425))
                  
                    holder.IndexJ = holder.IndexJ -1;
                      disp('pos'); disp( holder.IndexJ);
                    end
            
            else
                disp('hit wall'); disp(holder.IndexJ);
                xPos = xPos + (.1425/10);
            end
        end
end
if strcmp(eventdata.Key , 'rightarrow')
      
        xPos = xPos +(.1425/10);
        %xPos = xPos +.1425;
        if( (xPos - ((.1425)* (holder.SoundIndexJ-1) + .18)) >= (1/6 * .1425))
         if( (xPos - ((.1425)* (holder.SoundIndexJ-1) + .18)) > (3/4 * .1425))
                  
                    holder.SoundIndexJ = holder.SoundIndexJ +1;
                      disp('sound') ; disp(holder.SoundIndexJ);
         end
        end
        if( (xPos - ((.1425)* (holder.IndexJ-1) + .18)) >= (1/6 * .1425))
            if maze.checkWallRight(holder)
                      
                  
                    if( (xPos - ((.1425)* (holder.IndexJ-1) + .18)) > (1/3 * .1425))
                  
                    holder.IndexJ = holder.IndexJ +1;
                      disp('pos'); disp( holder.IndexJ);
                    end
            
            else
                disp('hit wall');
                disp(holder.IndexJ);
                xPos = xPos - (.1425/10);
            end
        end
    
end
if strcmp(eventdata.Key , 'uparrow')
    
        yPos = yPos +(.155/10);
         if( abs((yPos - ((.155)* (5-holder.SoundIndexI) + .18))) >= (1/6 * .155))
              if( abs((yPos - ((.155)* (5-holder.SoundIndexI) + .18))) > (3/4 * .155))

                            holder.SoundIndexI = holder.SoundIndexI -1;
                              disp(holder.SoundIndexI);
              end
         end
        
        
        if( abs((yPos - ((.155)* (4-holder.IndexI) + .18))) >= (7/6 * .155))
            if maze.checkWallTop(holder)
                         
                 if( abs((yPos - ((.155)* (5-holder.IndexI) + .18))) > (1/3 * .155))
                  
                    holder.IndexI = holder.IndexI -1;
                      disp(holder.IndexI);
                 end
        
        else
                disp('hit wall');
                yPos = yPos - (.155/10);
            end
        end
end
if strcmp(eventdata.Key , 'downarrow')
        
        yPos = yPos -(.155/10);
        if( abs((yPos - ((.155)* (5-holder.SoundIndexI) + .18))) >= (1/6 * .155))
            if( abs((yPos - ((.155)* (5-holder.SoundIndexI) + .18))) > (3/4 * .155))

                                holder.SoundIndexI = holder.SoundIndexI +1;
                                disp(holder.SoundIndexI);
            end
        end
        
        if( abs((yPos - ((.155)* (6-holder.IndexI) + .18))) >= (7/6 * .155))
            if maze.checkWallBottom(holder)
                       
                        if( abs((yPos - ((.155)* (5-holder.IndexI) + .18))) > (1/3 * .155))
                  
                            holder.IndexI = holder.IndexI +1;
                            disp(holder.IndexI);
                         end
        else
                disp('hit wall');
                yPos = yPos + (.155/10);
            end
        end
end



MatrixPos(1) = xPos;
MatrixPos(2) = yPos;
set(handles.Person,'Position',MatrixPos);
%Walls = maze.showPos(holder);
%playmusic(Walls);
handles.Maze = holder; 
guidata(hObject,handles);
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
