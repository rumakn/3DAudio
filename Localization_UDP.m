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

mBIdFront = 26;
mBIdBack = 27;

% profiling parameters
rounds = 500;
count = rounds;
interval = 0.1;

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

connFront = py.udpclient.udp_factory(ip,uint16(port),uint16(mBIdFront));
%connBack = py.udpclient.udp_factory(ip,uint16(port),uint16(mBIdBack));

duration = 0;

%----------------------------------------Matlab Start
hrtf = uigetfile(pwd, 'Please select the hrtf you would like to use');
load(deblank(sprintf('%s', hrtf)));

%25 locations
azimuths = [-80 -65 -55 -45:5:45 55 65 80];

%50 locations
elevations = -45 + 5.625 * (0:49);

soundSource = [0.3; 0.25];
soundSource2 = [0; 0];

sounds = [soundSource soundSource2];

forward = [0; 1];

FileReader = dsp.AudioFileReader('Violin.mp3', 'SamplesPerFrame', 11050, 'PlayCount', 500);

FilePlayer = dsp.AudioPlayer('QueueDuration', 1, 'BufferSizeSource', 'Property', 'BufferSize', 11050, 'SampleRate', FileReader.SampleRate);

aIndex = 1;
eIndex = 49;
%--------------------------------------------MATLAB end

while (count > 0)
    tic;
	
	count = count - 1;
    coordsFront = connFront.request_position();
	%coordsBack = connBack.request_position();
	
	%coords = fix(coords);
	
    duration = duration + toc;
	disp(coordsFront);
	
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
	
	%Get the azimuth angle and elevation index
	[azAngle, eIndex] = FindAngle(playerPos, forward, soundSource);
	%Get the correct index for a
	aIndex = find(azimuths == azAngle,1);
	
	%disp(angle);
    %disp(aIndex);
    
	%Play the sound
	wav_left = [];
	wav_right = [];
	soundToPlay = [];
	
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
	
	sig = step(FileReader);
	sig = sig(:,1);
	
	wav_left = conv(left', sig');
	wav_right = conv(right', sig');
	
	soundToPlay(:,1) = wav_left;
	soundToPlay(:,2) = wav_right;

	step(FilePlayer, soundToPlay);
	
	pause(interval);
end
    
fprintf('Average delay is:%f',duration/rounds);

connFront.close();
%connBack.close();