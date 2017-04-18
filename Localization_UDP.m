% three arguments for localization udp connection:
% 1. serever ip(the terminal which running the dashboard
% 2. udp listening port, this can be manualy configured in Dashboard Menu:
%       File -> Parameters. After setting the listening port, restart the
%       dashboard.
% 3. The address/ID of the mobile beacon, currently in our LAB the mobile
% beacon ID is 26. This can be configured in dashboard
clear;
% connection parameters
ip = '127.0.0.1';
% ip = '192.168.86.122';
port = 18888;

% profiling parameters
rounds = 500;
count = rounds;
interval = 0.1;
rate = 11050;
%44100;

beeps = false;

% add python scripts folder to path, in the repository, the default
% location of the python scripts locates at '[project_root]/py_scripts'
PyPath = py.sys.path;
if PyPath.count('.') == 0
   insert(PyPath,int32(0),'.');
end
PyModule = py.sys.modules;
if isa(PyModule.get('udpclient'),'py.NoneType')
    py.importlib.import_module('udpclient');
end

mBIdFront = 26;
mBIdBack = 27;

connFront = py.udpclient.udp_factory(ip,uint16(port),uint16(mBIdFront));
%connBack = py.udpclient.udp_factory(ip,uint16(port),uint16(mBIdBack));

duration = 0;

%Get HRTF from files
hrtf = uigetfile(pwd, 'Please select the hrtf you would like to use');
load(deblank(sprintf('%s', hrtf)));

%25 locations
azimuths = [-80 -65 -55 -45:5:45 55 65 80];

%50 locations
elevations = -45 + 5.625 * (0:49);

%Sound locations
soundSourceLeft = [0; 0];
soundSourceRight = [0; 0];
soundSourceUp = [0; 0];
soundSourceDown = [0; 0];

soundSourceExit = [10; 10];

soundSourceRumble = [0; 0];

%Storing sound locations
soundSources = {0.0, 0.0, 0.0, 0.0, 0.0};

%Default player direction is forward
forward = [0; 1];

%Winner vairable
global win;
win = false;

%To read the music files
FileReaderUp = 0;
FileReaderDown = 0;
FileReaderLeft = 0;
FileReaderRight = 0;

if (beeps)
	FileReaderUp = dsp.AudioFileReader('gToneFinal.wav', 'SamplesPerFrame', rate, 'PlayCount', 1000);
	FileReaderDown = dsp.AudioFileReader('bToneFinal.wav', 'SamplesPerFrame', rate, 'PlayCount', 1000);
	FileReaderLeft = dsp.AudioFileReader('dToneFinal.wav', 'SamplesPerFrame', rate, 'PlayCount', 1000);
	FileReaderRight = dsp.AudioFileReader('fToneFinal.wav', 'SamplesPerFrame', rate, 'PlayCount', 1000);
else
	FileReaderUp = dsp.AudioFileReader('3D_Oboe.wav', 'SamplesPerFrame', rate, 'PlayCount', 500);
	FileReaderDown = dsp.AudioFileReader('3D_Bassoon.wav', 'SamplesPerFrame', rate, 'PlayCount', 500);
	FileReaderLeft = dsp.AudioFileReader('3D_Flute.wav', 'SamplesPerFrame', rate, 'PlayCount', 500);
	FileReaderRight = dsp.AudioFileReader('3D_Clarinet.wav', 'SamplesPerFrame', rate, 'PlayCount', 500);
end

FileReaderExit = dsp.AudioFileReader('MiddleC.wav', 'SamplesPerFrame', rate, 'PlayCount', 500);
FileReaderRumble = dsp.AudioFileReader('RumbleStrip.wav', 'SamplesPerFrame', rate, 'PlayCount', 500);

FileReaders = {FileReaderLeft, FileReaderRight, FileReaderUp, FileReaderDown, FileReaderExit, FileReaderRumble};

%Audio player
FilePlayer = dsp.AudioPlayer('QueueDuration', 0, 'BufferSizeSource', 'Property', 'BufferSize', rate, 'SampleRate', FileReaderUp.SampleRate);

%Default indices
aIndex = 1;
eIndex = 49;

%overlap sounds
leftOverlap = [];
rightOverlap = [];

%Set up Globals
global coordsFront;
global coordsBack;
global playerPos;

global fracLeft;
global fracBott;
global CellWalls;

%Dummy values
CellWalls = [false, true, true, true];
playerPos = [0;0];

maze_UI();

%Set up timer
t = timer('TimerFcn', 'global coordsFront; coordsFront = connFront.request_position();','ExecutionMode','FixedRate','Period', interval);
start(t);

%t = timer('TimerFcn', 'global coordsFront; global coordsBack; coordsFront = connFront.request_position();coordsBack = connBack.request_position();','ExecutionMode','FixedRate','Period', interval);
%start(t);

while (~win)
    tic;
	
	count = count - 1;
    %coordsFront = connFront.request_position();
	%coordsBack = connBack.request_position();
	
    duration = duration + toc;
	
	%-------------------------------------Matlab start
	%Gets players front coordinate
    playerPosFro = [double(coordsFront{1}); double(coordsFront{2})];
	playerPosFro = playerPosFro/100;
	
	%Gets players back coordinate
	%playerPosBac = [double(coordsBack{1}); double(coordsBack{2})];
	%playerPosBac = playerPosBac/100;
	
	%Calculate player actualy coordinate from the midpoint of the front
	%and back
	%playerPos = (playerPosFro + playerPosBac) / 2;
	playerPos = playerPosFro;
	
	%Calculates the forward vector
	%forward = playerPosFro - playerPosBac;
	%forward = normc(forward);
	
	%Variable setUp;
	wav_left = [];
	wav_right = [];
	soundToPlay = [];
	
	%Set up sound locations
	soundSourceLeft = playerPos + [-1; 0];
	soundSourceRight = playerPos + [1; 0];
	soundSourceUp = playerPos + [0; 1];
	soundSourceDown = playerPos + [0; -1];
	
	soundSourceRumble = playerPos;
	
	%Set up to know how loud the rumble should be as player's approach it
	%and where it's coming from
	nearEdge = true;
	distEdgeX = 1;
	distEdgeY = 1;
	
	%Check left and right edges and move the sound to that location
	%Also checks distance to make sound more intense
	if (fracLeft < 1/6)
		if (CellWalls(1))
			soundSourceRumble = playerPos + [-1; 0];
		end
		
		distEdgeX = fracLeft/(1/6);
		
	elseif (fracLeft > 5/6)
		if (CellWalls(2))
			soundSourceRumble = playerPos + [1; 0];
		end
		
		distEdgeX = (1-fracLeft)/(1/6);
		
	else
		nearEdge = false;
	end
	
	%Check the bottom and top edges and move the sound towards there
	%Also checks distance to make sound more intense
	if (fracBott < 1/6)
		if(CellWalls(4))
			soundSourceRumble = playerPos + [0; -1];
		end
		
		distEdgeY = fracBott/(1/6);
		
	elseif (fracBott > 5/6)
		if (CellWalls(3))
			soundSourceRumble = playerPos + [0; 1];
		end
		
		distEdgeY = (1-fracBott)/(1/6);
		
	else
		nearEdge = false;
	end
	
	%Make the intensity match the one for the closest wall
	distEdge = max(1-distEdgeX, 1-distEdgeY);
	
	%Save them
	soundSources = {soundSourceLeft, soundSourceRight, soundSourceUp, soundSourceDown, soundSourceExit, soundSourceRumble};
	
	for i = 1:6
		
		sig = step(FileReaders{i});
		sig = sig(:,1);
		
		if (i < 5)
			if (CellWalls(i) == true)
				continue;
			end
		elseif (i == 6)
			if (~nearEdge)
				FileReaderRumble = dsp.AudioFileReader('RumbleStrip.wav', 'SamplesPerFrame', rate, 'PlayCount', 500);
				continue;
			end
		end
		
		%Get the azimuth angle and elevation index
		[azAngle, eIndex] = FindAngle(playerPos, forward, soundSources{i});
		%Get the correct index for a
		aIndex = find(azimuths == azAngle,1);
		
		%Convolve the sound for that source
		left = squeeze(hrir_l(aIndex, eIndex, :));
		right = squeeze(hrir_r(aIndex, eIndex, :));

		delay = ITD(aIndex, eIndex);

		if (aIndex < 13)
			left = [left' zeros(size(1:abs(delay)))];
			right = [zeros(size(1:abs(delay))) right'];
		else
			left = [zeros(size(1:abs(delay))) left'];
			right = [right' zeros(size(1:abs(delay)))];
		end
		
		wav_left = conv(left', sig');
		wav_right = conv(right', sig');
		
		%disp(size(wav_left));
		%wav_left = horzcat(leftOverlap, wav_left);
		%wav_right = horzcat(rightOverlap, wav_right);
		%disp(size(wav_left));
		
		%leftOverlap = wav_left(rate + 1:end);
		%rightOverlap = wav_right(rate + 1:end);
		
		wav_left = wav_left(1:rate);
		wav_right = wav_right(1:rate);
		
		%For West/East sounds
		if (i == 1 || i == 2)
			wav_left = wav_left * distEdgeY;
			wav_right = wav_right * distEdgeY;
			
			if (fracLeft > 5/6 || fracLeft < 1/6)
				wav_left = wav_left * (1-distEdgeX);
				wav_right = wav_right * (1-distEdgeX);
			end
		
		%For North/South sounds
		elseif (i == 3 || i == 4)
			wav_left = wav_left * distEdgeX;
			wav_right = wav_right * distEdgeX;
			
			if (fracBott > 5/6 || fracBott < 1/6)
				wav_left = wav_left * (1-distEdgeY);
				wav_right = wav_right * (1-distEdgeY);
			end
			
		%For rumble strip sounds
		elseif (i == 6)
			wav_left = wav_left * distEdge;
			wav_right = wav_right * distEdge;
		end
		
		if (size(soundToPlay) ~= [0,0])
			soundToPlay(:,1) =  soundToPlay(:,1) + wav_left';
			soundToPlay(:,2) =  soundToPlay(:,2) + wav_right';
		else
			soundToPlay(:,1) =  wav_left';
			soundToPlay(:,2) =  wav_right';
		end
	end
	
	step(FilePlayer, soundToPlay);
	
	%pause(interval);
end
    
fprintf('Average delay is:%f',duration/rounds);

connFront.close();
%connBack.close();

stop(t);
delete(t);