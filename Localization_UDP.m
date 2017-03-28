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
mobileBeaconId = 26;

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

conn = py.udpclient.udp_factory(ip,uint16(port),uint16(mobileBeaconId));

duration = 0;

%----------------------------------------Matlab Start
hrtf = uigetfile(pwd, 'Please select the hrtf you would like to use');
load(deblank(sprintf('%s', hrtf)));

soundSource = [3.5; 1.2];
forward = [0; 1];

%25 locations
azimuths = [-80 -65 -55 -45:5:45 55 65 80];

%50 locations
elevations = -45 + 5.625 * (0:49);

FileReader = dsp.AudioFileReader('Violin.mp3', 'SamplesPerFrame', 11050, 'PlayCount', 500);

FilePlayer = dsp.AudioPlayer('QueueDuration', 1, 'BufferSizeSource', 'Property', 'BufferSize', 11050, 'SampleRate', FileReader.SampleRate);

aIndex = 1;
eIndex = 49;
%--------------------------------------------MATLAB end

while (count > 0)
    tic;
	
	count = count - 1;
    coords = conn.request_position();
    duration = duration + toc;
	disp(coords);
    pause(interval);
	
	%-------------------------------------Matlab start
	%Gets the mouse position and stores it as a vector2
	

	
	
	
    playerPosFor = [double(coords{1}); double(coords{2})];
	playerPosFor = playerPosFor/100;
	%Get the vector from the middle of the screen to the mouse pos and
	%normalizes it
    directionVec = soundSource - playerPosFor;
	directionVec = normc(directionVec);
	
	%forward = playerPosFor - playerPosBack;
	
	%Calculates the degree angle between the forward vector and the source
	%of the sound
	angle = acosd(dot(directionVec, forward));
	
	%Make the angle negative if it needs to be
	if (directionVec(1) < 0)
		angle = -angle;
	end
	
	%disp(angle);
	aIndex = 9;
	
	%In the positive section make the sound come from the front
	if (angle > -90 && angle < 90)
		eIndex = 9;
		
		%Round the angles to the nearest possible angle
		if (angle < -72.5)
			angle = -80;
		elseif (angle < -60)
			angle = -65;
		elseif (angle < -50)
			angle = -55;
		elseif (angle < -42.5)
			angle = -45;
		elseif (angle < -37.5)
			angle = -40;
		elseif (angle < -32.5)
			angle = -35;
		elseif (angle < -27.5)
			angle = -30;
		elseif (angle < -22.5)
			angle = -25;
		elseif (angle < -17.5)
			angle = -20;
		elseif (angle < -12.5)
			angle = -15;
		elseif (angle < -7.5)
			angle = -10;
		elseif (angle < -2.5)
			angle = -5;
		elseif (angle < 2.5)
			angle = 0;
		elseif (angle < 7.5)
			angle = 5;
		elseif (angle < 12.5)
			angle = 10;
		elseif (angle < 17.5)
			angle = 15;
		elseif (angle < 22.5)
			angle = 20;
		elseif (angle < 27.5)
			angle = 25;
		elseif (angle < 32.5)
			angle = 30;
		elseif (angle < 37.5)
			angle = 35;
		elseif (angle < 42.5)
			angle = 40;
		elseif (angle < 50)
			angle = 45;
		elseif (angle < 60)
			angle = 55;
		elseif (angle < 72.5)
			angle = 65;
		elseif (angle < 90)
			angle = 80;
		end
	else 
		
		%If the angle is behind, have the elevation make it so the sound
		%goes all the way around
		eIndex = 49;
		
		%Round the angle to the nearest possible one
		if (angle < -177.5)
			angle = 0;
		elseif (angle < -172.5)
			angle = -5;
		elseif (angle < -167.5)
			angle = -10;
		elseif (angle < -162.5)
			angle = -15;
		elseif (angle < -157.5)
			angle = -20;
		elseif (angle < -152.5)
			angle = -25;
		elseif (angle < -147.5)
			angle = -30;
		elseif (angle < -142.5)
			angle = -35;
		elseif (angle < -137.5)
			angle = -40;
		elseif (angle < -132.5)
			angle = -45;
		elseif (angle < -120)
			angle = -55;
		elseif (angle < -110)
			angle = -65;
		elseif (angle < -90)
			angle = -80;
		end
		
		if (angle > 177.5)
			angle = 0;
		elseif (angle > 172.5)
			angle = 5;
		elseif (angle > 167.5)
			angle = 10;
		elseif (angle > 162.5)
			angle = 15;
		elseif (angle > 157.5)
			angle = 20;
		elseif (angle > 152.5)
			angle = 25;
		elseif (angle > 147.5)
			angle = 30;
		elseif (angle > 142.5)
			angle = 35;
		elseif (angle > 137.5)
			angle = 40;
		elseif (angle > 132.5)
			angle = 45;
		elseif (angle > 120)
			angle = 55;
		elseif (angle > 110)
			angle = 65;
		elseif (angle >= 90)
			angle = 80;
		end
	end
	
	%Get the correct index for a
	aIndex = find(azimuths == angle,1);
	
	%disp(angle);
    %disp(aIndex);
    
	%The rest you know
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
	
	wav_left = [conv(left', sig')];
	wav_right = [conv(right', sig')];
	
	soundToPlay(:,1) = wav_left;
	soundToPlay(:,2) = wav_right;

	step(FilePlayer, soundToPlay);
end
    
fprintf('Average delay is:%f',duration/rounds);

conn.close();