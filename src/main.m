% Clear command window, variables, and close all
clc, clearvars, close all;

% Create my arduino object
a = arduino("COM3","Nano3","Libraries",{"I2C"});

% Setup my Oled
[oled, a] = Initialize_Oled(a,0);
clearDisplay(oled); %clear oled screen
display_write(oled,1,1,1,128,1,8,1,'Quality Learning Monitor'); % display
% Quality learning monitor on the oled
pause(2);
clearDisplay(oled);

% Definition of the pins involved 
%Sensor pins
soundSensor = "A2";
lightSensor = "A6";
% Acuator pins
ledPin = "D4";
buzzerPin = "D5";

% Defining my thresholds in volts
soundThreshold = 1.5;
lightThreshold = 2.5;

% Setup Live plot
figure;
title("Live Quality Learning Monitor");
xlabel("Time (seconds"); 
ylabel("Voltage(volts)");
grid on;
hold on;
soundPlot = animatedline('Color','m','DisplayName','Sound');
lightPlot = animatedline('Color','c','DisplayName','Light');
legend;

startTime = tic; %Initialize tic

while true
    % Read sensor values
    soundValue = readVoltage(a, soundSensor);
    lightValue = readVoltage(a, lightSensor);

    % Round Sensor Values
    soundValueRound = round(readVoltage(a, soundSensor));
    lightValueRound = round(readVoltage(a, lightSensor));

    % Addon new points to the live plot
    endTime = toc(startTime);
    addpoints(soundPlot,endTime,soundValue);
    addpoints(lightPlot, endTime,lightValue);
    drawnow;

    % Check learning conditions with my user defined functions
    soundLevel = isItNoisy(soundValue, soundThreshold);
    lightLevel = isItBright(lightValue, lightThreshold);

    % Determine the feedback to display
    feedback = isItQuality(soundLevel, lightLevel);

    % Display the reaults on the command Window
    fprintf('Sound: %.2f V|| Light: %.2f V || Feedback: %s\n', soundValue, lightValue, feedback);

    % Alert Actions with the LED and buzzer
    if soundLevel || ~lightLevel
        writeDigitalPin(a, ledPin, 1);
        playTone(a, buzzerPin);
    else
        writeDigitalPin(a, ledPin, 0);
    end


    % Update Oled
    clearDisplay(oled);
    fontScale = 1;
    soundText = sprintf('Sound: %dv', soundValueRound);
    soundTextLendth = length(soundText)*8;
    soundColumnStart = (128 - soundTextLendth)/2;
    lightText = sprintf('Light: %dv', lightValueRound);
    lightTextLendth = length(lightText)*8;
    lightColumnStart = (128 - lightTextLendth)/2;
    feedbackText = sprintf('%s', feedback);
    display_write(oled,1,0,1,128,1,2,2,feedbackText);
    display_write(oled,1,1,soundColumnStart,128,3,4,fontScale,soundText);
    display_write(oled,1,0,lightColumnStart,128,5,6,fontScale,lightText);
end

% My user defined functions

function isNoisy = isItNoisy(soundValue, soundThreshold)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% --- help for isItNoisy ---
% isItNoisy
%    This is a user-defined function that accepts a voltage reading from
%    the sound sensor and a pre-defined threshold value as inputs. This 
%    function compares the sensor reading with the threshold;to check if
%    the sensor reading is below the threshold; and returns a
%    logical output.
% ------------------------------------------------------
% Syntax
%   isNoisy = isItNoisy(soundValue, soundThreshold)
%  --------------------------------------------------------
% Input Arguments
%   soundValue - The voltage reading of the sound sensor
%                    from 0 to 5 volts.
%   soundThreshold - The predefined voltage threshold for sound.
%  ---------------------------------------------------------
% Output Arguments
%   isNoisy - The logical output of the comparison between the inputs to 
%              if the sound sensor reading is below the threshold.
% ----------------------------------------------------------------
         isNoisy = soundValue > soundThreshold;
end

function isBright = isItBright(lightValue, lightThreshold)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% --- help for isItBright ---
% isItBright
%    This is a user-defined function that accepts a voltage reading from
%    the light sensor and a pre-defined threshold value as inputs. This 
%    function compares the sensor reading with the threshold;to check if
%    the sensor reading is below the threshold; and returns a
%    logical output.
% ------------------------------------------------------
% Syntax
%   isBright = isItBright(lightValue, lightThreshold)
%  --------------------------------------------------------
% Input Arguments
%   lightValue - The voltage reading of the light sensor
%                    from 0 to 5 volts.
%   lightThreshold - The predefined voltage threshold for light.
%  ---------------------------------------------------------
% Output Arguments
%   isBright - The logical output of the comparison between the inputs to 
%              if the light sensor reading is below the threshold.
% ----------------------------------------------------------------
         isBright = lightValue > lightThreshold;
end

function feedback = isItQuality(isNoisy, isBright)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% --- help for isItQuality ---
% isItQuality
%    This is a user-defined function that accepts two logical inputs and 
%    displays the string ststement base on the category the logical inputs
%    are under. 
% ------------------------------------------------------
% Syntax
%   feedback = isItQuality(isNoisy, isBright)
%  --------------------------------------------------------
% Input Arguments
%   isNoisy - a logical inpute i.e 1 or 0
%                    
%   isBright -  a logical inpute i.e 1 or 0
%  ---------------------------------------------------------
% Output Arguments
%   feedback - a string statement that notifies users on the state of the 
%              learning environment.
% ----------------------------------------------------------------
     if ~isNoisy && isBright
         feedback = "Quiet and Bright";
     elseif isNoisy && isBright
         feedback = "Too Noisy";
     elseif ~isNoisy && ~isBright
         feedback = "Too Dark";
     else
         feedback = "Noisy and Dark";
     end
end


