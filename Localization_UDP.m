% three arguments for localization udp connection:
% 1. serever ip(the terminal which running the dashboard
% 2. udp listening port, this can be manualy configured in Dashboard Menu:
%       File -> Parameters. After setting the listening port, restart the
%       dashboard.
% 3. The address/ID of the mobile beacon, currently in our LAB the mobile
% beacon ID is 26. This can be configured in dashboard
clear;
maze_UI();
% connection parameters
ip = '127.0.0.1';
% ip = '192.168.86.122';
port = 18888;

% profiling parameters
rounds = 500;
count = rounds;
interval = 0.5;
rate = 44100;

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
connBack = py.udpclient.udp_factory(ip,uint16(port),uint16(mBIdBack));

duration = 0;

%Get HRTF from files
hrtf = uigetfile(pwd, 'Please select the hrtf you would like to use');
load(deblank(sprintf('%s', hrtf)));

%25 locations
azimuths = [-80 -65 -55 -45:5:45 55 65 80];

%50 locations
elevations = -45 + 5.625 * (0:49);

%Sound locations
soundSource1 = [0.0; 0.0];
soundSource2 = [10.0; 10.0];

%Storing sound locations
soundSources = {soundSource1, soundSource2};

%Default player direction is forward
forward = [0; 1];

%To read the music files



%Make them match
%Try timer
%Test 1 sound



FileReaderViolin = dsp.AudioFileReader('Violin.mp3', 'SamplesPerFrame', rate, 'PlayCount', 500);
FileReaderDiner = dsp.AudioFileReader('x1.wav', 'SamplesPerFrame', rate, 'PlayCount', 500);

%x1.wav

FileReaders = {FileReaderViolin, FileReaderDiner};

%Audio player
FilePlayer = dsp.AudioPlayer('QueueDuration', 0, 'BufferSizeSource', 'Property', 'BufferSize', rate, 'SampleRate', FileReaderViolin.SampleRate);

%Default indices
aIndex = 1;
eIndex = 49;

%overlap sounds
leftOverlap = [];
rightOverlap = [];

%Set up Timer
global coordsFront;
global coordsBack;

global playerPos;

t = timer('TimerFcn', 'coordsFront = connFront.request_position(); coordsBack = connBack.request_position();','ExecutionMode','FixedRate','Period', interval);

start(t);


while (count > 0)
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
	playerPosBac = [double(coordsBack{1}); double(coordsBack{2})];
	playerPosBac = playerPosBac/100;
	
	%Calculate player actualy coordinate from the midpoint of the front
	%and back
	playerPos = (playerPosFro + playerPosBac) / 2;
	%playerPos = playerPosFro;
	
	%Calculates the forward vector
	forward = playerPosFro - playerPosBac;
	forward = normc(forward);
	
	wav_left = [];
	wav_right = [];
	soundToPlay = [];

	numSounds = [1,2];
	for i = numSounds
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

		sig = step(FileReaders{i});
		sig = sig(:,1);

		wav_left = conv(left', sig');
		wav_right = conv(right', sig');
		
		%disp(size(wav_left));
		%wav_left = horzcat(leftOverlap, wav_left);
		%wav_right = horzcat(rightOverlap, wav_right);
		%disp(size(wav_left));
		
		leftOverlap = wav_left(rate + 1:end);
		rightOverlap = wav_right(rate + 1:end);
		
		wav_left = wav_left(1:rate);
		wav_right = wav_right(1:rate);
		
		if (i > 1)
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
connBack.close();

stop(t);
delete(t);