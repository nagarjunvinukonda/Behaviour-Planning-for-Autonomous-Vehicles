% Set up Script for the Lane Following Example
%
% This script initializes the lane following example model. It loads
% necessary control constants and sets up the buses required for the
% referenced model.
%
%   This is a helper script for example purposes and may be removed or
%   modified in the future.

%   Copyright 2018 The MathWorks, Inc.

%% General Model Parameters
Ts = 0.1;               % Simulation sample time  (s)

%% Path following Controller Parameters
time_gap        = 1.5;   % time gap               (s)
default_spacing = 10;    % default spacing        (m)
max_ac          = 2;     % Maximum acceleration   (m/s^2)
min_ac          = -3;    % Minimum acceleration   (m/s^2)
max_steer       = 0.26;  % Maximum steering       (rad)
min_steer       = -0.26; % Minimum steering       (rad) 
PredictionHorizon = 30;  % Prediction horizon     

%% Create driving scenario
% The scenario name is a scenario file created by the Driving Scenario Designer App. 
scenariosNames = {
    'ACC_01_ISO_TargetDiscriminationTest.mat',...          % scenarioId = 1
    'ACC_02_ISO_AutoRetargetTest.mat',...                  % scenarioId = 2
    'ACC_03_ISO_CurveTest.mat',...                         % scenarioId = 3
    'ACC_04_StopnGo.mat',...                               % scenarioId = 4
    'LFACC_01_DoubleCurve_DecelTarget.mat',...             % scenarioId = 5
    'LFACC_02_DoubleCurve_AutoRetarget.mat',...            % scenarioId = 6
    'LFACC_03_DoubleCurve_StopnGo.mat',...                 % scenarioId = 7
    'LFACC_04_Curve_CutInOut.mat',...                      % scenarioId = 8
    'LFACC_05_Curve_CutInOut_TooClose.mat',...             % scenarioId = 9
    'mySin_LF_03__DbCurve.mat',...                % Scenar =10
    };
scenarioStopTimes = [19.82 17.99 21.99 28.61 27.3 39.66 34.28 22.8 23.47 34.28];
scenarioId = 10;

% The scenario file is converted to a drivingScenario object
% initial conditions of ego car and actor profiles
[scenario,egoCar,actor_Profiles] = helperSessionToScenario(scenariosNames{scenarioId});

if scenarioId == 8 || scenarioId == 9
    v_set = 21.5;       % ACC set speed (m/s)
else
    v_set = egoCar.v0;  % ACC set speed (m/s)
end

% Initial condition for the ego car in ISO 8855 coordinates
v0_ego   = egoCar.v0;          % Initial speed of the ego car           (m/s)
x0_ego   = egoCar.x0;          % Initial x position of ego car          (m)
y0_ego   = egoCar.y0;          % Initial y position of ego car          (m)
yaw0_ego = egoCar.yaw0;        % Initial yaw angle of ego car           (rad)

% Convert ISO 8855 to SAE J670E coordinates
y0_ego = -y0_ego;
yaw0_ego = -yaw0_ego;

% Define a simulation stop time
simStopTime = scenarioStopTimes(scenarioId);

%% Tracking and Sensor Fusion Parameters                        Units
clusterSize = 4;        % Distance for clustering               (m)
assigThresh = 20;       % Tracker assignment threshold          (N/A)
M           = 2;        % Tracker M value for M-out-of-N logic  (N/A)
N           = 3;        % Tracker M value for M-out-of-N logic  (N/A)
numCoasts   = 5;        % Number of track coasting steps        (N/A)
numTracks   = 100;       % Maximum number of tracks              (N/A)
numSensors  = 2;        % Maximum number of sensors             (N/A)

% Position and velocity selectors from track state
% The filter initialization function used in this example is initcvekf that 
% defines a state that is: [x;vx;y;vy;z;vz]. 
posSelector = [1,0,0,0,0,0; 0,0,1,0,0,0]; % Position selector   (N/A)
velSelector = [0,1,0,0,0,0; 0,0,0,1,0,0]; % Velocity selector   (N/A)

%% Ego Car Parameters
% Dynamics modeling parameters
m       = 1575;     % Total mass of vehicle                          (kg)
Iz      = 2875;     % Yaw moment of inertia of vehicle               (m*N*s^2)
lf      = 1.2;      % Longitudinal distance from c.g. to front tires (m)
lr      = 1.6;      % Longitudinal distance from c.g. to rear tires  (m)
Cf      = 19000;    % Cornering stiffness of front tires             (N/rad)
Cr      = 33000;    % Cornering stiffness of rear tires              (N/rad)
tau     = 0.5;      % time constant for longitudinal dynamics 1/s/(tau*s+1)
%% Bus Creation
% Load the Simulink model
modelName = 'LaneFollowingTestBenchExample';
wasModelLoaded = bdIsLoaded(modelName);
if ~wasModelLoaded
    load_system(modelName)
end

% Create buses for lane sensor and lane sensor boundaries
createLaneSensorBuses;

% load the bus for scenario reader
blk=find_system(modelName,'System','driving.scenario.internal.ScenarioReader');
s = get_param(blk{1},'PortHandles');
get(s.Outport(1),'SignalHierarchy');

% Set the scenario reader file name to the selected scenario
set_param(blk{1},'ScenarioFileName',scenariosNames{scenarioId});

% Create the bus of tracks (output from referenced model)
refModel = 'LFRefMdl';
wasReModelLoaded = bdIsLoaded(refModel);
if ~wasReModelLoaded
    load_system(refModel)
    blk=find_system(refModel,'System','multiObjectTracker');
    multiObjectTracker.createBus(blk{1});
    close_system(refModel)
else
    blk=find_system(refModel,'System','multiObjectTracker');
    multiObjectTracker.createBus(blk{1});
end

%% Code generation
% To generate code, uncomment the following commands.
% refModel = 'LFRefMdl';
% rtwbuild(refModel)